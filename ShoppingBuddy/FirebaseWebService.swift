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
        else { NSLog("IFirebaseWebService delegate for FirebaseRequestFinished not set from calling class") }
    }
    func FirebaseRequestStarted() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async { self.firebaseWebServiceDelegate!.FirebaseRequestStarted!() }}
        else { NSLog("IFirebaseWebService delegate for FirebaseRequestStarted not set from calling class") }
    }
    func FirebaseUserLoggedIn() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async { self.firebaseWebServiceDelegate!.FirebaseUserLoggedIn!() }}
        else { NSLog("IFirebaseWebService delegate for alert not set from calling class") }
    }
    func FirebaseUserLoggedOut() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async { self.firebaseWebServiceDelegate!.FirebaseUserLoggedOut!() }}
        else { NSLog("IFirebaseWebService delegate for alert not set from calling class") }
    }
    func ReloadItems() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async { self.firebaseWebServiceDelegate!.ReloadItems!() }}
        else { NSLog("IFirebaseWebService delegate for alert not set from calling class") }
    }
    func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil{
            DispatchQueue.main.async {
                self.alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
            }
        } else{
            NSLog("AlertMessageDelegate not set from calling class in FirebaseWebService")
        }
    }
    
    //MARK: - FirebaseWebService methods
    func AddUserStateListener() -> Void {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil{
                NSLog("State listener detected user loged in")
                self.FirebaseUserLoggedIn()
            } else {
                NSLog("State listener detected user loged out")
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
                NSLog("Succesfully created new Firebase User")
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
                NSLog("Succesfully loged user in to Firebase")
            }
        }
    }
    func LogUserOut() {
        let auth = Auth.auth()
        do{
            try  auth.signOut()
            self.FirebaseRequestFinished()
            NSLog("Succesfully logged out")
        }
        catch let error as NSError{
            NSLog(error.localizedDescription)
            self.FirebaseRequestFinished()
            let title = ""
            let message = ""
            self.ShowAlertMessage(title: title, message: message)
        }
    }
    func ResetUserPassword(email:String){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                NSLog(error!.localizedDescription)
                self.FirebaseRequestFinished()
                let title = ""
                let message = ""
                self.ShowAlertMessage(title: title, message: message)
                return
            }
            NSLog("Succesfully sent password reset mail")
            return
        }
        
    }
    
    //MARK: - Helpers
    private func SaveNewUserWithUIDtoFirebase(nickname:String, user: User?, firebaseURL: String){
        DispatchQueue.main.async {
            guard let uid = user?.uid else{
                return
            }
            let token:String = Messaging.messaging().fcmToken!
            NSLog(token)
            let usersReference = self.ref.child("users").child(uid)
            let values = (["nickname": nickname, "email": user!.email!, "fcmToken":token] as [String : Any])
            usersReference.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                if err != nil{
                    self.FirebaseRequestFinished()
                    NSLog(err!.localizedDescription)
                    return
                } else {
                    self.FirebaseRequestFinished()
                    NSLog("Succesfully saved user to Firebase")
                }
            })
        }
    }
    
}
