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

class ShoppingList: IShoppingBuddyListWebService, IAlertMessageDelegate{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var ref = Database.database().reference()
    private var shoppingListRef = Database.database().reference().child("shoppinglists").child(Auth.auth().currentUser!.uid)
    var alertMessageDelegate: IAlertMessageDelegate?
    var shoppingBuddyListWebServiceDelegate: IShoppingBuddyListWebService?
    var ID:String?
    var OwnerID:String?
    var Name:String?
    var RelatedStore:String?
    var ItemsArray:[ShoppingListItem]?
    var MembersArray:[String]?
    
    init() {
        ItemsArray = []
        MembersArray = []
    }
    
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
    
    //MARK: - IShoppingBuddyListWebService implementation
    func ShoppingBuddyListDataReceived() {
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate?.ShoppingBuddyListDataReceived!()
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyListDataReceived() in ShoppingList")
        }
    }
    
    
    //MARK:FirebaseSave Functions
    func SaveListToFirebaseDatabase(listName:String, relatedStore:String) -> Void {
        let listID =  shoppingListRef.childByAutoId()
        listID.updateChildValues(["listID":listID.key, "ownerID":Auth.auth().currentUser!.uid, "name":listName, "relatedStore":relatedStore], withCompletionBlock: { (error, dbref) in
            if error != nil{
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            listID.child("members").child(Auth.auth().currentUser!.uid).setValue("owner")
            NSLog("Succesfully saved Shopping List to Firebase")
            self.ObserveShoppingList()
        })
    }
    /*private func SaveListToCoreData(listID: String, relatedStore:String){
        DispatchQueue.main.async {
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            let coreDataListID:ListID = ListID.InsertIntoManagedObjectContext(context: self.context)
            coreDataListID.listID = listID
            coreDataListID.relatedStore = relatedStore
            coreDataListID.userID = Auth.auth().currentUser!.uid
            ListID.SaveListID(listID: coreDataListID, context: self.context)
        }
    }*/
    
    //Firebase Observe Functions
    func ObserveFriendsList(){
        ref.child("users").child(Auth.auth().currentUser!.uid).child("friends").observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull{ return }
            for friends in snapshot.children{
                let friend = friends as! DataSnapshot
                var status:String = ""
                 if let dict = friend.value as? NSDictionary{
                    status = dict[friend.key] as? String ?? ""
                 } else { return }
                if status.isEmpty || status == "pending" { return }
                self.ref.child("shoppinglists").child(friend.key).observe(.value, with: { (snapshot) in
                    if snapshot.value is NSNull{ return }
                    let listDataSnapshot = snapshot
                    var newShoppingListArray:[ShoppingList] = []
                    for listSnap in listDataSnapshot.children{
                        let list = listSnap as! DataSnapshot
                        //Get ListData
                        let newShoppinglist = ShoppingList()
                        if let dict = list.value as? NSDictionary{
                            newShoppinglist.ID = dict["listID"] as? String ?? ""
                            newShoppinglist.OwnerID = dict["ownerID"] as? String ?? ""
                            newShoppinglist.Name = dict["name"] as? String ?? ""
                            newShoppinglist.RelatedStore = dict["relatedStore"] as? String ?? ""
                            
                            //Get listitemsData
                            let itemDataSnapshot = list.childSnapshot(forPath: "items")
                            var newItems = [ShoppingListItem]()
                            for snap in itemDataSnapshot.children{
                                let item = snap as! DataSnapshot
                                if let dict = item.value as? [String: AnyObject]{
                                    let listItem:ShoppingListItem = ShoppingListItem()
                                    listItem.ID = dict["itemID"] as? String != nil ? (dict["itemID"] as? String)! : ""
                                    listItem.ItemName = dict["itemName"] as? String != nil ? (dict["itemName"] as? String)! : ""
                                    listItem.isSelected = dict["isSelected"] as? String != nil ? (dict["isSelected"] as? String)! : ""
                                    listItem.ShoppingListID = newShoppinglist.ID!
                                    newItems.append(listItem)
                                }
                            }
                            newShoppinglist.ItemsArray = newItems.filter({$0.ShoppingListID == newShoppinglist.ID!}).sorted(by: {return $0.isSelected! < $1.isSelected!})
                            //Get list members Data
                            let memberDataSnapshot = list.childSnapshot(forPath: "members")
                            var newMembers = [String]()
                            for snap in memberDataSnapshot.children{
                                let member = snap as! DataSnapshot
                                if let memberStr:String =  member.value as? String{
                                    newMembers.append(memberStr)
                                }
                            }
                            newShoppinglist.MembersArray = newMembers
                            newShoppingListArray.append(newShoppinglist)
                        }
                    }
                    ShoppingListsArray.append(contentsOf: newShoppingListArray)
                    self.ShoppingBuddyListDataReceived()
                })
            }
        })
    }
    func ObserveShoppingList() -> Void{
        shoppingListRef.observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull{ return }
            let listDataSnapshot = snapshot
            var newShoppingListArray:[ShoppingList] = []
            for listSnap in listDataSnapshot.children{
                let list = listSnap as! DataSnapshot
                //Get ListData
                let newShoppinglist = ShoppingList()
                if let dict = list.value as? NSDictionary{
                    newShoppinglist.ID = dict["listID"] as? String ?? ""
                    newShoppinglist.OwnerID = dict["ownerID"] as? String ?? ""
                    newShoppinglist.Name = dict["name"] as? String ?? ""
                    newShoppinglist.RelatedStore = dict["relatedStore"] as? String ?? ""
                    
                    //Get listitemsData
                    let itemDataSnapshot = list.childSnapshot(forPath: "items")
                    var newItems = [ShoppingListItem]()
                    for snap in itemDataSnapshot.children{
                        let item = snap as! DataSnapshot
                        if let dict = item.value as? [String: AnyObject]{
                            let listItem:ShoppingListItem = ShoppingListItem()
                            listItem.ID = dict["itemID"] as? String != nil ? (dict["itemID"] as? String)! : ""
                            listItem.ItemName = dict["itemName"] as? String != nil ? (dict["itemName"] as? String)! : ""
                            listItem.isSelected = dict["isSelected"] as? String != nil ? (dict["isSelected"] as? String)! : ""
                            listItem.ShoppingListID = newShoppinglist.ID!
                            newItems.append(listItem)
                        }
                    }
                    newShoppinglist.ItemsArray = newItems.filter({$0.ShoppingListID == newShoppinglist.ID!}).sorted(by: {return $0.isSelected! < $1.isSelected!})
                    //Get list members Data
                    let memberDataSnapshot = list.childSnapshot(forPath: "members")
                    var newMembers = [String]()
                    for snap in memberDataSnapshot.children{
                        let member = snap as! DataSnapshot
                        if let memberStr:String =  member.value as? String{
                            newMembers.append(memberStr)
                        }
                    }
                    newShoppinglist.MembersArray = newMembers
                    newShoppingListArray.append(newShoppinglist)
                }
            }
            ShoppingListsArray = newShoppingListArray
            self.ObserveFriendsList()
        })
    }
   /* private func RefreshLocalShoppingListArray(newShoppinglist:ShoppingList){
        if let index = ShoppingListsArray.index(where: {$0.ID == newShoppinglist.ID!}){
            ShoppingListsArray.remove(at: index)
            ShoppingListsArray.append(newShoppinglist)
            self.FirebaseRequestFinished()
        } else {
            ShoppingListsArray.append(newShoppinglist)
            self.FirebaseRequestFinished()
        }
    }*/
    
    //MARK: - Delete Functions
    func DeleteShoppingListFromFirebase(listToDelete: ShoppingList) -> Void {
        shoppingListRef.child(listToDelete.ID!).removeValue { (error, dbref) in
            if error != nil{
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            NSLog("Succesfully deleted Shopping List from Firebase")
            //Remove also from local array & CoreData
            self.RemoveShoppingListLocal(listToDelete: listToDelete)
            self.ShoppingBuddyListDataReceived()
        }
    }
    private func RemoveShoppingListLocal(listToDelete: ShoppingList){
        DispatchQueue.main.async {
            if let index = ShoppingListsArray.index(where: {$0.ID == listToDelete.ID!}){
                ShoppingListsArray.remove(at: index)
                if let listID = ListID.FetchListID(userID:Auth.auth().currentUser!.uid , idToFetch: listToDelete.ID!, context: self.context){
                    ListID.DeleteListID(listID: listID.first!, context: self.context)
                    self.ShoppingBuddyListDataReceived() 
                }
            }
        }
    }
}
