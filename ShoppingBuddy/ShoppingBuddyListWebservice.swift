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
    private var itemsRef = Database.database().reference().child("listItems")
    
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
    func ShoppingBuddyStoreReceived(store: String) {
        
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil {
            
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyStoreReceived!(store: store)
            }
            
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyStoresCollectionReceived() in ShoppingList")
        }
    }
    func ShoppingBuddyImageReceived() {
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyImageReceived!()
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyImageReceived() in ShoppingList")
        }
    }
    func ShoppingBuddyNewListSaved(listID: String) {
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyNewListSaved!(listID: listID)
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyNewListSaved() in ShoppingList")
        }
    }
    func ShoppingBuddyNewListReceived(listID: String) {
        self.HideActivityIndicator()
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyNewListReceived!(listID: listID)
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyNewListReceived() in ShoppingList")
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
    func ObserveAllList() -> Void{
        
        self.ShowActivityIndicator()
        if currentUser.shoppingLists.isEmpty {
            
            self.HideActivityIndicator()
            return
            
        }
        
        for listID in currentUser.shoppingLists {
            
            ObserveSingleList(listID: listID)
            
        }
        
    }
    
    
    func ObserveSingleList(listID:String) -> Void {
        
        self.ShowActivityIndicator()
        listRef.child(listID).queryOrdered(byChild: "isSelected").observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                self.HideActivityIndicator()
                return
                
            }
            
            var newList = ShoppingList()
            newList.id = snapshot.key
            newList.name = snapshot.childSnapshot(forPath: "listName").value as? String
            newList.owneruid = snapshot.childSnapshot(forPath: "owneruid").value as? String
            newList.relatedStore = snapshot.childSnapshot(forPath: "relatedStore").value as? String
            
            if let index = ShoppingListsArray.index(where: { $0.id == listID }){
                
                ShoppingListsArray[index].id = newList.id
                ShoppingListsArray[index].name = newList.name
                ShoppingListsArray[index].owneruid = newList.owneruid
                ShoppingListsArray[index].relatedStore = newList.relatedStore
                
            } else {
                
                ShoppingListsArray.append(newList)
                
            }
            
            self.ShoppingBuddyListDataReceived()
            self.ObserveListItems(list: newList)
            
        }) { (error) in
            
            self.HideActivityIndicator()
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
    }
    
    func ObserveNewList(listID:String) -> Void {
        
        self.ShowActivityIndicator()
        listRef.child(listID).queryOrdered(byChild: "isSelected").observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                self.HideActivityIndicator()
                return
                
            }
            
            var newList = ShoppingList()
            newList.id = snapshot.key
            newList.name = snapshot.childSnapshot(forPath: "listName").value as? String
            newList.owneruid = snapshot.childSnapshot(forPath: "owneruid").value as? String
            newList.relatedStore = snapshot.childSnapshot(forPath: "relatedStore").value as? String
            
            if let index = ShoppingListsArray.index(where: { $0.id == listID }){
                
                ShoppingListsArray[index].id = newList.id
                ShoppingListsArray[index].name = newList.name
                ShoppingListsArray[index].owneruid = newList.owneruid
                ShoppingListsArray[index].relatedStore = newList.relatedStore
                self.ShoppingBuddyNewListReceived(listID: newList.id!)
                
            } else {
                
                ShoppingListsArray.append(newList)
                self.ShoppingBuddyNewListReceived(listID: newList.id!)
                
            }
            
        }) { (error) in
            
            self.HideActivityIndicator()
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
    }
    
    func ObserveListItems(list:ShoppingList) -> Void {
        
        self.ShowActivityIndicator()
        itemsRef.child(list.id!).observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                self.HideActivityIndicator()
                return
                
            }
            
            for items in snapshot.children {
                
                let item = items as! DataSnapshot
                var newItem = ShoppingListItem()
                newItem.id = item.key
                newItem.listID  = list.id
                newItem.isSelected = item.childSnapshot(forPath: "isSelected").value as? Bool
                newItem.itemName = item.childSnapshot(forPath: "itemName").value as? String
                newItem.sortNumber = item.childSnapshot(forPath: "sortNumber").value as? Int
                
                self.ObserveSingleItem(listItem: newItem)
                
            }
            
        }) { (error) in
            
            self.HideActivityIndicator()
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
    }
    
    private func ObserveSingleItem(listItem:ShoppingListItem) -> Void {
        
        self.ShowActivityIndicator()
        itemsRef.child(listItem.listID!).child(listItem.id!).observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                self.HideActivityIndicator()
                return
                
            }
            
            var newItem = ShoppingListItem()
            newItem.id = snapshot.key
            newItem.listID = listItem.listID
            newItem.isSelected = snapshot.childSnapshot(forPath: "isSelected").value as? Bool
            newItem.itemName = snapshot.childSnapshot(forPath: "itemName").value as? String
            newItem.sortNumber = snapshot.childSnapshot(forPath: "sortNumber").value as? Int
            
            if let listIndex = ShoppingListsArray.index(where: { $0.id == listItem.listID }) {
                
                if let itemIndex = ShoppingListsArray[listIndex].itemsArray.index(where: { $0.id == listItem.id }) {
                    
                    if newItem.itemName == nil {
                        self.ShoppingBuddyListDataReceived()
                        return
                    }
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].id = newItem.id
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].isSelected = newItem.isSelected
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].itemName = newItem.itemName
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].listID = newItem.listID
                    ShoppingListsArray[listIndex].itemsArray[itemIndex].sortNumber = newItem.sortNumber
                    self.ShoppingBuddyListDataReceived()
                    
                } else {
                    
                    if newItem.itemName == nil {
                        return
                    }
                    ShoppingListsArray[listIndex].itemsArray.append(newItem)
                    
                    self.ShoppingBuddyListDataReceived()
                    
                }
                
            } else {
                
                self.HideActivityIndicator()
                
            }
            
        }) { (error) in
            
            self.HideActivityIndicator()
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
    }
    
    func ObserveFriendsList(){
        
    }
    func GetStoresForGeofencing() -> Void {
        
        self.ShowActivityIndicator()
        userRef.child("shoppinglists").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                self.HideActivityIndicator()
                return
                
            }
            
            possibleRegionsPerStore = Int(snapshot.childrenCount)
            for lists in snapshot.children {
                
                guard let list = lists as? DataSnapshot else {
                    
                    self.HideActivityIndicator()
                    return
                    
                }
                
                self.listRef.child(list.key).observeSingleEvent(of: .value, with: { (listSnap) in
                    
                    let store = listSnap.childSnapshot(forPath: "relatedStore").value as? String
                    
                    if store == nil {
                        self.HideActivityIndicator()
                        return
                    }
                    
                    self.itemsRef.child(list.key).observeSingleEvent(of: .value, with: { (itemSnap) in
                        
                        if itemSnap.childrenCount == 0  { return }
                        
                        var cnt:Int = 0
                        for items in itemSnap.children {
                            
                            let item = items as! DataSnapshot
                            let isSelected = item.childSnapshot(forPath: "isSelected").value as? Bool
                            cnt = isSelected! == false ? cnt + 1 : cnt
                            
                        }
                        
                        if cnt == 0 { return }
                        self.ShoppingBuddyStoreReceived(store: store!)
                        
                    })
                    
                    
                }, withCancel: { (error) in
                    
                    self.HideActivityIndicator()
                    NSLog(error.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                    return
                    
                })
                
            }
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
            self.itemsRef.child(listToDelete.id!).removeValue()
            self.userRef.child("shoppinglists").child(listToDelete.id!).removeValue()
            
            if let index = ShoppingListsArray.index(where: { $0.id == listToDelete.id }) {
                ShoppingListsArray.remove(at: index)
            }
            
        }
    }
    
}
