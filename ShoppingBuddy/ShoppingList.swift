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

class ShoppingList: IShoppingBuddyListWebService, IAlertMessageDelegate, IActivityAnimationService{
    private var ref = Database.database().reference()
    private var shoppingListRef = Database.database().reference().child("shoppinglists").child(Auth.auth().currentUser!.uid)
    var alertMessageDelegate: IAlertMessageDelegate?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    var shoppingBuddyListWebServiceDelegate: IShoppingBuddyListWebService?
    var ID:String?
    var OwnerID:String?
    var Name:String?
    var OwnerProfileImageURL:String?
    var OwnerProfileImage:UIImage?
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
    
    
    //MARK: - FirebaseSave Functions
    func SaveListToFirebaseDatabase() -> Void {
        self.ShowActivityIndicator()
        guard let uid = Auth.auth().currentUser?.uid else{
            self.HideActivityIndicator()
            return
        }
        let listID =  shoppingListRef.childByAutoId()
        listID.updateChildValues(["listID":listID.key, "ownerID":uid, "name":self.Name!, "relatedStore":self.RelatedStore!], withCompletionBlock: { (error, dbref) in
            if error != nil{
                self.HideActivityIndicator()
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            listID.child("members").child(uid).setValue("owner")
            self.ref.child("users").child(uid).child("profileImageURL").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.value == nil { return }
                listID.child("ownerProfileImageURL").setValue(snapshot.value as! String)
                NSLog("Succesfully saved Shopping List to Firebase")
                self.ObserveShoppingList()
            })
        })
    }
    func DownloadImage(url: String){
        if let index = ProfileImageCache.index(where: { $0.ProfileImageURL == url }) {
            for list in ShoppingListsArray{
                if list.OwnerProfileImageURL! == ProfileImageCache[index].ProfileImageURL!{
                    NSLog("ProfileImage set from ImageCache!")
                    list.OwnerProfileImage = ProfileImageCache[index].UserProfileImage!
                    break
                }
            }
        } else {
            loadImageUsingCacheWithURLString(urlString: url)           
        }
    }
   private func loadImageUsingCacheWithURLString(urlString: String) -> Void {
        let url = URL(string: urlString)!
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            DispatchQueue.main.async {
                if let downloadImage = UIImage(data: data!){
                    let cacheImage = CacheUserProfileImage()
                    cacheImage.UserProfileImage = downloadImage
                    cacheImage.ProfileImageURL = urlString
                    ProfileImageCache.append(cacheImage)
                    NSLog("Added UserProfileImage to imageChache!")
                    for list in ShoppingListsArray{
                        if list.OwnerProfileImageURL == urlString{
                            list.OwnerProfileImage = downloadImage
                            print("UserProfileImage set from Download!")
                        }
                    }
                    self.ShoppingBuddyImageReceived()
                }
            }
        }
        task.resume()
    } 
    
    //MARK: - Firebase Observe Functions
    func GetStoresForGeofencing(){
        self.ShowActivityIndicator()
        shoppingListRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value == nil { return }
            var newStoresArray:[String] = []
            for listSnap in snapshot.children {
                let list = listSnap as! DataSnapshot
                let storeSnap = list.childSnapshot(forPath: "relatedStore")
                if storeSnap.value == nil { return }
                newStoresArray.append(storeSnap.value as! String)
                self.ShoppingBuddyStoresCollectionReceived()
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
                            let storeSnap = list.childSnapshot(forPath: "relatedStore")
                            newStoresArray.append(storeSnap.value as! String)
                        }
                        StoresArray = newStoresArray
                        self.ShoppingBuddyStoresCollectionReceived()
                    })
                }
            })
        })
    }
    func ObserveShoppingList() -> Void{
        shoppingListRef.observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull{ return }
            var newShoppingListArray:[ShoppingList] = []
            for listSnap in snapshot.children {
                let list = listSnap as! DataSnapshot
                //Get ListData
                let newShoppinglist = ShoppingList()
                if let dict = list.value as? NSDictionary{
                    newShoppinglist.ID = dict["listID"] as? String ?? ""
                    newShoppinglist.OwnerID = dict["ownerID"] as? String ?? ""
                    newShoppinglist.Name = dict["name"] as? String ?? ""
                    newShoppinglist.RelatedStore = dict["relatedStore"] as? String ?? ""
                    newShoppinglist.OwnerProfileImageURL = dict["ownerProfileImageURL"] as? String ?? ""
                    
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
            self.ShoppingBuddyListDataReceived()
            self.ObserveFriendsList()
        })
    }
    func ObserveFriendsList(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref.child("users").child(uid).child("friends").observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull{ return }
            for friends in snapshot.children{
                let friend = friends as! DataSnapshot
                var status:String = ""
                status = friend.value as! String
                //Remove all previous data with friend.key from ShoppingListsArray
                ShoppingListsArray = ShoppingListsArray.filter({$0.OwnerID! != friend.key})
                if status.isEmpty || status == "pending" { return }
                
                self.ref.child("shoppinglists").child(friend.key).observe(.value, with: { (snapshot) in
                    if snapshot.value is NSNull{ return }
                    var newShoppingListArray:[ShoppingList] = []
                    for listSnap in snapshot.children {
                        let list = listSnap as! DataSnapshot
                        //Get ListData
                        let newShoppinglist = ShoppingList()
                        if let dict = list.value as? NSDictionary{
                            newShoppinglist.ID = dict["listID"] as? String ?? ""
                            newShoppinglist.OwnerID = dict["ownerID"] as? String ?? ""
                            newShoppinglist.Name = dict["name"] as? String ?? ""
                            newShoppinglist.RelatedStore = dict["relatedStore"] as? String ?? ""
                            newShoppinglist.OwnerProfileImageURL = dict["ownerProfileImageURL"] as? String ?? ""
                            newShoppinglist.OwnerProfileImageURL  = dict["ownerProfileImageURL"] as? String ?? ""
                            
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
    
    //MARK: - Delete Functions
    func DeleteShoppingListFromFirebase(listToDelete: ShoppingList) -> Void {
        self.ShowActivityIndicator()
        shoppingListRef.child(listToDelete.ID!).removeValue { (error, dbref) in
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
