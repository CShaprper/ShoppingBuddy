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
    internal let firebaseURL:String = "https://shoppingbuddy-1ef51.firebaseio.com/"
    private var ref:DatabaseReference!
    private var isCalled:Bool = false
    var delegate: IFirebaseWebService?
    var alertTitle = ""
    var alertMessage = ""
    
    //Constructor
    init() {
        ref = Database.database().reference(fromURL: firebaseURL)
    }
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestFinished() {
        if delegate != nil { DispatchQueue.main.async { self.delegate!.FirebaseRequestFinished!() }}
        else { print("IFirebaseWebService delegate for FirebaseRequestFinished not set from calling class") }
    }
    func FirebaseRequestStarted() {
        if delegate != nil { DispatchQueue.main.async { self.delegate!.FirebaseRequestStarted!() }}
        else { print("IFirebaseWebService delegate for FirebaseRequestStarted not set from calling class") }
    }
    func AlertFromFirebaseService(title: String, message: String) {
        if delegate != nil { DispatchQueue.main.async { self.delegate!.AlertFromFirebaseService!(title: title, message: message) }}
        else { print("IFirebaseWebService delegate for alert not set from calling class") }
    }
    
    //MARK: - FirebaseWebService methods
    func AddUserStateListener() -> Void {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil{
                if !self.isCalled{
                    print("State listener detected user loged in")
                    NotificationCenter.default.post(name: NSNotification.Name.SegueToDashboardController, object: nil)
                    self.isCalled = true
                }
            } else {
                print("State listener detected user loged out")
                NotificationCenter.default.post(name: NSNotification.Name.SegueToLogInController, object: nil)
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
                    self.AlertFromFirebaseService(title: title, message: message)
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
                    self.AlertFromFirebaseService(title: title, message: message)
                }
                return
            } else {
                self.FirebaseRequestFinished()
                print("Succesfully loged user in to Firebase")
            }
        }
    }
    func LogUserOut() {
        self.isCalled = false
        let auth = Auth.auth()
        do{
            try  auth.signOut()
            self.FirebaseRequestFinished()
            print("Succesfully logged out")
            self.isCalled = false
        }
        catch let error as NSError{
            print(error.localizedDescription)
            self.FirebaseRequestFinished()
            let title = ""
            let message = ""
            self.AlertFromFirebaseService(title: title, message: message)
        }
        
    }
    func ResetUserPassword(email:String){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                print(error!.localizedDescription)
                self.FirebaseRequestFinished()
                let title = ""
                let message = ""
                self.AlertFromFirebaseService(title: title, message: message)
                return
            }
            print("Succesfully sent password reset mail")
            return
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
