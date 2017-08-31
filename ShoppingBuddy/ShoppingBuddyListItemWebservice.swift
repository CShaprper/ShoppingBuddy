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

class ShoppingBuddyListItemWebservice: IShoppingBuddyListItemWebService, IAlertMessageDelegate, IActivityAnimationService {
    var alertMessageDelegate: IAlertMessageDelegate?
    var shoppingListItemWebServiceDelegate: IShoppingBuddyListItemWebService?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    
    private var ref = Database.database().reference()
    private var userRef = Database.database().reference().child("users")
    private var listItemRef = Database.database().reference().child("listItems")
    
    
    //MARK: - IShoppingBuddyListItemWebService
    func ListItemSaved() {
        self.HideActivityIndicator()
        if shoppingListItemWebServiceDelegate != nil {
            shoppingListItemWebServiceDelegate?.ListItemSaved!()
        } else {
            NSLog("shoppingListItemWebServiceDelegate not set from calling class. ListItemSaved in ShoppingListItem")
        }
    } 
    func ListItemReceived() {
        self.HideActivityIndicator()
        if shoppingListItemWebServiceDelegate != nil {
            shoppingListItemWebServiceDelegate!.ListItemReceived!()
        } else {
            NSLog("shoppingListItemWebServiceDelegate not set from calling class. ListItemReceived in ShoppingListItem")
        }
    }
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            activityAnimationServiceDelegate!.ShowActivityIndicator!()
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. ShowActivityIndicator in ShoppingListItem")
        }
    }
    func HideActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            activityAnimationServiceDelegate!.HideActivityIndicator!()
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
    
    //MARK: - Edit Functions
    func EditIsSelectedOnShoppingListItem(listItem: ShoppingListItem) -> Void {
        self.ShowActivityIndicator()
        
        listItemRef.child(listItem.listID!).child(listItem.id!).child("isSelected").setValue(listItem.isSelected!)
        
    }
    
    
    //MARK: - Save functions
    func SaveListItemToFirebaseDatabase(listItem: ShoppingListItem) -> Void {
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
            
            self.ListItemSaved()
            NSLog("Succesfully saved ShoppingListItem to Firebase")
            
            var newListItem = listItem
            newListItem.id = itemRef.key            
            //self.ObserveListItem(listItem: newListItem)
            
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
            
            if let listIndex = ShoppingListsArray.index(where: { $0.id == listItem.listID! }) {
                
                if let itemIndex = ShoppingListsArray[listIndex].itemsArray.index(where: { $0.id == listItem.id! }) {
                    
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].id = newlistItem.id
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].listID = newlistItem.listID
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].isSelected = newlistItem.isSelected
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].itemName = newlistItem.itemName
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].sortNumber = newlistItem.sortNumber
                    self.ListItemReceived()
                    
                } else {
                    
                    ShoppingListsArray[listIndex].itemsArray.append(newlistItem)
                    self.ListItemReceived()
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
