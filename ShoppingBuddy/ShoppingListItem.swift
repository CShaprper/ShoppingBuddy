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
    private var shoppingListRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("shoppinglists")
    var alertMessageDelegate: IAlertMessageDelegate?
    var shoppingListItemWebServiceDelegate: IShoppingBuddyListItemWebService?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    
    var id:String?
    var itemName:String?
    //var ShoppingListID:String?
    var isSelected:Bool?
    var sortNumber:Int?
    var amount:Int?
    var price:Double?
    
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
    func EditIsSelectedOnShoppingListItem(list:ShoppingList, shoppingListItem: ShoppingListItem) -> Void {
        self.ShowActivityIndicator()
        shoppingListRef.child(list.id!).child("items").child(shoppingListItem.id!).child("isSelected").setValue(shoppingListItem.isSelected!)
        self.ListItemChanged()
    }
    
    
    //MARK: - Save functions
    func SaveListItemToFirebaseDatabase(shoppingList:ShoppingList, itemName:String) -> Void {
       self.ShowActivityIndicator()
        let itemRef = shoppingListRef.child(shoppingList.id!).child("items").childByAutoId()
        itemRef.updateChildValues(["sortNumber":0, "itemName":itemName, "isSelected":false]) { (error, dbRef) in
            if error != nil{
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }            
            self.ListItemSaved()
            NSLog("Succesfully saved ShoppingListItem to Firebase")
        }
    }
    
    //MARK: - Delete Functions
    func DeleteShoppingListItemFromFirebase(list:ShoppingList, itemToDelete: ShoppingListItem){
    self.ShowActivityIndicator()
        shoppingListRef.child(list.id!).child("items").child(itemToDelete.id!).removeValue { (error, dbref) in
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
