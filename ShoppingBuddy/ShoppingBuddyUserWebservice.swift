//
//  ShoppingBuddyUserWebservice.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

class ShoppingBuddyUserWebservice:NSObject, URLSessionDelegate {
    var alertMessageDelegate: IAlertMessageDelegate?
    
    internal var ref = Database.database().reference()
    internal var userRef = Database.database().reference().child("users")
    
    override init() {
        super.init()
    }
    
    //CurrentUser Download
    func GetCurrentUser(){

        userRef.child(Auth.auth().currentUser!.uid).observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull { return }
            
            currentUser!.id = snapshot.key
            currentUser!.email = snapshot.childSnapshot(forPath: "email").value as? String
            currentUser!.nickname = snapshot.childSnapshot(forPath: "nickname").value as? String
            currentUser!.fcmToken = snapshot.childSnapshot(forPath: "fcmToken").value as? String
            currentUser!.profileImageURL = snapshot.childSnapshot(forPath: "profileImageURL").value as? String
            currentUser!.isFullVersionUser = snapshot.childSnapshot(forPath: "isFullVersionUser").value as? Bool
            currentUser!.userProfileImageFromURL(dlType: .DownloadForCurrentUser)
                
            if let index = allUsers.index(where: { $0.id == currentUser!.id }){
                
                allUsers[index] = currentUser!
                
            } else {
                
                allUsers.append(currentUser!)
                
            }
                NotificationCenter.default.post(name: .CurrentUserReceived, object: nil, userInfo: nil)
            
            
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            
        }
    }
    
    func ObserveUser(userID: String, dlType:eUserDLType){
        
        userRef.child(userID).observeSingleEvent(of: .value, with: { (userSnap) in
            
            if userSnap.value is NSNull { return }
            
            let newUser = ShoppingBuddyUser()
            newUser.id = userSnap.key
            newUser.email = userSnap.childSnapshot(forPath: "email").value as? String
            newUser.nickname = userSnap.childSnapshot(forPath: "nickname").value as? String
            newUser.fcmToken = userSnap.childSnapshot(forPath: "fcmToken").value as? String
            newUser.isFullVersionUser = userSnap.childSnapshot(forPath: "isFullVersionUser").value as? Bool
            newUser.profileImageURL = userSnap.childSnapshot(forPath: "profileImageURL").value as? String
            newUser.userProfileImageFromURL(dlType: dlType)
            
            if let index = allUsers.index(where: { $0.id == newUser.id }){
                
                allUsers[index] = newUser
                
            } else {
               
                allUsers.append(newUser)
                
            }            
            
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            
        }
    }
    
    
    
    //MARK User Login
    func LoginFirebaseUser(email: String, password: String) {
        
        //self.isCalled = false
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil{
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            } else {
                
                UserDefaults.standard.set(user!.uid, forKey: eUserDefaultKey.CurrentUserID.rawValue)
                NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyUserLoggedIn, object: nil, userInfo: nil)
                NSLog("Succesfully loged user in to Firebase")
                
            }
        }
        
    }
    //MARK: User Loout
    func LogFirebaseUserOut() {
        
        let auth = Auth.auth()
        do{
            try  auth.signOut()
            UserDefaults.standard.set("false", forKey: eUserDefaultKey.CurrentUserID.rawValue)
            NSLog("Succesfully logged out")
        }
        catch let error as NSError{
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
        }
        
    }
    
    //MARK: - Change FullVersionUser
    func ChangeFullVersionUserStatus(status: Bool) -> Void {
        
        ref.child("users").child(Auth.auth().currentUser!.uid).child("isFullVersionUser").setValue(status)       
        
    }
    
    //MARK:- Firebase Auth Section
    func CreateNewFirebaseUser(profileImage:UIImage, nickname: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print(error!.localizedDescription)
                  OperationQueue.main.addOperation {
                    let title = ""
                    let message = ""
                    self.ShowAlertMessage(title: title, message: message)
                }
                return
            } else {
                
                let sbUser = ShoppingBuddyUser()
                sbUser.profileImage = profileImage
                sbUser.nickname = nickname
                sbUser.email = email
                
                self.SaveNewUserWithUIDtoFirebase(shoppingBuddyUser: sbUser, user: user)
                NSLog("Succesfully created new Firebase User")
            }
        })
    }
    
    func SetNewFcmToken(token:String){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        ref.child("users").child(uid).child("fcmToken").setValue(token) { (error, dbRef) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            NSLog("Refreshed User fcmToken")
        }
    }
    
    func ResetUserPassword(email:String){
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            NSLog("Succesfully sent password reset mail")
            return
            
        }
        
    }
    
    //MARK: - FirebaseWebService methods
    func AddUserStateListener() -> Void {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if user != nil {
                
                NSLog("State listener detected user loged in")
                UserDefaults.standard.set(user!.uid, forKey: eUserDefaultKey.CurrentUserID.rawValue)
                NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyUserLoggedIn, object: nil, userInfo: nil)
                
            } else {
                
                UserDefaults.standard.set("false", forKey: eUserDefaultKey.CurrentUserID.rawValue)
                NSLog("State listener detected user loged out")
                
                NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyUserLoggedOut, object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name.SegueToLogInController, object: nil, userInfo: nil)
                
            }
        }
    }
    
    func changeUserProfileImage(forUserID:String, image:UIImage) -> Void {
        if let uploadData = image.mediumQualityJPEGNSData {
            let imagesRef = Storage.storage().reference().child(forUserID)
            let _ = imagesRef.putData(uploadData as Data, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    NSLog(error!.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error!.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                    return
                    
                }
                
                
                if let imgURL =  metadata?.downloadURL()?.absoluteString {

                    self.ref.child("users").child(forUserID).child("profileImageURL").setValue(imgURL, withCompletionBlock: { (err, ref) in
                        
                        if err != nil {
                            
                            NSLog(err!.localizedDescription)
                            let title = String.OnlineFetchRequestError
                            let message = err!.localizedDescription
                            self.ShowAlertMessage(title: title, message: message)
                            return
                            
                        }
                        
                        NSLog("Succesfully saved user to Firebase")
                        if let index = allUsers.index(where: { $0.id == forUserID}) {
                            
                            allUsers[index].profileImage = image
                            allUsers[index].profileImageURL = imgURL
                            
                        }
                        NotificationCenter.default.post(name: Notification.Name.CurrentUserCreated, object: nil, userInfo: nil)
                        
                    })
                }
                
                print("Successfully uploaded prodcut image!")
                
            }) // end: let _ = imagesRef.putData
        }//end: if let let uploadData
    }
    
    //MARK: - Helpers
    private func SaveNewUserWithUIDtoFirebase(shoppingBuddyUser:ShoppingBuddyUser, user: User?) -> Void {
        
        //Image Upload
        let imagesRef = Storage.storage().reference().child(user!.uid)
        if shoppingBuddyUser.profileImage != nil {
            
            if let uploadData = shoppingBuddyUser.profileImage!.mediumQualityJPEGNSData {
                
                let _ = imagesRef.putData(uploadData as Data, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        
                        NSLog(error!.localizedDescription)
                        let title = String.OnlineFetchRequestError
                        let message = error!.localizedDescription
                        self.ShowAlertMessage(title: title, message: message)
                        return
                        
                    }
                    
                    
                    if let imgURL =  metadata?.downloadURL()?.absoluteString {
                        
                        let token:String = Messaging.messaging().fcmToken!
                        let values = (["nickname": shoppingBuddyUser.nickname!, "email": user!.email!, "fcmToken":token, "profileImageURL":imgURL, "isFullVersionUser":false] as [String : Any])
                        self.ref.child("users").child(user!.uid).updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                            
                            if err != nil {
                                
                                NSLog(err!.localizedDescription)
                                let title = String.OnlineFetchRequestError
                                let message = err!.localizedDescription
                                self.ShowAlertMessage(title: title, message: message)
                                return
                                
                            }
                            
                                NSLog("Succesfully saved user to Firebase")
                                NotificationCenter.default.post(name: Notification.Name.CurrentUserCreated, object: nil, userInfo: nil)
                                
                             
                        })
                    }
                    
                    print("Successfully uploaded prodcut image!")
                    
                }) // end: let _ = imagesRef.putData
            }//end: if let let uploadData
        }
    }
}
extension ShoppingBuddyUserWebservice: IAlertMessageDelegate {
    
    //MARK: IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        
        if alertMessageDelegate != nil {
            
            OperationQueue.main.addOperation {
                self.alertMessageDelegate?.ShowAlertMessage(title: title, message: message)
            }
            
        } else {
            
            NSLog("AlertMessageDelegate not set from calling class in ShoppingListItem")
            
        }
    }
    
}
