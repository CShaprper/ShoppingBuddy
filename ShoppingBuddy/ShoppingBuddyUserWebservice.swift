//
//  ShoppingBuddyUserWebservice.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

class ShoppingBuddyUserWebservice:NSObject, IAlertMessageDelegate, IActivityAnimationService, URLSessionDelegate {
    var activityAnimationServiceDelegate:IActivityAnimationService?
    var alertMessageDelegate: IAlertMessageDelegate?
    
    private var ref = Database.database().reference()
    private var userRef = Database.database().reference().child("users")
    
    override init() {
        super.init()
    }
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            DispatchQueue.main.async {
                self.activityAnimationServiceDelegate!.ShowActivityIndicator!()
            }
        }
    }
    func HideActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            DispatchQueue.main.async {
                self.activityAnimationServiceDelegate!.HideActivityIndicator!()
            }
        }
    }
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        HideActivityIndicator()
        if alertMessageDelegate != nil {
            DispatchQueue.main.async {
                self.alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
            }
        }
    }
    
    //CurrentUser Download
    func GetCurrentUser(){
        userRef.child(Auth.auth().currentUser!.uid).observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull { return }
            
            currentUser!.id = snapshot.key
            currentUser!.email = snapshot.childSnapshot(forPath: "email").value as? String
            currentUser!.nickname = snapshot.childSnapshot(forPath: "nickname").value as? String
            currentUser!.profileImageURL = snapshot.childSnapshot(forPath: "profileImageURL").value as? String
            currentUser!.fcmToken = snapshot.childSnapshot(forPath: "fcmToken").value as? String
            
            for lists in snapshot.childSnapshot(forPath: "shoppinglists").children {
                
                let list = lists as! DataSnapshot
                if let index = currentUser!.shoppingLists.index(where: { $0 == list.key }){
                    currentUser!.shoppingLists.remove(at: index)
                }
                currentUser!.shoppingLists.append(list.key)
                NSLog("Succesfully added shoppinglist key \(list.key) to users \(currentUser!.nickname!) shopping lists")
                
            }
            
            var invites = [ShoppingBuddyInvitation]()
            for invitations in snapshot.childSnapshot(forPath: "invites").children {
                
                let invite = invitations as! DataSnapshot
                
                let i = ShoppingBuddyInvitation()
                i.id = invite.key
                i.inviteMessage = invite.childSnapshot(forPath: "inviteMessage").value as? String
                i.inviteTitle = invite.childSnapshot(forPath: "inviteTitle").value as? String
                i.listID = invite.childSnapshot(forPath: "listID").value as? String
                i.listName = invite.childSnapshot(forPath: "listName").value as? String
                i.receiptFcmToken = invite.childSnapshot(forPath: "receiptFcmToken").value as? String
                i.receiptID = invite.childSnapshot(forPath: "receiptID").value as? String
                i.receiptNickname = invite.childSnapshot(forPath: "receiptID").value as? String
                i.receiptProfileImageURL = invite.childSnapshot(forPath: "receiptProfileImageURL").value as? String
                i.senderFcmToken = invite.childSnapshot(forPath: "senderFcmToken").value as? String
                i.senderID = invite.childSnapshot(forPath: "senderID").value as? String
                i.senderNickname = invite.childSnapshot(forPath: "senderNickname").value as? String
                i.senderProfileImageURL = invite.childSnapshot(forPath: "senderProfileImageURL").value as? String
                
                invites.append(i)
                NSLog("Succesfully added invite \(i.id!) to users \(currentUser!.nickname!) invites")
                
                self.UserProfileImageDownloadTask(url: URL(string: i.senderProfileImageURL!)!)
            }
            currentUser!.invites = invites
             
            NotificationCenter.default.post(name: Notification.Name.ReloadInvitesTableView, object: nil, userInfo: nil)
            
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
        self.ShowActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil{
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            } else {
                
                UserDefaults.standard.set(user!.uid, forKey: eUserDefaultKey.CurrentUserID.rawValue)
                self.HideActivityIndicator()
                NotificationCenter.default.post(name: Notification.Name.ShoppingBuddyUserLoggedIn, object: nil, userInfo: nil)
                NSLog("Succesfully loged user in to Firebase")
                
            }
        }
        
    }
    //MARK: User Loout
    func LogFirebaseUserOut() {
        
        self.ShowActivityIndicator()
        let auth = Auth.auth()
        do{
            try  auth.signOut()
            self.HideActivityIndicator()
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
    
    //MARK:- Firebase Auth Section
    func CreateNewFirebaseUser(profileImage:UIImage, nickname: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print(error!.localizedDescription)
                DispatchQueue.main.async {
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
        
        self.ShowActivityIndicator()
        
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
    
    func DownloadUserProfileImage() -> Void {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref.child("users").child(uid).child("profileImageURL").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { return }
            let url = URL(string: snapshot.value as! String)!
            self.UserProfileImageDownloadTask(url: url)
        })
    }
    private func UserProfileImageDownloadTask(url:URL) -> Void {
        
        self.ShowActivityIndicator()
        if let _ = ProfileImageCache.index(where: { $0.ProfileImageURL == url.absoluteString }) {
            
            HideActivityIndicator()
            NotificationCenter.default.post(name: Notification.Name.UserProfileImageDownloadFinished, object: nil, userInfo: nil)
            return
            
        }
        
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            DispatchQueue.main.async {
                
                if let downloadImage = UIImage(data: data!) {
                    
                    let cachedImage = CacheUserProfileImage()
                    cachedImage.UserProfileImage = downloadImage
                    cachedImage.ProfileImageURL = url.absoluteString
                    ProfileImageCache.append(cachedImage)
                    
                    self.HideActivityIndicator()
                    NotificationCenter.default.post(name: Notification.Name.UserProfileImageDownloadFinished, object: nil, userInfo: nil) 
                    
                }
            }
        }
        task.resume()
    }
    
    func ResetUserPassword(email:String){
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            if error == nil {
                
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
    
    //MARK: - Helpers
    private func SaveNewUserWithUIDtoFirebase(shoppingBuddyUser:ShoppingBuddyUser, user: User?) -> Void {
        
        self.ShowActivityIndicator()
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
                    
                    DispatchQueue.main.async {
                        
                        if let imgURL =  metadata?.downloadURL()?.absoluteString {
                            
                            let token:String = Messaging.messaging().fcmToken!
                            let values = (["nickname": shoppingBuddyUser.nickname!, "email": user!.email!, "fcmToken":token, "profileImageURL":imgURL] as [String : Any])
                            self.ref.child("users").child(user!.uid).updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                                
                                if err != nil {
                                     
                                    NSLog(err!.localizedDescription)
                                    let title = String.OnlineFetchRequestError
                                    let message = err!.localizedDescription
                                    self.ShowAlertMessage(title: title, message: message)
                                    return
                                    
                                } else {
                                    
                                    self.HideActivityIndicator()
                                    NSLog("Succesfully saved user to Firebase")
                                    
                                }
                            })
                        }
                        
                        NotificationCenter.default.post(name: Notification.Name.ImageUploadFinished, object: nil, userInfo: nil)
                        print("Successfully uploaded prodcut image!")
                        
                    }//end: Dispatch Queue
                }) // end: let _ = imagesRef.putData
            }//end: if let let uploadData
        }
    }
}
