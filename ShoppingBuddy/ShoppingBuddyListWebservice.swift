//
//  ShhoppingBuddyListWebservice.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

class ShoppingBuddyListWebservice {
    var alertMessageDelegate: IAlertMessageDelegate?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    internal var sbUserService:ShoppingBuddyUserWebservice!
    
    internal var ref = Database.database().reference()
    internal var userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
    
    init() {
        sbUserService = ShoppingBuddyUserWebservice()
        
    }
    
    
    ///Saves a new Shopping List in firebase "shoppinglists" node
    ///The creation of a node "shoppingList_member" that stores the user id will be performed as firebase function.
    /**- Parameters:
     - currentUser: - ShoppingBuddyUser: The current user
     - listName: - String: Name of the list to save
     - relatedStore: - String: Name of the store that is related to this shopping list
     */
    func SaveListToFirebaseDatabase(currentUser:ShoppingBuddyUser, listName:String, relatedStore:String) -> Void {
        
        self.ShowActivityIndicator()
        let newListRef = ref.child("shoppinglists").childByAutoId()
        newListRef.updateChildValues(["listName":listName, "relatedStore":relatedStore, "owneruid":Auth.auth().currentUser!.uid], withCompletionBlock: { (error, dbRef) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            self.HideActivityIndicator()
            
        })
    }
    
    
    //MARK: - Firebase Observe Functions
    
    func ObserveAllList() -> Void{
        if currentUser == nil { return }
        
        self.ShowActivityIndicator()
        ref.child("users_shoppinglists").child(Auth.auth().currentUser!.uid).observe(.value, with: { (usersListsSnap) in            
            
            allShoppingLists = []
            
            if usersListsSnap.value is NSNull {
                
                self.HideActivityIndicator()
                return
            
            }

            for listSnap in usersListsSnap.children {
                
                let list = listSnap as! DataSnapshot
                
                self.ref.child("shoppinglists").child(list.key).observe(.value, with: { (snapshot) in
                    
                    if snapshot.value is NSNull { self.HideActivityIndicator(); return }
                    
                    
                    //Read listData
                    var newList = ShoppingList()
                    newList.id = snapshot.key
                    newList.name = snapshot.childSnapshot(forPath: "listName").value as? String
                    newList.owneruid = snapshot.childSnapshot(forPath: "owneruid").value as? String
                    newList.relatedStore = snapshot.childSnapshot(forPath: "relatedStore").value as? String
                    
                    self.getUser(userID: newList.owneruid!)
                    
                 
                    if let index = allShoppingLists.index(where: { $0.id == newList.id }){
                        
                        allShoppingLists[index] = newList
                        
                    } else {
                        
                        allShoppingLists.append(newList)
                        
                    }
                    
                    
                    //Read List members
                    self.ObserveListMembers()
                    
                    // Read list Items
                    self.ObserveListItems()
                    
                    self.HideActivityIndicator()
                    NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyListDataReceived, object: nil, userInfo: nil)
                    
                    
                    
                    
                }) { (error) in
                    
                    self.HideActivityIndicator()
                    NSLog(error.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                    return
                    
                }
                
            }
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
        
        
    }
    
    private func getUser(userID:String) -> Void {
        
        //download user if unknown
        if let _ = allUsers.index(where: { $0.id == userID }) { }
        else {
            sbUserService.ObserveUser(userID:userID, dlType: .DownloadForShoppingList)
        }
        
    }
    
    private func ObserveListMembers() -> Void {
        
        if allShoppingLists.isEmpty { return }
        self.ShowActivityIndicator()
        
        for list in allShoppingLists {
            //Read List members
            self.ref.child("shoppinglist_member").child(list.id!).observe(.value, with: { (memberSnap) in
                
                var newMembers = [ShoppingListMember]()
                for members in memberSnap.children {
                    
                    let member = members as! DataSnapshot
                    var m = ShoppingListMember()
                    m.listID = list.id!
                    m.memberID = member.key 
                    m.status = member.value as? String
                    
                    self.getUser(userID: m.memberID!)
                    
                    //dont append listowner
                    if m.memberID != list.owneruid {
                            
                            newMembers.append(m)
                            
                    }
                    
                }
                
                
                if let index = allShoppingLists.index(where: { $0.id == list.id! }){
                    
                    OperationQueue.main.addOperation {
                        allShoppingLists[index].members = newMembers
                    }
                }
                
                self.HideActivityIndicator()
                NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyListDataReceived, object: nil, userInfo: nil)
                
                
                
            }, withCancel: { (error) in
                
                self.HideActivityIndicator()
                NSLog(error.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            })
        }
        
    }
    
    private func ObserveListItems() -> Void {
        
        self.ShowActivityIndicator()
        //Read List items
        for list in allShoppingLists {
            
            self.ref.child("listItems").child(list.id!).queryOrdered(byChild: "sortNumber").observe(.value, with: { (itemSnap) in
                
                var newItems = [ShoppingListItem]()
                for items in itemSnap.children {
                    
                    let item = items as! DataSnapshot
                    var newItem = ShoppingListItem()
                    newItem.id = item.key
                    newItem.listID  = list.id!
                    newItem.isSelected = item.childSnapshot(forPath: "isSelected").value as? Bool
                    newItem.itemName = item.childSnapshot(forPath: "itemName").value as? String
                    newItem.sortNumber = item.childSnapshot(forPath: "sortNumber").value as? Int
                    
                    //Logic for FullVersionUser
                    guard let user = currentUser else { return }
                    guard let isFullVersionUser = user.isFullVersionUser else { return }
                    
                    if !isFullVersionUser && newItems.count >= 7 {
                        
                        continue
                        
                    } else {
                        
                        newItems.append(newItem)
                        
                    }
                    
                }
                if let index = allShoppingLists.index(where: { $0.id == list.id! }){
                
                    OperationQueue.main.addOperation {
                        allShoppingLists[index].items = newItems
                    }
                    
                }
                
                self.HideActivityIndicator()
                NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyListDataReceived, object: nil, userInfo: nil)
                
            }, withCancel: { (error) in
                
                self.HideActivityIndicator()
                NSLog(error.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            })
            
        }
        
    }
    
    func CancelSharingByOwnerForUser(userToDelete:ShoppingBuddyUser , listToCancel:ShoppingList) -> Void {
        
        self.ShowActivityIndicator()
        
        //Add message for canceled user to messages node
        let title = String.ListOwnerCanceledSharingTitle
        let message = String.localizedStringWithFormat(String.ListOwnerCanceledSharingMessage, currentUser!.nickname!, userToDelete.nickname!, listToCancel.name!)
        self.ref.child("messages").childByAutoId().updateChildValues(["listID":listToCancel.id!, "title":title, "message":message, "senderID":Auth.auth().currentUser!.uid, "messageType":eNotificationType.CancelSharingByOwner.rawValue, "userIDToDelete": userToDelete.id!], withCompletionBlock: { (error, dbRef) in
            
            if error != nil{
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
        })
        
        self.HideActivityIndicator()
        
    }
    
    func CancelSharingBySharedUserForMember(member:ShoppingBuddyUser, listToCancel:ShoppingList) -> Void {
        
        self.ShowActivityIndicator()
        //Add message to messages node
        let title = String.SharedUserCanceledSharingTitle
        let message = String.localizedStringWithFormat(String.SharedUserCanceledSharingMessage, currentUser!.nickname!, listToCancel.name! )
        self.ref.child("messages").childByAutoId().updateChildValues(["listID":listToCancel.id!, "title":title, "message":message, "senderID":Auth.auth().currentUser!.uid, "messageType":eNotificationType.CancelSharingBySharedUser.rawValue, "userIDToDelete": member.id!]) { (error, dbRef) in
        
            if error != nil{
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            
        }
        
    }
    
    func GetStoresForGeofencing() -> Void {
        
        if currentUser?.id == nil { return }
        
        self.ShowActivityIndicator()
        ref.child("users_shoppinglists").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                self.HideActivityIndicator()
                return
                
            }
            
            possibleRegionsPerStore = Int(snapshot.childrenCount)
            for lists in snapshot.children {
                
                guard let list = lists as? DataSnapshot else {
                    
                    self.HideActivityIndicator()
                    return
                    
                }
                
                self.ref.child("shoppinglists").child(list.key).observeSingleEvent(of: .value, with: { (listSnap) in
                    
                    let store = listSnap.childSnapshot(forPath: "relatedStore").value as? String
                    
                    if store == nil { self.HideActivityIndicator(); return }
                    
                    self.ref.child("listItems").child(list.key).observeSingleEvent(of: .value, with: { (itemSnap) in
                        
                        if itemSnap.childrenCount == 0  { self.HideActivityIndicator(); return } // only observe store when list contains open items
                        
                        var cnt:Int = 0
                        for items in itemSnap.children {
                            
                            let item = items as! DataSnapshot
                            let isSelected = item.childSnapshot(forPath: "isSelected").value as? Bool
                            cnt = isSelected! == false ? cnt + 1 : cnt
                            
                        }
                        
                        if cnt == 0 { self.HideActivityIndicator(); return }
                        let userInfo = ["store": store!]
                        
                        NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyStoreReceived, object: nil, userInfo: userInfo)
                        self.HideActivityIndicator()
                        
                    })
                    
                    
                }, withCancel: { (error) in
                    
                    NSLog(error.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                    return
                    
                })
                
            }
        })
    }
    
    func OrderShoppingListItems(list: ShoppingList) -> Void {
        
        self.ShowActivityIndicator()
        
        for i in 0..<list.items.count{
             ref.child("listItems").child(list.items[i].id!).child("sortNumber").setValue(i + 1)
        }
        self.HideActivityIndicator()
        
    }
    
    
    //MARK: - Delete Functions
    func DeleteShoppingListFromFirebase(listToDelete: ShoppingList) -> Void {
        self.ShowActivityIndicator()
        
        ref.child("shoppinglists").child(listToDelete.id!).child("status").setValue("deleted by owner", withCompletionBlock: { (error, dbRef) in
            
            if error != nil{
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            NSLog("Succesfully deleted Shopping List from Firebase")
            
            OperationQueue.main.addOperation {
                
                if let index = allShoppingLists.index(where: { $0.id == listToDelete.id }) {
                    allShoppingLists.remove(at: index)
                }
                
            }
            
        })
    }
}


extension ShoppingBuddyListWebservice: IActivityAnimationService, IAlertMessageDelegate {
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        HideActivityIndicator()
        if alertMessageDelegate != nil {
            OperationQueue.main.addOperation {
                self.alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
            }
        } else {
            NSLog("alertMessageDelegate not set from calling class in ShoppingList")
        }
    }
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            OperationQueue.main.addOperation {
                self.activityAnimationServiceDelegate!.ShowActivityIndicator!()
            }
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. ShowActivityIndicator() in ShoppingList")
        }
    }
    func HideActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            OperationQueue.main.addOperation {
                self.activityAnimationServiceDelegate!.HideActivityIndicator!()
            }
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. HideActivityIndicator() in ShoppingList")
        }
    }
    
}
