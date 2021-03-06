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
    var fcmToken:String?
    var profileImageURL:String?
    var localImageLocation:String?
    var profileImage:UIImage?
    var dlType:eUserDLType?
    var isFullVersionUser:Bool?
    
    lazy var uSession:URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
}
extension ShoppingBuddyUser: URLSessionDownloadDelegate {
    
    public func userProfileImageFromURL(dlType:eUserDLType) {
        
        self.dlType = dlType
        
        if let index = allUsers.index(where: { $0.profileImageURL == self.profileImageURL }) {
            
            if allUsers[index].profileImage == nil {
                guard let imageURL = self.profileImageURL else { return }
                let uTask = self.uSession.downloadTask(with: URL(string: imageURL)!)
                uTask.resume()
                return
            }
            
            self.profileImage = allUsers[index].profileImage!
            
            switch dlType {
                
            case .DownloadForPushNotification:
                NotificationCenter.default.post(name: .UserProfileImageDLForPushNotificationFinished, object: nil, userInfo: nil)
                break
            default:
                NotificationCenter.default.post(name: .UserProfileImageDownloadFinished, object: nil, userInfo: nil)
                
            }
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
                
                switch self.dlType! {
                    
                case .DownloadForPushNotification:
                    NotificationCenter.default.post(name: .UserProfileImageDLForPushNotificationFinished, object: nil, userInfo: nil)
                    break
                default:
                    NotificationCenter.default.post(name: .UserProfileImageDownloadFinished, object: nil, userInfo: nil)
                    break
                }
                
            } 
            
        }
        
    }
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error != nil {
            
            NSLog(error!.localizedDescription)
            //ShowAlertMessage(title: String.OnlineFetchRequestError, message: error!.localizedDescription)
            
        }
        
    }
}
