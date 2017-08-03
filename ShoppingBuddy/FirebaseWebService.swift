//
//  FirebaseWebService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 23.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class FirebaseWebService: IFirebaseWebService {
    //MARK: - Member
    var alertMessageDelegate: IAlertMessageDelegate?
    internal let firebaseURL:String = "https://shoppingbuddy-1ef51.firebaseio.com/"
    private var ref:DatabaseReference!
    private var isCalled:Bool = false
    private var isLogoutCalled:Bool = false
    var firebaseWebServiceDelegate:IFirebaseWebService?
    var alertTitle = ""
    var alertMessage = ""
    
    //Constructor
    init() {
        ref = Database.database().reference(fromURL: firebaseURL)
    }
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestFinished() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async { self.firebaseWebServiceDelegate!.FirebaseRequestFinished!() }}
        else { print("IFirebaseWebService delegate for FirebaseRequestFinished not set from calling class") }
    }
    func FirebaseRequestStarted() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async { self.firebaseWebServiceDelegate!.FirebaseRequestStarted!() }}
        else { print("IFirebaseWebService delegate for FirebaseRequestStarted not set from calling class") }
    }
    func FirebaseUserLoggedIn() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async { self.firebaseWebServiceDelegate!.FirebaseUserLoggedIn!() }}
        else { print("IFirebaseWebService delegate for alert not set from calling class") }
    }
    func FirebaseUserLoggedOut() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async { self.firebaseWebServiceDelegate!.FirebaseUserLoggedOut!() }}
        else { print("IFirebaseWebService delegate for alert not set from calling class") }
    }
    func ReloadItems() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async { self.firebaseWebServiceDelegate!.ReloadItems!() }}
        else { print("IFirebaseWebService delegate for alert not set from calling class") }
    }
    func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil{
            DispatchQueue.main.async {
                self.alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
            }
        } else{
            print("AlertMessageDelegate not set from calling class in FirebaseWebService")
        }
    }
    
    //MARK: - FirebaseWebService methods
    func AddUserStateListener() -> Void {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil{
                print("State listener detected user loged in")
                self.FirebaseUserLoggedIn()
            } else {
                print("State listener detected user loged out")
                self.isLogoutCalled = true
                NotificationCenter.default.post(name: Notification.Name.SegueToLogInController, object: nil, userInfo: nil)
            }
        }
    }
    
    //MARK:- Firebase Auth Section
    func CreateNewFirebaseUser(nickname: String, email: String, password: String) {
        self.isCalled = false
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    self.FirebaseRequestFinished()
                    let title = ""
                    let message = ""
                    self.ShowAlertMessage(title: title, message: message)
                }
                return
            } else {
                self.SaveNewUserWithUIDtoFirebase(nickname: nickname, user: user, firebaseURL: self.firebaseURL)
                self.FirebaseRequestFinished()
                print("Succesfully created new Firebase User")
            }
        })
    }
    func LoginFirebaseUser(email: String, password: String) {
        self.isCalled = false
        self.FirebaseRequestStarted()
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    self.FirebaseRequestFinished()
                    let title = ""
                    let message = ""
                    self.ShowAlertMessage(title: title, message: message)
                }
                return
            } else {
                self.FirebaseRequestFinished()
                print("Succesfully loged user in to Firebase")
            }
        }
    }
    func LogUserOut() {
        let auth = Auth.auth()
        do{
            try  auth.signOut()
            self.FirebaseRequestFinished()
            print("Succesfully logged out")
        }
        catch let error as NSError{
            print(error.localizedDescription)
            self.FirebaseRequestFinished()
            let title = ""
            let message = ""
            self.ShowAlertMessage(title: title, message: message)
        }
    }
    func ResetUserPassword(email:String){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                print(error!.localizedDescription)
                self.FirebaseRequestFinished()
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            print("Succesfully sent password reset mail")
            return
        }
        
    }
    
    
    //MARK: - Firebase Read Functions
    func ReadFirebaseShoppingListsSection() -> Void {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        var newLists = [ShoppingList]()
        var newItems = [ShoppingListItem]()
        ref.child("shopping-lists").child(uid).observe(.childAdded, with: { (snapshot) in
            if snapshot.value is NSNull{ return }
            print(snapshot)
            let value = snapshot.value as? NSDictionary
            var list = ShoppingList()
            list.ID = value?["id"] as? String ?? ""
            list.Name = value?["name"] as? String ?? ""
            list.RelatedStore = value?["relatedStore"] as? String ?? ""
            // newLists.append(list)
            
            let items = snapshot.childSnapshot(forPath: "items")
            if items.value is NSNull{ return }
            for item in items.children{
                let item2 = item as! DataSnapshot
                if let dict = item2.value as? [String: AnyObject]{
                    var listItem:ShoppingListItem = ShoppingListItem()
                    listItem.ID = dict["id"] as? String != nil ? (dict["id"] as? String)! : ""
                    listItem.ItemName = dict["itemName"] as? String != nil ? (dict["itemName"] as? String)! : ""
                    listItem.isSelected = dict["isSelected"] as? String != nil ? (dict["isSelected"] as? String)! : ""
                    listItem.ShoppingListID = list.ID!
                    newItems.append(listItem)
                }
            }
            list.ItemsArray = newItems.filter({$0.ShoppingListID == list.ID!}).sorted(by: {return $0.isSelected! < $1.isSelected!})
            newLists.append(list)
            ShoppingListsArray = newLists
            self.FirebaseRequestFinished()
        })
    } 
    func ReadSingleShoppingList(listID:String) -> Void{
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref.child("shopping-lists").child(uid).child(listID).child("items").observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull{ return }
            print(snapshot)
            if let dict = snapshot.value as? [String: AnyObject]{
                var listItem = ShoppingListItem()
                listItem.ID = dict["id"] as? String != nil ? (dict["id"] as? String)! : ""
                listItem.ItemName = dict["itemName"] as? String != nil ? (dict["itemName"] as? String)! : ""
                listItem.isSelected = dict["isSelected"] as? String != nil ? (dict["isSelected"] as? String)! : ""
                listItem.ShoppingListID = listID
                if let index = ShoppingListsArray.index(where: {$0.ID == listItem.ShoppingListID}){
                    ShoppingListsArray[index].ItemsArray!.append(listItem)
                }
            }
            self.FirebaseRequestFinished()
        })
    }
    
    //MARK: - Edit Functions
    func EditIsSelectedOnShoppingListItem(shoppingListItem: ShoppingListItem) -> Void{
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref.child("shopping-lists").child(uid).child(shoppingListItem.ShoppingListID!).child("items").child(shoppingListItem.ID!).child("isSelected").setValue(shoppingListItem.isSelected!)
    }
    
    
    //MARK: - Firebase Save Functions
    func SaveStoreToFirebaseDatabase(storeName: String) -> Void {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let storeID =  ref.child("stores").child(uid).childByAutoId()
        print(storeID.key)
        storeID.updateChildValues(["store":storeName, "id":storeID.key], withCompletionBlock: { (error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            self.FirebaseRequestFinished()
            print("Succesfully saved Store to Firebase")
        })
    }
    func SaveListToFirebaseDatabase(listName:String, relatedStore:String) -> Void {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let listID =  ref.child("shopping-lists").child(uid).childByAutoId()
        listID.updateChildValues(["id":listID.key, "name":listName, "relatedStore":relatedStore], withCompletionBlock: { (error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            self.FirebaseRequestFinished()
            print("Succesfully saved Shopping List to Firebase")
        })
    }
    func SaveListItemToFirebaseDatabase(shoppingListID:String, itemName:String) -> Void {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let itemID =  ref.child("shopping-lists").child(uid).child(shoppingListID).child("items").childByAutoId()
        itemID.updateChildValues(["id":itemID.key, "itemName":itemName, "isSelected":"false", "shoppingListID":shoppingListID], withCompletionBlock: {(error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            self.FirebaseRequestFinished()
            self.ReadFirebaseShoppingListsSection()
            print("Succesfully saved ShoppingListItem to Firebase")
        })
    }
    
    
    //MARK: - Firebase Delete Functions
    func DeleteStoreFromFirebase(idToDelete: String) -> Void {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let storeRef = ref.child("stores").child(uid)
        storeRef.child(idToDelete).removeValue { (error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            print("Succesfully deleted Store \(dbref.key) from Firebase")
            self.FirebaseRequestFinished()
        }
    }
    func DeleteShoppingListItemFromFirebase(itemToDelete: ShoppingListItem){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let itemRef = ref.child("shopping-lists").child(uid).child(itemToDelete.ShoppingListID!).child("items").child(itemToDelete.ID!)
        itemRef.removeValue { (error, dbref) in
            if error != nil{
                self.FirebaseRequestFinished()
                print(error!.localizedDescription)
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            print("Succesfully deleted item of shopping list from Firebase")
            self.FirebaseRequestFinished()
        }

    }
    
    //MARK: - Helpers
    private func SaveNewUserWithUIDtoFirebase(nickname:String, user: User?, firebaseURL: String){
        DispatchQueue.main.async {
            guard let uid = user?.uid else{
                return
            }
            let token:[String:AnyObject] = [Messaging.messaging().fcmToken!:Messaging.messaging().fcmToken as AnyObject]
            print(token)
            let usersReference = self.ref.child("users").child(uid)
            let values = (["nickname": nickname, "email": user!.email!, "fcmToken":token] as [String : Any])
            usersReference.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                if err != nil{
                    self.FirebaseRequestFinished()
                    print(err!.localizedDescription)
                    return
                } else {
                    self.FirebaseRequestFinished()
                    print("Succesfully saved user to Firebase")
                }
            })
        }
    }
    
}
