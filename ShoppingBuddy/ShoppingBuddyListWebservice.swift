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

class ShoppingBuddyListWebservice: IAlertMessageDelegate, IActivityAnimationService{
    var alertMessageDelegate: IAlertMessageDelegate?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    
    private var ref = Database.database().reference()
    private var userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
    private var listRef = Database.database().reference().child("shoppinglists")
    private var itemsRef = Database.database().reference().child("listItems")
    
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        HideActivityIndicator()
        if alertMessageDelegate != nil {
            DispatchQueue.main.async {
                self.alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
            }
        } else {
            NSLog("alertMessageDelegate not set from calling class in ShoppingList")
        }
    }
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            activityAnimationServiceDelegate!.ShowActivityIndicator!()
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. ShowActivityIndicator() in ShoppingList")
        }
    }
    func HideActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            activityAnimationServiceDelegate!.HideActivityIndicator!()
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. HideActivityIndicator() in ShoppingList")
        }
    }
    
    
    //Share Functions
    func SendFriendSharingInvitation(friendsEmail:String, list: ShoppingList, listOwner: ShoppingBuddyUser) -> Void {
        
        self.ShowActivityIndicator()
        
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: friendsEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value is NSNull { self.HideActivityIndicator(); return }
            
            for childs in snapshot.children {
                
                let receipt = childs as! DataSnapshot
                
                //Write invitation Data to receipt ref
                let inviteRef = self.ref.child("invites").childByAutoId()                
                let inviteTitle = String.ShareListTitle + " \(listOwner.nickname!)"
                let inviteMessage = "\(listOwner.nickname!) " + String.ShareListMessage
                
                inviteRef.updateChildValues(["receiptID":receipt.key, "senderID":currentUser!.id!, "inviteMessage":inviteMessage, "inviteTitle":inviteTitle, "listID":list.id!], withCompletionBlock: { (error, dbRef) in
                    
                    if error != nil {
                        
                        NSLog(error!.localizedDescription)
                        let title = String.OnlineFetchRequestError
                        let message = error!.localizedDescription
                        self.ShowAlertMessage(title: title, message: message)
                        return
                        
                    }
                    
                    NSLog("Succesfully sent invitation for sharing")
                })
            }
            
            self.HideActivityIndicator()
            
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
    }
    
    
    //MARK: - FirebaseSave Functions
    func SaveListToFirebaseDatabase(currentUser:ShoppingBuddyUser, listName:String, relatedStore:String) -> Void {
        
        self.ShowActivityIndicator()
        let newListRef = listRef.childByAutoId()
        newListRef.updateChildValues(["listName":listName, "relatedStore":relatedStore, "owneruid":currentUser.id!], withCompletionBlock: { (error, dbRef) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            self.HideActivityIndicator()
            NSLog("Successfully saved List to Firebase Listname: %@ related Store: %@",listName, relatedStore)
          
        })
    }
    
    
    //MARK: - Firebase Observe Functions
    
    func ObserveAllList() -> Void{
        
        self.ShowActivityIndicator()
        ref.child("users_shoppinglists").child(currentUser!.id!).observe(.value, with: { (usersListsSnap) in
            
            if usersListsSnap.value is NSNull { self.HideActivityIndicator(); return }
            
            for listSnap in usersListsSnap.children {
                
                let list = listSnap as! DataSnapshot
                
                self.ObserveSingleList(listID: list.key)
                
            }
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
        
        
    }
    
    func ObserveSingleList(listID:String) -> Void {
        
        self.ShowActivityIndicator()
        listRef.child(listID).queryOrdered(byChild: "isSelected").observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                self.HideActivityIndicator()
                if let index = allShoppingLists.index(where: { $0.id == listID }) {
                    
                    allShoppingLists.remove(at: index)
                    NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyListDataReceived, object: nil, userInfo: nil)
                    
                }
                
                return
                
            }
            
            //Read listData
            var newList = ShoppingList()
            newList.id = snapshot.key
            newList.name = snapshot.childSnapshot(forPath: "listName").value as? String
            newList.owneruid = snapshot.childSnapshot(forPath: "owneruid").value as? String
            newList.relatedStore = snapshot.childSnapshot(forPath: "relatedStore").value as? String 
            
            self.itemsRef.child(listID).observe(.value, with: { (itemSnap) in
                
                var newItems = [ShoppingListItem]()
                for items in itemSnap.children {
                    
                    let item = items as! DataSnapshot
                    var newItem = ShoppingListItem()
                    newItem.id = item.key
                    newItem.listID  = listID
                    newItem.isSelected = item.childSnapshot(forPath: "isSelected").value as? Bool
                    newItem.itemName = item.childSnapshot(forPath: "itemName").value as? String
                    newItem.sortNumber = item.childSnapshot(forPath: "sortNumber").value as? Int
                    newItems.append(newItem)
                    
                }
                newList.items = newItems
                
                //GroupMembers
                var newMembers = [String]()
                let m = snapshot.childSnapshot(forPath: "members")
                for members in m.children {
                    
                    let member = members as! DataSnapshot
                    
                    newMembers.append(member.key)
                    
                    NSLog("Succesfully added user \(member.key) to Group in List \(newList.name!)")
                    
                }
                
                newList.members = newMembers
                
                
                if let index = allShoppingLists.index(where: { $0.id == listID }){
                    
                    allShoppingLists[index] = newList
                    
                } else {
                    
                    allShoppingLists.append(newList)
                    
                }
                
                self.HideActivityIndicator()
                NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyListDataReceived, object: nil, userInfo: nil)
                
            })
            
        }) { (error) in
            
            self.HideActivityIndicator()
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
    }
    
    func GetStoresForGeofencing() -> Void {
        
        self.ShowActivityIndicator()
        ref.child("users_shoppinglists").child(currentUser!.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            
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
                
                self.listRef.child(list.key).observeSingleEvent(of: .value, with: { (listSnap) in
                    
                    let store = listSnap.childSnapshot(forPath: "relatedStore").value as? String
                    
                    if store == nil { self.HideActivityIndicator(); return }
                    
                    self.itemsRef.child(list.key).observeSingleEvent(of: .value, with: { (itemSnap) in
                        
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
    
    
    //MARK: - Delete Functions
    func DeleteShoppingListFromFirebase(listToDelete: ShoppingList) -> Void {
        self.ShowActivityIndicator()
        
        ref.child("users_shoppinglists").child(currentUser!.id!).child(listToDelete.id!).removeValue { (error, dbref) in
            
            if error != nil{
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            NSLog("Succesfully deleted Shopping List from Firebase")
            
            if let index = allShoppingLists.index(where: { $0.id == listToDelete.id }) {
                allShoppingLists.remove(at: index)
            }
            
        }
    }
    
}
