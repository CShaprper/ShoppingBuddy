//
//  User.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 08.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ShoppingBuddyUser:NSObject {
    
    //MARK: - Member
    var id:String?
    var email:String?
    var nickname:String?
    var password:String?
    var fcmToken:String?
    var profileImageURL:String?
    var localImageLocation:String?
    var profileImage:UIImage? 
    
    lazy var uSession:URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
}
extension ShoppingBuddyUser: URLSessionDownloadDelegate {
    
    public func userProfileImageFromURL() {
        
        if let index = allUsers.index(where: { $0.profileImageURL == self.profileImageURL }) {
            
            if allUsers[index].profileImage == nil {
                let uTask = self.uSession.downloadTask(with: URL(string: self.profileImageURL!)!)
                uTask.resume()
                return
            }
            
            self.profileImage = allUsers[index].profileImage!
            NSLog("UserProfileImage for \(self.nickname!) set from ImageCache!")
            NotificationCenter.default.post(name: .UserProfileImageDownloadFinished, object: nil, userInfo: nil)
            return
            
        }
        if let imageURL = self.profileImageURL {
            
            if imageURL.isEmpty { return } 
            let url = URL(string: imageURL)!
            let uTask = self.uSession.downloadTask(with: url)
            uTask.resume()
            
        }
    }
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        
        if let image = try? UIImage(data: Data(contentsOf: location)), image != nil {
            
            if let index = allUsers.index(where: { $0.profileImageURL == self.profileImageURL }){
                
                allUsers[index].profileImage = image
                allUsers[index].localImageLocation = location.absoluteString
                NSLog("Added UserProfileImage for \(self.nickname!) to allUsers")
                NSLog("UserProfileImage for \(self.nickname!) set from DownloadTask!")
                NotificationCenter.default.post(name: .UserProfileImageDownloadFinished, object: nil, userInfo: nil)
                
            } 
            
        } else {
            
            self.profileImage = #imageLiteral(resourceName: "userPlaceholder")
            NotificationCenter.default.post(name: .UserProfileImageDownloadFinished, object: nil, userInfo: nil)
            
        }
        
    }
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error != nil {
            
            NSLog(error!.localizedDescription)
            //ShowAlertMessage(title: String.OnlineFetchRequestError, message: error!.localizedDescription)
            
        }
        
    }
}
