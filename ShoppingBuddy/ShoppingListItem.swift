//
//  ShoppingListItem.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 30.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class ShoppingListItem: IShoppingBuddyListItemWebService, IAlertMessageDelegate, IActivityAnimationService{
    private var ref = Database.database().reference()
    private var shoppingListRef = Database.database().reference().child("shoppinglists")
    var alertMessageDelegate: IAlertMessageDelegate?
    var firebaseWebServiceDelegate: IFirebaseWebService?
    var shoppingListItemWebServiceDelegate: IShoppingBuddyListItemWebService?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    
    var ID:String?
    var ItemName:String?
    var ShoppingListID:String?
    var isSelected:String?
    
    //MARK: - IShoppingBuddyListItemWebService
    func ListItemSaved() {
        self.HideActivityIndicator()
        if shoppingListItemWebServiceDelegate != nil {
            shoppingListItemWebServiceDelegate?.ListItemSaved!()
        } else {
            NSLog("shoppingListItemWebServiceDelegate not set from calling class. ListItemSaved in ShoppingListItem")
        }
    }
    func ListItemDeleted() {
        self.HideActivityIndicator()
        if shoppingListItemWebServiceDelegate != nil {
            shoppingListItemWebServiceDelegate?.ListItemDeleted!()
        } else {
            NSLog("shoppingListItemWebServiceDelegate not set from calling class. ListItemDeleted in ShoppingListItem")
        }
    }
    func ListItemChanged() {
        self.HideActivityIndicator()
        if shoppingListItemWebServiceDelegate != nil {
            shoppingListItemWebServiceDelegate?.ListItemChanged!()
        } else {
            NSLog("shoppingListItemWebServiceDelegate not set from calling class. ListItemChanged in ShoppingListItem")
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
    func EditIsSelectedOnShoppingListItem(listOwnerID:String, shoppingListItem: ShoppingListItem) -> Void {
        shoppingListRef.child(listOwnerID).child(shoppingListItem.ShoppingListID!).child("items").child(shoppingListItem.ID!).child("isSelected").setValue(shoppingListItem.isSelected!)
        self.ListItemChanged()
    }
    
    
    //MARK: - Save functions
    func SaveListItemToFirebaseDatabase(shoppingList:ShoppingList, itemName:String) -> Void {
        self.ShowActivityIndicator()
        let itemref = shoppingListRef.child(shoppingList.OwnerID!).child(shoppingList.ID!).child("items").childByAutoId()
        itemref.updateChildValues(["itemID":itemref.key, "itemName":itemName, "isSelected":"false", "shoppingListID":shoppingList.ID!], withCompletionBlock: {(error, dbref) in
            if error != nil{
                NSLog(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            self.ListItemSaved()
            NSLog("Succesfully saved ShoppingListItem to Firebase")
        })
    }
    
    //MARK: - Delete Functions
    func DeleteShoppingListItemFromFirebase(list:ShoppingList, itemToDelete: ShoppingListItem){
        self.ShowActivityIndicator()
        shoppingListRef.child(list.OwnerID!).child(list.ID!).child("items").child(itemToDelete.ID!).removeValue { (error, dbref) in
            if error != nil{ 
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            NSLog("Succesfully deleted item of shopping list from Firebase")
            self.ListItemDeleted()
        }
        
    }
}
