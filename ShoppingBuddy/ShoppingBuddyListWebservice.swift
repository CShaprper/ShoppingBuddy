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

class ShoppingBuddyListWebservice: IShoppingBuddyListWebService, IAlertMessageDelegate, IActivityAnimationService{
    var alertMessageDelegate: IAlertMessageDelegate?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    var shoppingBuddyListWebServiceDelegate: IShoppingBuddyListWebService?
    
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
    
    //MARK: - IShoppingBuddyListWebService implementation
    func ShoppingBuddyStoreReceived(store: String) {
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil {
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyStoreReceived!(store: store)
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyStoresCollectionReceived() in ShoppingList")
        }
    }
    func ShoppingBuddyImageReceived() {
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyImageReceived!()
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyImageReceived() in ShoppingList")
        }
    }
    func ShoppingBuddyNewListSaved(listID: String) {
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyNewListSaved!(listID: listID)
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyNewListSaved() in ShoppingList")
        }
    }
    func ShoppingBuddyNewListReceived(listID: String) {
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyNewListReceived!(listID: listID)
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyNewListReceived() in ShoppingList")
        }
    }
    
    
    
    //Share Functions
    func SendFriendSharingInvitation(friendsEmail:String, list: ShoppingList, listOwner: ShoppingBuddyUser) -> Void {
        
        self.ShowActivityIndicator()
        
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: friendsEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                //User not found
                self.HideActivityIndicator()
                return
                
            }
            
            for childs in snapshot.children {
                
                let receipt = childs as! DataSnapshot
                
                //Write invitation Data to receipt ref
                let inviteRef = self.ref.child("users").child(receipt.key).child("invites").childByAutoId()
                let receiptFcmToken = receipt.childSnapshot(forPath: "fcmToken").value as! String
                let receiptProfileImageURL = receipt.childSnapshot(forPath: "profileImageURL").value as! String
                let receiptNickname = receipt.childSnapshot(forPath: "nickname").value as! String
                let inviteTitle = String.ShareListTitle + " \(listOwner.nickname!)"
                let inviteMessage = "\(listOwner.nickname!) " + String.ShareListMessage
                
                inviteRef.updateChildValues(["receiptID":receipt.key, "receiptFcmToken":receiptFcmToken, "receiptNickname":receiptNickname, "receiptProfileImageURL":receiptProfileImageURL, "senderFcmToken":Messaging.messaging().fcmToken!, "senderID":currentUser!.id!, "senderNickname":currentUser!.nickname!, "senderProfileImageURL":currentUser!.profileImageURL!, "inviteMessage":inviteMessage, "inviteTitle":inviteTitle, "listName":list.name!, "listID":list.id!], withCompletionBlock: { (error, dbRef) in
                    
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
        newListRef.updateChildValues(["listName":listName, "relatedStore":relatedStore, "owneruid":currentUser.id!, "ownerImageURL":currentUser.profileImageURL!], withCompletionBlock: { (error, dbRef) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            NSLog("Successfully saved List to Firebase Listname: %@ related Store: %@",listName, relatedStore)
                self.ShoppingBuddyNewListSaved(listID: newListRef.key)
        })
    }
    
    
    //MARK: - Firebase Observe Functions
    
    func ObserveAllList() -> Void{
        
        self.ShowActivityIndicator()
        if currentUser!.shoppingLists.isEmpty {
            
            self.HideActivityIndicator()
            return
            
        }
        
        for listID in currentUser!.shoppingLists {
            
            ObserveSingleList(listID: listID)
        }
        
    }
    
    
    func ObserveSingleList(listID:String) -> Void {
        
        self.ShowActivityIndicator()
        listRef.child(listID).queryOrdered(byChild: "isSelected").observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                self.HideActivityIndicator()
                return
                
            }
            
            //Read listData
            var newList = ShoppingList()
            newList.id = snapshot.key
            newList.name = snapshot.childSnapshot(forPath: "listName").value as? String
            newList.owneruid = snapshot.childSnapshot(forPath: "owneruid").value as? String
            newList.relatedStore = snapshot.childSnapshot(forPath: "relatedStore").value as? String
            newList.ownerImageURL = snapshot.childSnapshot(forPath: "ownerImageURL").value as? String
            
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
                newList.itemsArray = newItems
                
                if let index = ShoppingListsArray.index(where: { $0.id == listID }){
                    
                    ShoppingListsArray[index] = newList
                    
                } else {
                    
                    ShoppingListsArray.append(newList)
                    
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
    
    func ObserveNewList(listID:String) -> Void {
        
        self.ShowActivityIndicator()
        listRef.child(listID).queryOrdered(byChild: "isSelected").observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                self.HideActivityIndicator()
                return
                
            }
            
            var newList = ShoppingList()
            newList.id = snapshot.key
            newList.name = snapshot.childSnapshot(forPath: "listName").value as? String
            newList.owneruid = snapshot.childSnapshot(forPath: "owneruid").value as? String
            newList.ownerImageURL = snapshot.childSnapshot(forPath: "ownerImageURL").value as? String
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
                newList.itemsArray = newItems
                
                if let index = ShoppingListsArray.index(where: { $0.id == listID }){
                    
                    ShoppingListsArray[index] = newList
                    
                } else {
                    
                    ShoppingListsArray.append(newList)
                    
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
    
    func ObserveFriendsList(){
        
    }
    func GetStoresForGeofencing() -> Void {
        
        self.ShowActivityIndicator()
        userRef.child("shoppinglists").observeSingleEvent(of: .value, with: { (snapshot) in
            
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
                    
                    if store == nil {
                        self.HideActivityIndicator()
                        return
                    }
                    
                    self.itemsRef.child(list.key).observeSingleEvent(of: .value, with: { (itemSnap) in
                        
                        if itemSnap.childrenCount == 0  { return }
                        
                        var cnt:Int = 0
                        for items in itemSnap.children {
                            
                            let item = items as! DataSnapshot
                            let isSelected = item.childSnapshot(forPath: "isSelected").value as? Bool
                            cnt = isSelected! == false ? cnt + 1 : cnt
                            
                        }
                        
                        if cnt == 0 { return }
                        self.ShoppingBuddyStoreReceived(store: store!)
                        
                    })
                    
                    
                }, withCancel: { (error) in
                    
                    self.HideActivityIndicator()
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
        
        listRef.child(listToDelete.id!).removeValue { (error, dbref) in
            
            if error != nil{
                
                self.HideActivityIndicator()
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            NSLog("Succesfully deleted Shopping List from Firebase")
            //items and reference in user node is deleted on serverside code 
            
            if let index = ShoppingListsArray.index(where: { $0.id == listToDelete.id }) {
                ShoppingListsArray.remove(at: index)
            }
            
        }
    }
    
}
