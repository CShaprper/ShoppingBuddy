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
    func ShoppingBuddyListDataReceived() {
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyListDataReceived!()
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyListDataReceived() in ShoppingList")
        }
    }
    func ShoppingBuddyStoresCollectionReceived() {
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyStoresCollectionReceived!()
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyStoresCollectionReceived() in ShoppingList")
        }
    }
    func ShoppingBuddyImageReceived() {
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyImageReceived!()
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyImageReceived() in ShoppingList")
        }
    }
    func ShoppingBuddyNewListSaved(listID: String) {
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyNewListSaved!(listID: listID)
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyNewListSaved() in ShoppingList")
        }
    }
    //Share Functions
    func SendFriendSharingInvitation(friendsEmail:String) -> Void {
        self.ShowActivityIndicator()
        Auth.auth().fetchProviders(forEmail: friendsEmail) { (snapshot, error) in
            if error != nil {
                NSLog(error!.localizedDescription)
                self.HideActivityIndicator()
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            if snapshot != nil {
                
            } else {
                self.HideActivityIndicator()
                let title = String.OnlineFetchRequestError
                let message = "\(friendsEmail) is not a registered Shopping Buddy address!"
                self.ShowAlertMessage(title: title, message: message)
            }
        }
    }
    func SearchUserByEmail(listID:String, email:String) -> Void {
        self.ShowActivityIndicator()
        Auth.auth().fetchProviders(forEmail: email) { (snapshot, error) in
            if error != nil {
                NSLog(error!.localizedDescription)
                self.HideActivityIndicator()
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            NSLog("Refreshed User fcmToken")
            if snapshot != nil {
                
            } else {
                let title = String.OnlineFetchRequestError
                let message = "\(email) is not a registered address!"
                self.ShowAlertMessage(title: title, message: message)
            }
        }
    }
    
    
    //MARK: - FirebaseSave Functions
    func SaveListToFirebaseDatabase(currentUser:ShoppingBuddyUser, listName:String, relatedStore:String) -> Void {
        self.ShowActivityIndicator()
        let newListRef = listRef.childByAutoId()
        newListRef.updateChildValues(["listName":listName, "relatedStore":relatedStore, "owneruid":currentUser.id!], withCompletionBlock: { (error, dbRef) in
            
            if error != nil {
                self.HideActivityIndicator()
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            
            NSLog("Successfully saved List to Firebase Listname: %@ related Store: %@",listName, relatedStore)
            self.userRef.child("shoppinglists").updateChildValues([newListRef.key:"owner"], withCompletionBlock: { (error, dbRef) in
                
                if error != nil {
                    self.HideActivityIndicator()
                    NSLog(error!.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error!.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                    return
                }
                NSLog("Successfully Updated ListID in User Node: %@ related Store: %@",listName, relatedStore)
                self.HideActivityIndicator()
                self.ShoppingBuddyNewListSaved(listID: newListRef.key)
            })
        })
    }
    
    //MARK: - Firebase Observe Functions
    func ObserveSingleList(listID:String) -> Void {
        self.ShowActivityIndicator()
        listRef.child(listID).observe(.value, with: { (snapshot) in
            
            var newList = ShoppingList()
            newList.id = snapshot.key
            newList.name = snapshot.childSnapshot(forPath: "listName").value as? String
            newList.owneruid = snapshot.childSnapshot(forPath: "owneruid").value as? String
            newList.relatedStore = snapshot.childSnapshot(forPath: "relatedStore").value as? String
            
            var newItems = [ShoppingListItem]()
            for items in snapshot.childSnapshot(forPath: "items").children {
                let item = items as! DataSnapshot
                let newItem = ShoppingListItem()
                newItem.id = item.key
                newItem.isSelected = item.childSnapshot(forPath: "isSelected").value as? Bool
                newItem.itemName = item.childSnapshot(forPath: "itemName").value as? String
                newItem.sortNumber = item.childSnapshot(forPath: "sortNumber").value as? Int
                newItems.append(newItem)
            }
            newList.itemsArray = newItems
            
            if let index = ShoppingListsArray.index(where: { $0.id == listID }){
                ShoppingListsArray.remove(at: index)
            }
            ShoppingListsArray.append(newList)
            
            self.ShoppingBuddyListDataReceived()
            
        }) { (error) in
            
            self.HideActivityIndicator()
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
    }
    
    func ObserveAllList() -> Void{
        self.ShowActivityIndicator()
        if currentUser.shoppingLists.isEmpty { return }
        
        for listID in currentUser.shoppingLists {
            ObserveSingleList(listID: listID)
        }
    }
    func ObserveFriendsList(){
        
    }
    func GetStoresForGeofencing(){
        self.ShowActivityIndicator()
        listRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value == nil { return }
            var newStoresArray:[String] = []
            for listSnap in snapshot.children {
                let list = listSnap as! DataSnapshot
                let items = list.childSnapshot(forPath: "items")
                var hasOpenElements:Bool = false
                for item in items.children{
                    let currItem = item as! DataSnapshot
                    let isSelected = currItem.childSnapshot(forPath: "isSelected")
                    if isSelected.value as! Bool == false {
                        hasOpenElements = true
                        break
                    }
                }
                if hasOpenElements {
                    let storeSnap = list.childSnapshot(forPath: "relatedStore")
                    if storeSnap.value == nil { return }
                    newStoresArray.append(storeSnap.value as! String)
                    self.ShoppingBuddyStoresCollectionReceived()
                }
            }
            StoresArray = newStoresArray
            //Get friends stores
            guard let uid = Auth.auth().currentUser?.uid else{
                self.HideActivityIndicator()
                return
            }
            //TODO: overwork
            self.ref.child("users").child(uid).child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.value is NSNull{ return }
                for friendSnap in snapshot.children {
                    let friend = friendSnap as! DataSnapshot
                    var status:String = ""
                    status = friend.value as! String
                    if status.isEmpty || status == "pending" { return }
                    self.ref.child("shoppinglists").child(friend.key).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.value is NSNull{ return }
                        for listSnap in snapshot.children{
                            let list = listSnap as! DataSnapshot
                            let items = list.childSnapshot(forPath: "items")
                            var hasOpenElements:Bool = false
                            for item in items.children{
                                let currItem = item as! DataSnapshot
                                let isSelected = currItem.childSnapshot(forPath: "isSelected")
                                if isSelected.value as! Bool == false {
                                    hasOpenElements = true
                                    break
                                }
                            }
                            if hasOpenElements {
                                let storeSnap = list.childSnapshot(forPath: "relatedStore")
                                newStoresArray.append(storeSnap.value as! String)
                            }
                        }
                        StoresArray = newStoresArray
                        self.ShoppingBuddyStoresCollectionReceived()
                    })
                }
            })
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
            self.ShoppingBuddyListDataReceived()
        }
    }
    
}
