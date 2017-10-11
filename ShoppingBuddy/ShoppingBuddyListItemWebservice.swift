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
            
            self.HideActivityIndicator()
            NotificationCenter.default.post(name: Notification.Name.ListItemSaved, object: nil, userInfo: nil)
            NSLog("Succesfully saved ShoppingListItem to Firebase")
            
            let messagesRef = self.ref.child("messages").childByAutoId()
            
            //Add message to messages node  
            let title = String.ListItemAddedTitle
            let message = String.localizedStringWithFormat(String.ListItemAddedMessage, currentUser!.nickname!, listItem.itemName!, allShoppingLists[currentShoppingListIndex].name!) 
            
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
            
            self.HideActivityIndicator()
            NSLog("Succesfully deleted item of shopping list from Firebase")
            
        }
    }
}

extension ShoppingBuddyListItemWebservice: IAlertMessageDelegate, IActivityAnimationService {
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            OperationQueue.main.addOperation {
                self.activityAnimationServiceDelegate!.ShowActivityIndicator!()
            }
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. ShowActivityIndicator in ShoppingListItem")
        }
    }
    func HideActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            OperationQueue.main.addOperation {
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
            OperationQueue.main.addOperation {
                self.alertMessageDelegate?.ShowAlertMessage(title: title, message: message)
            }
        } else {
            NSLog("AlertMessageDelegate not set from calling class in ShoppingListItem")
        }
    }
    
}
