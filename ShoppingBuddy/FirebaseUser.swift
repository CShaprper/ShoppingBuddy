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

class FirebaseUser: IFirebaseWebService {
    //MARK: - Member
    private var ref = Database.database().reference()
    private var userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
    var alertMessageDelegate: IAlertMessageDelegate?
    var firebaseWebServiceDelegate: IFirebaseWebService?
    var Email:String?
    var Nickname:String?
    var Password:String?
    var FCMToken:String?
    
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseUserLoggedIn() { }
    func FirebaseUserLoggedOut() { }
    func FirebaseRequestStarted() {
        if firebaseWebServiceDelegate != nil{
            DispatchQueue.main.async {
                self.firebaseWebServiceDelegate!.FirebaseRequestStarted!()
            }
        }
    }
    func FirebaseRequestFinished() {
        if firebaseWebServiceDelegate != nil {
            DispatchQueue.main.async {
                self.firebaseWebServiceDelegate!.FirebaseRequestFinished!()
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
    
    func CreateNewFirebaseUser(firebaseUser: FirebaseUser) {
        //self.isCalled = false
        
        Auth.auth().createUser(withEmail: firebaseUser.Email!, password: firebaseUser.Password!, completion: { (user, error) in
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
                self.SaveNewUserWithUIDtoFirebase(firebaseUser: firebaseUser, user: user)
                self.FirebaseRequestFinished()
                print("Succesfully created new Firebase User")
            }
        })
    }
    //MARK: - Helpers
    private func SaveNewUserWithUIDtoFirebase(firebaseUser:FirebaseUser, user: User?){
        DispatchQueue.main.async {
            let token:[String:AnyObject] = [Messaging.messaging().fcmToken!:Messaging.messaging().fcmToken as AnyObject]
            print(token)
            let values = (["nickname": firebaseUser.Nickname!, "email": user!.email!, "fcmToken":token] as [String : Any])
            self.userRef.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
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
