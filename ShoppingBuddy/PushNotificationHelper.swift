//
//  PushNotificationHelper.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 01.09.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
var notificationInfo: [AnyHashable : Any]?

class PushNotificationHelper:NSObject, URLSessionDownloadDelegate {
    internal var profileImageURL:String!
    internal var notificationType:eNotificationType?
    
    lazy var uSession:URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: .UserProfileImageDLForPushNotificationFinished, object: nil, queue: OperationQueue.main, using: UserProfileImageDLForPushNotificationFinished)
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        if let image = try? UIImage(data: Data(contentsOf: location)), image != nil {
            
            if let index = allUsers.index(where: { $0.profileImageURL == profileImageURL }){
                
                allUsers[index].profileImage = image
                allUsers[index].localImageLocation = location.absoluteString
                NotificationCenter.default.post(name: .UserProfileImageDownloadFinished, object: nil, userInfo: nil)
                
            }
        }
    }
    
    func SendNotificationDependendOnPushNotificationType(userInfo: [AnyHashable : Any]) -> Void {
        
        notificationType = getNotificationType(userInfo: userInfo)
        
        switch notificationType! {
        case .NotSet:
            break
            
        case .SharingInvitation:
            let not = getNotificationData(userInfo: userInfo)
            if not == nil { return }
            NotificationCenter.default.post(name: Notification.Name.SharingInviteReceived, object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        case .SharingAccepted:
            let not = getNotificationData(userInfo: userInfo)
            if not == nil { return }
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            NotificationCenter.default.post(name: Notification.Name.UserAcceptedSharing, object: nil, userInfo: nil)
            break
            
        case .CancelSharingBySharedUser:
            let not = getNotificationData(userInfo: userInfo)
            if not == nil { return }
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        case .CancelSharingByOwner:
            let not = getNotificationData(userInfo: userInfo)
            if not == nil { return }
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        case .ListItemAddedBySharedUser:
            let not = getNotificationData(userInfo: userInfo)
            if not == nil { return }
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        case .DeclinedSharingInvitation:
            let not = getNotificationData(userInfo: userInfo)
            if not == nil { return }
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        case .WillGoShoppingMessage:
            let not = getNotificationData(userInfo: userInfo)
            if not == nil { return }
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        }
        
        
        
    }
    
    
    private func getNotificationType(userInfo: [AnyHashable : Any]) -> eNotificationType {
        
        guard let notificationType = userInfo["gcm.notification.notificationType"] as? String else {
            return eNotificationType.NotSet
        }
        
        switch notificationType {
            
        case eNotificationType.SharingInvitation.rawValue:
            return eNotificationType.SharingInvitation
            
        case eNotificationType.SharingAccepted.rawValue:
            return eNotificationType.SharingAccepted
            
        case eNotificationType.CancelSharingByOwner.rawValue:
            return eNotificationType.CancelSharingByOwner
            
        case eNotificationType.CancelSharingBySharedUser.rawValue:
            return eNotificationType.CancelSharingBySharedUser
            
        case eNotificationType.ListItemAddedBySharedUser.rawValue:
            return eNotificationType.ListItemAddedBySharedUser
            
        case eNotificationType.ListItemAddedBySharedUser.rawValue:
            return eNotificationType.ListItemAddedBySharedUser
            
        case eNotificationType.WillGoShoppingMessage.rawValue:
            return eNotificationType.WillGoShoppingMessage
            
        case eNotificationType.DeclinedSharingInvitation.rawValue:
            return eNotificationType.DeclinedSharingInvitation
            
        default:
            return eNotificationType.NotSet
            
        }
        
    }
    
    private func getNotificationData(userInfo: [AnyHashable : Any]) -> [AnyHashable : Any]? {
        
        guard let listID = userInfo["gcm.notification.listID"] as? String,
            let senderID = userInfo["gcm.notification.senderID"] as? String else { return nil }
        guard let aps = userInfo["aps"] as? NSDictionary else { return nil }
        guard let alert = aps["alert"] as? NSDictionary else { return nil }
        guard let notificationTitle = alert["title"] as? String,
            let notificationMessage = alert["body"] as? String else { return nil }
        
        //set notification info
        notificationInfo = userInfo
        
        //profile image URL exists?
        if needDownloadUserProfileImage(userID: senderID) {
            
            downloadUser(userID: senderID, dlType: .DownloadForPushNotification)
            
        } else {
            
            //no new user download necessary return notification info from push
            notificationInfo = ["notificationTitle": notificationTitle, "notificationMessage":notificationMessage, "senderID":senderID, "listID":listID]
            return notificationInfo
            
        }
        
        return nil
        
    }
    
    private func needDownloadUserProfileImage(userID: String) -> Bool {
        
        if let _ = allUsers.index(where: { $0.id == userID }) { return false }
        return true
        
    }
    
    private func downloadUser(userID:String, dlType:eUserDLType) {
        
        let sbUserService = ShoppingBuddyUserWebservice()
        sbUserService.ObserveUser(userID: userID, dlType: dlType)
        
    }
    
    func UserProfileImageDLForPushNotificationFinished(notification:Notification) -> Void {
        
        //send out notification after image downloaded with pre saved  notification inf
        SendNotificationDependendOnPushNotificationType(userInfo: notificationInfo!)
        
    }
    
}

