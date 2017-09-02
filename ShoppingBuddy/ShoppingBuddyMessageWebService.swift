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
    
    func AcceptInvitation(invitation: ShoppingBuddyInvitation) -> Void {        
       
        
    }
    
    //private func set
    
    private func buildGroupFromInvitationMembers(invitation: ShoppingBuddyInvitation) -> Void {
        
        
        
    }
    
    
    func DownloadInvitationsProfileImages(invitation:ShoppingBuddyInvitation) -> Void {
        
      let url = URL(string: invitation.senderProfileImageURL!)!
        self.UserProfileImageDownloadTask(url: url)
        
    }
    
    private func UserProfileImageDownloadTask(url:URL) -> Void {
        
        self.ShowActivityIndicator()
        if let index = ProfileImageCache.index(where: { $0.ProfileImageURL! == url.absoluteString }) {
            
            if let inviteIndex = currentUser!.invites.index(where: { $0.senderProfileImageURL! == url.absoluteString }) {
                currentUser!.invites[inviteIndex].senderImage = ProfileImageCache[index].UserProfileImage!
                self.ShoppingBuddyUserImageReceived()
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
                    return
                    
                }
                self.HideActivityIndicator()
            }
        }
        task.resume()
    }
}

