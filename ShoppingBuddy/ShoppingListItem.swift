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

class ShoppingListItem: IFirebaseWebService {
    private var listItemRef = Database.database().reference().child("shoppinglists")
    var alertMessageDelegate: IAlertMessageDelegate?
    var firebaseWebServiceDelegate: IFirebaseWebService?
    
    var ID:String?
    var ItemName:String?
    var ShoppingListID:String?
    var isSelected:String?
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestFinished() {
        if firebaseWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.firebaseWebServiceDelegate!.FirebaseRequestFinished!()
            }
        } else {
            NSLog("firebaseWebServiceDelegate not set from calling class. FirebaseRequestFinished in ShoppingListItem")
        }
    }
    func FirebaseRequestStarted() {
        if firebaseWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.firebaseWebServiceDelegate!.FirebaseRequestStarted!()
            }
        } else {
            NSLog("firebaseWebServiceDelegate not set from calling class. FirebaseRequestStarted in ShoppingList")
        }
    }
    func FirebaseUserLoggedIn() { }
    func FirebaseUserLoggedOut() {}
    
    //MARK: IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil {
            DispatchQueue.main.async {
                self.alertMessageDelegate?.ShowAlertMessage(title: title, message: message)
            }
        } else {
            NSLog("AlertMessageDelegate not set from calling class in ShoppingListItem")
        }
    }
    
    //MARK: - Edit Functions
    func EditIsSelectedOnShoppingListItem(shoppingListItem: ShoppingListItem) -> Void{
        listItemRef.child(shoppingListItem.ShoppingListID!).child("items").child(shoppingListItem.ID!).child("isSelected").setValue(shoppingListItem.isSelected!)
    }
    
    
    //MARK: - Save functions
    func SaveListItemToFirebaseDatabase(shoppingListID:String, itemName:String) -> Void { 
       let itemref = listItemRef.child(shoppingListID).child("items").childByAutoId()
        itemref.updateChildValues(["id":itemref.key, "itemName":itemName, "isSelected":"false", "shoppingListID":shoppingListID], withCompletionBlock: {(error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                NSLog(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            self.FirebaseRequestFinished()
            // self.ReadFirebaseShoppingListsSection()
            NSLog("Succesfully saved ShoppingListItem to Firebase")
        })
    }
    
    //MARK: - Delete Functions
    func DeleteShoppingListItemFromFirebase(itemToDelete: ShoppingListItem){
        let itemRef = listItemRef.child(itemToDelete.ShoppingListID!).child("items").child(itemToDelete.ID!)
        itemRef.removeValue { (error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            NSLog("Succesfully deleted item of shopping list from Firebase")
            self.FirebaseRequestFinished()
        }
        
    }
}
