//
//  User.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 08.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

class FirebaseUser:NSObject, IFirebaseUserWebservice {
    //MARK: - Member
    private var ref = Database.database().reference()
    var activityAnimationServiceDelegate:IActivityAnimationService?
    var alertMessageDelegate: IAlertMessageDelegate?
    var firebaseUserWebServiceDelegate:IFirebaseUserWebservice?
    var id:String?
    var email:String?
    var nickname:String?
    var password:String?
    var fcmToken:String?
    var profileImageURL:String?
    var profileImage:UIImage?
    var sharingStatus:String?
    
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
    
    //MARK: - IFirebaseUserWebService implementation
    func FirebaseUserLoggedIn() {
        if firebaseUserWebServiceDelegate != nil {
            DispatchQueue.main.async {
                self.firebaseUserWebServiceDelegate!.FirebaseUserLoggedIn!()
            }
        }
    }
    func FirebaseUserLoggedOut() {
        if firebaseUserWebServiceDelegate != nil {
            DispatchQueue.main.async {
                self.firebaseUserWebServiceDelegate!.FirebaseUserLoggedOut!()
            }
        }
    }
    func UserProfileImageDownloadFinished() -> Void {
        if firebaseUserWebServiceDelegate != nil {
            DispatchQueue.main.async {
                self.firebaseUserWebServiceDelegate!.UserProfileImageDownloadFinished!()
            }
        }
    }
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil {
            DispatchQueue.main.async {
                self.alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
            }
        }
    }
    
    
    lazy var uSession:URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    //MARK User Login
    func LoginFirebaseUser(email: String, password: String) {
        //self.isCalled = false
        self.ShowActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                NSLog(error!.localizedDescription)
                self.HideActivityIndicator()
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            } else {
                UserDefaults.standard.set(user!.uid, forKey: eUserDefaultKey.CurrentUserID.rawValue)
                self.HideActivityIndicator()
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
            self.HideActivityIndicator()
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
                let fbUser = FirebaseUser()
                fbUser.profileImage = profileImage
                fbUser.nickname = nickname
                fbUser.email = email
                
                self.SaveNewUserWithUIDtoFirebase(firebaseUser: fbUser, user: user) 
                NSLog("Succesfully created new Firebase User")
            }
        })
    }

    func SetNewFcmToken(token:String){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        self.ShowActivityIndicator()
        ref.child("users").child(uid).child("fcmToken").setValue(token) { (error, dbRef) in
            if error != nil{
                NSLog(error!.localizedDescription)
                self.HideActivityIndicator()
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            NSLog("Refreshed User fcmToken")
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
                self.SetFriendValues(listID: listID, email: email)
            } else {
                let title = String.OnlineFetchRequestError
                let message = "\(email) is not a registered address!"
                self.ShowAlertMessage(title: title, message: message)
            }
        }
    }
    func SetFriendValues(listID:String, email:String) -> Void {
        self.ShowActivityIndicator()
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { return }
            if snapshot.childrenCount == 0 { return }
            for user in snapshot.children{
                let usr = user as! DataSnapshot
                self.ref.child("users").child(uid).child("friends").child(usr.key).setValue("pending")
                self.ref.child("shoppinglists").child(uid).child(listID).child("members").child(usr.key).setValue("pending")
                self.ref.child("users").child(usr.key).child("friends").child(uid).setValue("pending")
            }
            self.HideActivityIndicator()
        })
    }
    func DownloadUserProfileImage(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref.child("users").child(uid).child("profileImageURL").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { return }
            let url = URL(string: snapshot.value as! String)!
            self.UserProfileImageDownloadTask(url: url)
        })
    }
    private func UserProfileImageDownloadTask(url:URL) -> Void{
        self.ShowActivityIndicator()
        if let index = ProfileImageCache.index(where: { $0.ProfileImageURL == url.absoluteString }) {
            CurrentUserProfileImage = ProfileImageCache[index].UserProfileImage!
            self.HideActivityIndicator()
            return
        }
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil{
                self.HideActivityIndicator()
                print(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            DispatchQueue.main.async {
                if let downloadImage = UIImage(data: data!){
                    let cachedImage = CacheUserProfileImage()
                    cachedImage.UserProfileImage = downloadImage
                    cachedImage.ProfileImageURL = url.absoluteString
                    ProfileImageCache.append(cachedImage)
                    CurrentUserProfileImage = downloadImage
                    self.UserProfileImageDownloadFinished()
                    self.HideActivityIndicator()
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
            if user != nil{
                NSLog("State listener detected user loged in")
                UserDefaults.standard.set(user!.uid, forKey: eUserDefaultKey.CurrentUserID.rawValue)
                self.FirebaseUserLoggedIn()
            } else {
                UserDefaults.standard.set("false", forKey: eUserDefaultKey.CurrentUserID.rawValue)
                NSLog("State listener detected user loged out")
                self.FirebaseUserLoggedOut()
                NotificationCenter.default.post(name: Notification.Name.SegueToLogInController, object: nil, userInfo: nil)
            }
        }
    }
    
    //MARK: - Helpers
    private func SaveNewUserWithUIDtoFirebase(firebaseUser:FirebaseUser, user: User?){
        self.ShowActivityIndicator()
        //Image Upload
        let imagesRef = Storage.storage().reference().child(user!.uid)
        if firebaseUser.profileImage != nil {
            if let uploadData = firebaseUser.profileImage!.mediumQualityJPEGNSData{
                let _ = imagesRef.putData(uploadData as Data, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error!.localizedDescription)
                        self.HideActivityIndicator()
                        let title = String.OnlineFetchRequestError
                        let message = error!.localizedDescription
                        self.ShowAlertMessage(title: title, message: message)
                        return
                    }
                    DispatchQueue.main.async {
                        print(metadata ?? "")
                        if let imgURL =  metadata?.downloadURL()?.absoluteString{
                            let token:String = Messaging.messaging().fcmToken!              
                            let values = (["nickname": firebaseUser.nickname!, "email": user!.email!, "fcmToken":token, "profileImageURL":imgURL] as [String : Any])
                            self.ref.child("users").child(user!.uid).updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                                if err != nil{
                                    self.HideActivityIndicator()
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
