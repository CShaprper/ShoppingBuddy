//
//  ShoppingBuddyListItemWebservice.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ShoppingBuddyListItemWebservice {
    var alertMessageDelegate: IAlertMessageDelegate?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    
    internal var ref = Database.database().reference()
    internal var userRef = Database.database().reference().child("users")
    internal var listItemRef = Database.database().reference().child("listItems")
    
    
    
    //MARK: - Edit Functions
    func EditIsSelectedOnShoppingListItem(listItem: ShoppingListItem) -> Void {
        self.ShowActivityIndicator()
        
        listItemRef.child(listItem.listID!).child(listItem.id!).child("isSelected").setValue(listItem.isSelected!)
        
    }
    
    //MARK: - Save functions
    func SaveListItemToFirebaseDatabase(listItem: ShoppingListItem, currentShoppingListIndex:Int) -> Void {
        self.ShowActivityIndicator()
        let itemRef = listItemRef.child(listItem.listID!).childByAutoId()
        
        itemRef.updateChildValues(["sortNumber":0, "itemName":listItem.itemName!, "isSelected":false]) { (error, dbRef) in
            
            if error != nil{
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            var newListItem = listItem
            newListItem.id = itemRef.key
            
            NotificationCenter.default.post(name: Notification.Name.ListItemSaved, object: nil, userInfo: nil)
            NSLog("Succesfully saved ShoppingListItem to Firebase")
            
            
            //Add Message if shoppinglist members available && the only one shopping list member is not owner
            if allShoppingLists[currentShoppingListIndex].members.count == 1 && allShoppingLists[currentShoppingListIndex].members[0].status == "owner" { return }
            
            let messagesRef = self.ref.child("messages").childByAutoId()
            
            for receipt in allShoppingLists[currentShoppingListIndex].members {
      
                if receipt.memberID! == Auth.auth().currentUser!.uid { continue }
                 self.ref.child("message_receipts").child(messagesRef.key).updateChildValues([receipt.memberID!:"receipt"])
                 self.ref.child("users_messages").child(receipt.memberID!).child(messagesRef.key).setValue(eNotificationType.ListItemAddedBySharedUser.rawValue)
                
            }
            
            //Add message to messages node
            //TODO: variate by language
            let title = String.ListItemAddedTitle
            let message = String.localizedStringWithFormat(NSLocalizedString("ListItemAddedMessage", comment: ""), currentUser!.nickname!, listItem.itemName!, allShoppingLists[currentShoppingListIndex].name!) 
            
            messagesRef.updateChildValues(["listID":listItem.listID!, "title":title, "message":message, "senderID":currentUser!.id!, "messageType":eNotificationType.ListItemAddedBySharedUser.rawValue], withCompletionBlock: { (error, dbRef) in
                
                if error != nil{
                    
                    NSLog(error!.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error!.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                    return
                    
                }
                
            })
            
        }
    }
    
    func ObserveListItem(listItem: ShoppingListItem) -> Void {
        self.ShowActivityIndicator()
        listItemRef.child(listItem.listID!).child(listItem.id!).observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull { return }
            var newlistItem = ShoppingListItem()
            newlistItem.id = snapshot.key
            newlistItem.listID = listItem.listID
            newlistItem.isSelected = snapshot.childSnapshot(forPath: "isSelected").value as? Bool
            newlistItem.sortNumber = snapshot.childSnapshot(forPath: "sortNumber").value as? Int
            newlistItem.itemName = snapshot.childSnapshot(forPath: "itemName").value as? String
            
            DispatchQueue.main.async {
                
                if let listIndex = allShoppingLists.index(where: { $0.id == listItem.listID! }) {
                    
                    if let itemIndex = allShoppingLists[listIndex].items.index(where: { $0.id == listItem.id! }) {
                        
                        allShoppingLists[listIndex].items[itemIndex] = newlistItem
                        NotificationCenter.default.post(name: Notification.Name.ListItemReceived, object: nil, userInfo: nil)
                        
                    } else {
                        
                        allShoppingLists[listIndex].items.append(newlistItem)
                        NotificationCenter.default.post(name: Notification.Name.ListItemReceived, object: nil, userInfo: nil)
                        
                    }
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
    
    //MARK: - Delete Functions
    func DeleteShoppingListItemFromFirebase(itemToDelete: ShoppingListItem){
        self.ShowActivityIndicator()
        listItemRef.child(itemToDelete.listID!).child(itemToDelete.id!).removeValue { (error, dbref) in
            
            if error != nil{
                
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            NSLog("Succesfully deleted item of shopping list from Firebase")
            
        }
    }
}

extension ShoppingBuddyListItemWebservice: IAlertMessageDelegate, IActivityAnimationService {
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            DispatchQueue.main.async {
                self.activityAnimationServiceDelegate!.ShowActivityIndicator!()
            }
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. ShowActivityIndicator in ShoppingListItem")
        }
    }
    func HideActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            DispatchQueue.main.async {
                self.activityAnimationServiceDelegate!.HideActivityIndicator!()
            }
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. HideActivityIndicator in ShoppingListItem")
        }
    }
    
    //MARK: IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        self.HideActivityIndicator()
        if alertMessageDelegate != nil {
            DispatchQueue.main.async {
                self.alertMessageDelegate?.ShowAlertMessage(title: title, message: message)
            }
        } else {
            NSLog("AlertMessageDelegate not set from calling class in ShoppingListItem")
        }
    }
    
}
