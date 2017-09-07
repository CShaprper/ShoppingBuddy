//
//  ShoppingBuddyMessageWebService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 30.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ShoppingBuddyMessageWebservice: IAlertMessageDelegate, IActivityAnimationService {
    
    var alertMessageDelegate: IAlertMessageDelegate?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    
    private var ref = Database.database().reference()
    private var userRef = Database.database().reference().child("users")
    
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            activityAnimationServiceDelegate!.ShowActivityIndicator!()
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. ShowActivityIndicator in ShoppingBuddyMessageWebservice")
        }
    }
    func HideActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            activityAnimationServiceDelegate!.HideActivityIndicator!()
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. HideActivityIndicator in ShoppingBuddyMessageWebservice")
        }
    }
    
    //MARK: IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        self.HideActivityIndicator()
        if alertMessageDelegate != nil {
            DispatchQueue.main.async {
                self.alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
            }
        } else {
            NSLog("AlertMessageDelegate not set from calling class in ShoppingBuddyMessageWebservice")
        }
    }
    
    func AcceptInvitation(invitation: ShoppingBuddyInvitation) -> Void {
        
        self.ShowActivityIndicator()
        let inviteAccepetdMessage = "\(currentUser!.nickname! ) \(String.ShareListAcceptedMessage)"
        
        ref.child("invites").child(invitation.id!).updateChildValues(["inviteAcceptedTitle":String.ShareListTitle, "inviteAcceptedMessage":inviteAccepetdMessage, "status":"accepted"], withCompletionBlock: { (error, dbRef) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            self.HideActivityIndicator()
            NSLog("Successfully accepted invite node")
            
        })
        
    }
     
    
    func ObserveAllInvites() -> Void {
        
        ShowActivityIndicator()
        ref.child("users_invites").child(currentUser!.id!).observe(.value, with: { (allInvitesSnap) in
            
            if allInvitesSnap.value is NSNull { self.HideActivityIndicator(); return }
            
            for invites in allInvitesSnap.children {
                
                let invite = invites as! DataSnapshot
                self.ObserveInvitation(inviteID: invite.key)
                
            }
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            
        }
        
    }
    
    
    func ObserveInvitation(inviteID:String) -> Void {
        
        ShowActivityIndicator()
        ref.child("invites").child(inviteID).observe(.value, with: { (inviteSnap) in
            
            if inviteSnap.value is NSNull {
                
                self.HideActivityIndicator()
                if let index = allInvites.index(where: { $0.id == inviteID }) {
                    
                    allInvites.remove(at: index)
                    NotificationCenter.default.post(name: Notification.Name.AllInvitesReceived, object: nil, userInfo: nil)
                    
                }
                
                return
                
            }
            
            var newInvite = ShoppingBuddyInvitation()
            newInvite.id = inviteSnap.key
            newInvite.inviteMessage = inviteSnap.childSnapshot(forPath: "inviteMessage").value as? String
            newInvite.inviteTitle = inviteSnap.childSnapshot(forPath: "inviteTitle").value as? String
            newInvite.listID = inviteSnap.childSnapshot(forPath: "listID").value as? String
            newInvite.senderID = inviteSnap.childSnapshot(forPath: "senderID").value as? String
            newInvite.receiptID = inviteSnap.childSnapshot(forPath: "receiptID").value as? String
            
            if let index = allInvites.index(where: { $0.id == newInvite.id }) {
                
                allInvites[index] = newInvite
                
            } else {
                
                allInvites.append(newInvite)
                
            }
            self.HideActivityIndicator()
            
            
            //all invites received so lets inform userWebservice to download all users
            NotificationCenter.default.post(name: Notification.Name.AllInvitesReceived, object: nil, userInfo: nil)
            
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            
        }
        
        
        
    }
}

