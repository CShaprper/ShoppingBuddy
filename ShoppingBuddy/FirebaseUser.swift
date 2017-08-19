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

class FirebaseUser:IFirebaseUserWebservice {
    //MARK: - Member
    private var ref = Database.database().reference()
    private var userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
    var activityAnimationServiceDelegate:IActivityAnimationService?
    var alertMessageDelegate: IAlertMessageDelegate?
    var firebaseUserWebServiceDelegate:IFirebaseUserWebservice?
    var firebaseWebServiceDelegate: IFirebaseWebService?
    var Email:String?
    var Nickname:String?
    var Password:String?
    var FCMToken:String?
    var ProfileImage:UIImage?
    
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
    
    //MARK User Login
    func LoginFirebaseUser(email: String, password: String) {
        //self.isCalled = false
        self.ShowActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    self.HideActivityIndicator()
                    let title = String.OnlineFetchRequestError
                    let message = error!.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                }
                return
            } else {
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
    
    func CreateNewFirebaseUser(firebaseUser: FirebaseUser) {
        self.ShowActivityIndicator()
        //self.isCalled = false
        Auth.auth().createUser(withEmail: firebaseUser.Email!, password: firebaseUser.Password!, completion: { (user, error) in
            if error != nil{
                NSLog(error!.localizedDescription)
                self.HideActivityIndicator()
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            self.SaveNewUserWithUIDtoFirebase(firebaseUser: firebaseUser, user: user)
            self.HideActivityIndicator()
            NSLog("Succesfully created new Firebase User")
        })
    }
    func SetNewFcmToken(token:String){
        self.ShowActivityIndicator()
        userRef.child("fcmToken").setValue(token) { (error, dbRef) in
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
        Auth.auth().fetchProviders(forEmail: email) { (test, error) in
            if error != nil {
                NSLog(error!.localizedDescription)
                self.HideActivityIndicator()
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            NSLog("Refreshed User fcmToken")
            if test != nil {
                self.GetuidByEmail(listID: listID, email: email)
            } else {
                let title = String.OnlineFetchRequestError
                let message = "\(email) is not a registered address!"
                self.ShowAlertMessage(title: title, message: message)
            }
        }
    }
    func GetuidByEmail(listID:String, email:String) -> Void {
        self.ShowActivityIndicator()
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value == nil { return }
            if snapshot.childrenCount == 0 { return }
            for user in snapshot.children{
                let usr = user as! DataSnapshot
                self.userRef.child("friends").child(usr.key).setValue("pending")
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
            if snapshot.value == nil { return }
            NSLog(snapshot.value as! String)
            let url = URL(string: snapshot.value as! String)!
            self.UserProfileImageDownloadTask(url: url)
        })
    }
    private func UserProfileImageDownloadTask(url:URL) -> Void{
        self.ShowActivityIndicator()
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
                    CurrentUserProfileImage = downloadImage
                    self.UserProfileImageDownloadFinished()
                    self.HideActivityIndicator()
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Helpers
    private func SaveNewUserWithUIDtoFirebase(firebaseUser:FirebaseUser, user: User?){
        self.ShowActivityIndicator()
        //Image Upload
        let imagesRef = Storage.storage().reference().child(user!.uid)
        if firebaseUser.ProfileImage != nil {
            if let uploadData = firebaseUser.ProfileImage!.mediumQualityJPEGNSData{
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
                            let values = (["nickname": firebaseUser.Nickname!, "email": user!.email!, "fcmToken":token, "profileImageURL":imgURL] as [String : Any])
                            self.userRef.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
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
                        print("Successfully uploaded prodcut image!")
                    }//end: Dispatch Queue
                }) // end: let _ = imagesRef.putData
            }//end: if let let uploadData
        }
    }
}
