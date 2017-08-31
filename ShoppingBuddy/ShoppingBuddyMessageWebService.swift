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

class ShoppingBuddyMessageWebservice: IShoppingBuddyMessageWebservice, IAlertMessageDelegate, IActivityAnimationService {
    
    var alertMessageDelegate: IAlertMessageDelegate?
    var shoppingMessageWebServiceDelegate: IShoppingBuddyMessageWebservice?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    
    private var ref = Database.database().reference()
    private var inviteRef = Database.database().reference().child("invites")
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
    
    //MARK: IShoppingBuddyMessageWebservice implementation
    func ShoppingBuddyInvitationReceived(invitation: ShoppingBuddyInvitation) {
        self.HideActivityIndicator()
        if shoppingMessageWebServiceDelegate != nil {
            DispatchQueue.main.async {
                self.shoppingMessageWebServiceDelegate!.ShoppingBuddyInvitationReceived!(invitation: invitation)
            }
        } else {
            NSLog("shoppingMessageWebServiceDelegate not set from calling class in ShoppingBuddyMessageWebservice")
        }
    }
    
    func ShoppingBuddyUserImageReceived() {
        self.HideActivityIndicator()
        if shoppingMessageWebServiceDelegate != nil {
            DispatchQueue.main.async {
                self.shoppingMessageWebServiceDelegate!.ShoppingBuddyUserImageReceived!()
            }
        } else {
            NSLog("shoppingMessageWebServiceDelegate not set from calling class in ShoppingBuddyUserImageReceived")
        }
    }
    
    //MARK: - Observe Invitations
    func ObserveInvitations() -> Void {
        self.ShowActivityIndicator()
        
        for invite in currentUser.invites {
            inviteRef.child(invite).observe(.value, with: { (snapshot) in
                
                if snapshot.value is NSNull { return }
                let invitation = ShoppingBuddyInvitation()
                invitation.id = snapshot.key
                invitation.invitedListID = snapshot.childSnapshot(forPath: "listID").value as? String
                invitation.inviteMessage = snapshot.childSnapshot(forPath: "inviteMessage").value as? String
                invitation.inviteTitle = snapshot.childSnapshot(forPath: "inviteTitle").value as? String
                invitation.senderFcmToken = snapshot.childSnapshot(forPath: "senderFcmToken").value as? String
                invitation.senderID = snapshot.childSnapshot(forPath: "senderID").value as? String
                invitation.senderNickname = snapshot.childSnapshot(forPath: "senderNickname").value as? String
                invitation.senderProfileImageURL = snapshot.childSnapshot(forPath: "senderProfileImageURL").value as? String
                
                if let index = invitationsArray.index(where: { $0.id == invitation.id }) {
                    invitationsArray.remove(at: index)
                }
                
                invitationsArray.append(invitation)
                self.HideActivityIndicator()
                self.ShoppingBuddyInvitationReceived(invitation: invitation)
                NotificationCenter.default.post(name: Notification.Name.RefreshMessagesBadgeValue, object: nil, userInfo: nil)
                
            }, withCancel: { (error) in
                
                self.HideActivityIndicator()
                NSLog(error.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                
            })
        }
    }
    
    
    func DownloadInvitationsProfileImages(invitation:ShoppingBuddyInvitation) -> Void {
        
        let url = URL(string: invitation.senderProfileImageURL!)!
        self.UserProfileImageDownloadTask(url: url)
        
    }
    
    private func UserProfileImageDownloadTask(url:URL) -> Void {
        
        self.ShowActivityIndicator()
        if let index = ProfileImageCache.index(where: { $0.ProfileImageURL == url.absoluteString }) {
            
            if let inviteIndex = invitationsArray.index(where: { $0.senderProfileImageURL! == url.absoluteString }) {
                invitationsArray[inviteIndex].senderImage = ProfileImageCache[index].UserProfileImage!
                self.HideActivityIndicator()
                return
            }
            
        }
        
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
                self.HideActivityIndicator()
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
                    self.ShoppingBuddyUserImageReceived()
                    
                }
                self.HideActivityIndicator()
            }
        }
        task.resume()
    }
}

