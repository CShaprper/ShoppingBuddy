//
//  ShoppingList.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 28.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class ShoppingList: IFirebaseWebService {
    private var ref = Database.database().reference()
    private var shoppingListRef = Database.database().reference().child("shopping-lists")
    var alertMessageDelegate: IAlertMessageDelegate?
    var firebaseWebServiceDelegate: IFirebaseWebService?
    var ID:String?
    var Name:String?
    var RelatedStore:String?
    var ItemsArray:[ShoppingListItem]?
    
    init() {
        ItemsArray = []
    }
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestFinished() {
        if firebaseWebServiceDelegate != nil{
            firebaseWebServiceDelegate!.FirebaseRequestFinished!()
        } else {
            print("firebaseWebServiceDelegate not set from calling class. FirebaseRequestFinished in ShoppingList")
        }
    }
    func FirebaseRequestStarted() {
        if firebaseWebServiceDelegate != nil{
            firebaseWebServiceDelegate!.FirebaseRequestStarted!()
        } else {
            print("firebaseWebServiceDelegate not set from calling class. FirebaseRequestStarted in ShoppingList")
        }
    }
    func FirebaseUserLoggedOut() { }
    func FirebaseUserLoggedIn() { }
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil {
            alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
        } else {
            print("alertMessageDelegate not set from calling class in ShoppingList")
        }
    }
    
    //MARK: - Firebase Read Functions
    func ReadFirebaseShoppingListsSection() -> Void {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        shoppingListRef.child(uid).observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull{ return }
            for sList in snapshot.children{
                let list = sList as! DataSnapshot
                let newShoppinglist = ShoppingList()
                if let dict = list.value as? NSDictionary{
                    newShoppinglist.ID = dict["id"] as? String ?? ""
                    newShoppinglist.Name = dict["name"] as? String ?? ""
                    newShoppinglist.RelatedStore = dict["relatedStore"] as? String ?? ""
                    let store = dict["relatedStore"] as? String ?? ""
                    self.AppendToStoresArray(store: store)
                }
                let itemDataSnapshot = list.childSnapshot(forPath: "items")
                var newItems = [ShoppingListItem]()
                for snap in itemDataSnapshot.children{
                    let item = snap as! DataSnapshot
                    if let dict = item.value as? [String: AnyObject]{
                        var listItem:ShoppingListItem = ShoppingListItem()
                        listItem.ID = dict["id"] as? String != nil ? (dict["id"] as? String)! : ""
                        listItem.ItemName = dict["itemName"] as? String != nil ? (dict["itemName"] as? String)! : ""
                        listItem.isSelected = dict["isSelected"] as? String != nil ? (dict["isSelected"] as? String)! : ""
                        listItem.ShoppingListID = newShoppinglist.ID!
                        newItems.append(listItem)
                    }
                }
                newShoppinglist.ItemsArray = newItems.filter({$0.ShoppingListID == newShoppinglist.ID!}).sorted(by: {return $0.isSelected! < $1.isSelected!})
                if let index = ShoppingListsArray.index(where: {$0.ID == newShoppinglist.ID!}){
                    ShoppingListsArray[index].ID = newShoppinglist.ID
                    ShoppingListsArray[index].Name = newShoppinglist.Name
                    ShoppingListsArray[index].RelatedStore = newShoppinglist.RelatedStore
                    ShoppingListsArray[index].ItemsArray = newShoppinglist.ItemsArray
                } else {
                    ShoppingListsArray.append(newShoppinglist)
                }
            }
            self.FirebaseRequestFinished()
        })
    }
    private func AppendToStoresArray(store: String){
        if store != ""{
            if !StoresArray.contains(store){
                StoresArray.append(store)
                //Save Stores Array to UserDefaults
                UserDefaults.standard.setValue(StoresArray, forKey: eUserDefaultKey.StoresArray.rawValue)
            }
        }
    }
    
    
    func DeleteShoppingListFromFirebase(listToDelete: ShoppingList) -> Void {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
       let storeRef = self.shoppingListRef.child(uid).child(listToDelete.ID!)
        storeRef.removeValue { (error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            print("Succesfully deleted Shopping List from Firebase")
            self.FirebaseRequestFinished()
        }
    }
}
