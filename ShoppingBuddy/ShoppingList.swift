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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var ref = Database.database().reference()
    private var shoppingListRef = Database.database().reference().child("shoppinglists")
    var alertMessageDelegate: IAlertMessageDelegate?
    var firebaseWebServiceDelegate: IFirebaseWebService?
    var ID:String?
    var Name:String?
    var RelatedStore:String?
    var ItemsArray:[ShoppingListItem]?
    var MembersArray:[String]?
    
    init() {
        ItemsArray = []
        MembersArray = []
    }
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestFinished() {
        if firebaseWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.firebaseWebServiceDelegate!.FirebaseRequestFinished!()
            }
        } else {
            NSLog("firebaseWebServiceDelegate not set from calling class. FirebaseRequestFinished in ShoppingList")
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
    func FirebaseUserLoggedOut() { }
    func FirebaseUserLoggedIn() { }
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil {
            DispatchQueue.main.async {
                self.alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
            }
        } else {
            NSLog("alertMessageDelegate not set from calling class in ShoppingList")
        }
    }
    
    //MARK:FirebaseSave Functions
    func SaveListToFirebaseDatabase(listName:String, relatedStore:String) -> Void {
        let listID =  shoppingListRef.childByAutoId()
        listID.updateChildValues(["id":listID.key, "name":listName, "relatedStore":relatedStore], withCompletionBlock: { (error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            listID.child("member").updateChildValues([Auth.auth().currentUser!.uid:Auth.auth().currentUser!.uid])
            //Save List also local to CoreData
            self.SaveListToCoreData(listID: listID.key, relatedStore: relatedStore)
            NSLog("Succesfully saved Shopping List to Firebase")
            self.ObserveShoppingList(listID: listID.key)
        })
    }
    private func SaveListToCoreData(listID: String, relatedStore:String){
        DispatchQueue.main.async {
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            let coreDataListID:ListID = ListID.InsertIntoManagedObjectContext(context: self.context)
            coreDataListID.listID = listID
            coreDataListID.relatedStore = relatedStore
            ListID.SaveListID(userID: Auth.auth().currentUser!.uid, listID: coreDataListID, context: self.context)
        }
    }
    
    //Firebase Observe Functions
    func ObserveShoppingList(listID: String) -> Void{
        shoppingListRef.child(listID).observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull{ return }
            //Get ListData
            let newShoppinglist = ShoppingList()
            if let dict = snapshot.value as? NSDictionary{
                newShoppinglist.ID = dict["id"] as? String ?? ""
                newShoppinglist.Name = dict["name"] as? String ?? ""
                newShoppinglist.RelatedStore = dict["relatedStore"] as? String ?? ""
            }
            //Get listitemsData
            let itemDataSnapshot = snapshot.childSnapshot(forPath: "items")
            var newItems = [ShoppingListItem]()
            for snap in itemDataSnapshot.children{
                let item = snap as! DataSnapshot
                if let dict = item.value as? [String: AnyObject]{
                    let listItem:ShoppingListItem = ShoppingListItem()
                    listItem.ID = dict["id"] as? String != nil ? (dict["id"] as? String)! : ""
                    listItem.ItemName = dict["itemName"] as? String != nil ? (dict["itemName"] as? String)! : ""
                    listItem.isSelected = dict["isSelected"] as? String != nil ? (dict["isSelected"] as? String)! : ""
                    listItem.ShoppingListID = newShoppinglist.ID!
                    newItems.append(listItem)
                }
            }
            newShoppinglist.ItemsArray = newItems.filter({$0.ShoppingListID == newShoppinglist.ID!}).sorted(by: {return $0.isSelected! < $1.isSelected!})
            //Get list members Data
            let memberDataSnapshot = snapshot.childSnapshot(forPath: "members")
            var newMembers = [String]()
            for snap in memberDataSnapshot.children{
                let member = snap as! DataSnapshot
                if let memberStr:String =  member.value as? String{
                    newMembers.append(memberStr)
                }
            }
            newShoppinglist.MembersArray = newMembers
            //Refresh local Array Data
            self.RefreshLocalShoppingListArray(newShoppinglist: newShoppinglist)
        })
    }
    private func RefreshLocalShoppingListArray(newShoppinglist:ShoppingList){
        if let index = ShoppingListsArray.index(where: {$0.ID == newShoppinglist.ID!}){
            ShoppingListsArray.remove(at: index)
            ShoppingListsArray.append(newShoppinglist)
            self.FirebaseRequestFinished()
        } else {
            ShoppingListsArray.append(newShoppinglist)
            self.FirebaseRequestFinished()
        }
    }
    
    //MARK: - Delete Functions
    func DeleteShoppingListFromFirebase(listToDelete: ShoppingList) -> Void {
        let storeRef = self.shoppingListRef.child(listToDelete.ID!)
        storeRef.removeValue { (error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            NSLog("Succesfully deleted Shopping List from Firebase")
            //Remove also from local array & CoreData
            self.RemoveShoppingListLocal(listToDelete: listToDelete)
            self.FirebaseRequestFinished()
        }
    }
    private func RemoveShoppingListLocal(listToDelete: ShoppingList){
        DispatchQueue.main.async {
            if let index = ShoppingListsArray.index(where: {$0.ID == listToDelete.ID!}){
                ShoppingListsArray.remove(at: index)
                if let listID = ListID.FetchListID(userID:Auth.auth().currentUser!.uid , idToFetch: listToDelete.ID!, context: self.context){
                    ListID.DeleteListID(listID: listID.first!, context: self.context)
                    self.FirebaseRequestFinished()
                }
            }
        }
    }
}
