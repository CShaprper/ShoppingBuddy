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
 
class ShoppingList:NSObject, IShoppingBuddyListWebService, IAlertMessageDelegate, IActivityAnimationService{
    private var ref = Database.database().reference()
    private var userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
    private var shoppingListRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("shoppinglists")
    var alertMessageDelegate: IAlertMessageDelegate?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    var shoppingBuddyListWebServiceDelegate: IShoppingBuddyListWebService?
    var id:String?
    var owner:FirebaseUser?
    var name:String?
    var relatedStore:String?
    var itemsArray:[ShoppingListItem]!
    var membersArray:[FirebaseUser]!
    
    override init() {
        super.init()
        owner = FirebaseUser()
        itemsArray = []
        membersArray = []
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
    func ShoppingBuddyNewListSaved() {
        if shoppingBuddyListWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.shoppingBuddyListWebServiceDelegate!.ShoppingBuddyNewListSaved!()
            }
        } else {
            NSLog("shoppingBuddyListWebServiceDelegate not set from calling class. ShoppingBuddyNewListSaved() in ShoppingList")
        }
    }
    
    
    //MARK: - FirebaseSave Functions
    func SaveListToFirebaseDatabase() -> Void {
        self.ShowActivityIndicator()
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { return }
            let listRef =  snapshot.ref.child("shoppinglists").childByAutoId()
            listRef.updateChildValues(["listName":self.name!, "relatedStore":self.relatedStore!], withCompletionBlock: { (error, dbRef) in
                if error != nil {
                    self.HideActivityIndicator()
                    NSLog(error!.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error!.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                    return
                }
                NSLog("Successfully saved List to Firebase Listname: %@ related Store: %@",self.name!, self.relatedStore!)
                let owner = FirebaseUser()
                owner.id = snapshot.key
                owner.email = snapshot.childSnapshot(forPath: "email").value as? String
                owner.nickname = snapshot.childSnapshot(forPath:"nickname").value as? String
                owner.profileImageURL = snapshot.childSnapshot(forPath: "profileImageURL").value as? String
                owner.fcmToken = snapshot.childSnapshot(forPath: "fcmToken").value as? String
                
                if owner.id == nil || owner.email == nil || owner.nickname == nil || owner.profileImageURL == nil || owner.fcmToken == nil {
                    self.HideActivityIndicator()
                    return
                }
                
                dbRef.child("owner").child(owner.id!).updateChildValues(["email":owner.email!, "nickname":owner.nickname!, "profileImageURL":owner.profileImageURL!, "fcmToken":owner.fcmToken!], withCompletionBlock: { (error, dbRef) in
                    if error != nil {
                        self.HideActivityIndicator()
                        NSLog(error!.localizedDescription)
                        let title = String.OnlineFetchRequestError
                        let message = error!.localizedDescription
                        self.ShowAlertMessage(title: title, message: message)
                        return
                    }
                    NSLog("Successfully saved owner of List to Firebase Listname: %@ related Store: %@",self.name!, self.relatedStore!)
                    self.HideActivityIndicator()
                    
                    self.ObserveSingleShoppingList(owner: owner, listID: listRef.key)
                })
            })
        }) { (error) in
            self.HideActivityIndicator()
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
        }
    }
    
    //MARK: - Firebase Observe Functions
    func ObserveSingleShoppingList(owner:FirebaseUser, listID:String) -> Void {
        self.ShowActivityIndicator()
         shoppingListRef.child(listID).observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull { return }
            
             let newShoppingList = ShoppingList()
            newShoppingList.id = snapshot.key
            newShoppingList.name = snapshot.childSnapshot(forPath: "listName").value as? String
            newShoppingList.relatedStore = snapshot.childSnapshot(forPath: "relatedStore").value as? String
            newShoppingList.owner = owner
            
            var newItems = [ShoppingListItem]()
            for items in snapshot.childSnapshot(forPath: "items").children{
                guard let item = items as? DataSnapshot else {
                    return
                }
                let newItem = ShoppingListItem()
                newItem.id = item.key
                newItem.isSelected = item.childSnapshot(forPath: "isSelected").value as? Bool
                newItem.itemName = item.childSnapshot(forPath: "itemName").value as? String
                newItem.sortNumber = item.childSnapshot(forPath: "sortNumber").value as? Int
                newItems.append(newItem)
            }
            newShoppingList.itemsArray  = newItems
            
            var newMembers = [FirebaseUser]()
            for members in snapshot.childSnapshot(forPath: "members").children{
                guard let member = members as? DataSnapshot else {
                    return
                }
                let newMember = FirebaseUser()
                newMember.id = member.key
                newMember.email = member.childSnapshot(forPath: "email").value as? String
                newMember.nickname = member.childSnapshot(forPath: "nickname").value as? String
                newMember.profileImageURL = member.childSnapshot(forPath: "profileImageURL").value as? String
                newMember.fcmToken = member.childSnapshot(forPath: "fcmToken").value as? String
                newMember.userProfileImageFromURL()
                newMembers.append(newMember)
            }
            newShoppingList.membersArray = newMembers
            
            ShoppingListsArray.append(newShoppingList)
            self.HideActivityIndicator()
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
    
       func ObserveShoppingList() -> Void{
        self.ShowActivityIndicator()
        userRef.observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull{
                self.HideActivityIndicator()
                return
            }
            
            //Fill UserData from Snapshot
            let fbUser = FirebaseUser()
            fbUser.id = snapshot.key
            fbUser.email = snapshot.childSnapshot(forPath: "email").value as? String
            fbUser.nickname = snapshot.childSnapshot(forPath: "nickName").value as? String
            fbUser.profileImageURL = snapshot.childSnapshot(forPath: "profileImageURL").value as? String
            fbUser.fcmToken = snapshot.childSnapshot(forPath: "fcmToken").value as? String
            
            //Fill Listdata from ListSnapshot
            let listSnap = snapshot.childSnapshot(forPath: "shoppinglists")
            var shoppingListArray = [ShoppingList]()
            for lists in listSnap.children {
                let list = lists as! DataSnapshot
                let shoppingList = ShoppingList()
                shoppingList.owner = fbUser  //Set User Data
                shoppingList.id = list.key
                shoppingList.name = list.childSnapshot(forPath: "listName").value as? String
                shoppingList.relatedStore = list.childSnapshot(forPath: "relatedStore").value as? String
                
                let itemsRef = list.childSnapshot(forPath: "items")
                var itemsArray = [ShoppingListItem]()
                for items in itemsRef.children {
                    let item = items as! DataSnapshot
                    let listItem = ShoppingListItem()
                    listItem.id = item.key
                    listItem.itemName = item.childSnapshot(forPath: "itemName").value as? String
                    listItem.isSelected = item.childSnapshot(forPath:  "isSelected").value as? Bool
                    itemsArray.append(listItem)
                }
                shoppingList.itemsArray = itemsArray
                
                let membersRef = list.childSnapshot(forPath: "members")
                var membersArray = [FirebaseUser]()
                for members in membersRef.children {
                    let member = members as! DataSnapshot
                    let fbUser = FirebaseUser()
                    fbUser.id = member.key
                    fbUser.email = snapshot.childSnapshot(forPath: "email").value as? String
                    fbUser.nickname = snapshot.childSnapshot(forPath: "nickName").value as? String
                    fbUser.profileImageURL = snapshot.childSnapshot(forPath: "profileImageURL").value as? String
                    fbUser.fcmToken = snapshot.childSnapshot(forPath: "fcmToken").value as? String
                    fbUser.sharingStatus = snapshot.childSnapshot(forPath: "sharingStatus").value as? String
                    membersArray.append(fbUser)
                }
                shoppingList.membersArray = membersArray
                shoppingListArray.append(shoppingList)
            }
            self.HideActivityIndicator()
            ShoppingListsArray = shoppingListArray
            self.ShoppingBuddyListDataReceived()
        })
    }
    func ObserveFriendsList(){
      
    }
    func GetStoresForGeofencing(){
        self.ShowActivityIndicator()
        shoppingListRef.observeSingleEvent(of: .value, with: { (snapshot) in
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
                                if isSelected.value as! String == "false" {
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
        shoppingListRef.child(listToDelete.id!).removeValue { (error, dbref) in
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
