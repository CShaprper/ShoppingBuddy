//
//  PushNotificationHelper.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 01.09.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

class PushNotificationHelper {
    
    func SendNotificationDependendOnPushNotificationType(userInfo: [AnyHashable : Any]) -> Void {
        
        let notificationType = getNotificationType(userInfo: userInfo)
        
        switch notificationType {
        case .NotSet:
            break
            
        case .SharingInvitation:
            let notificationInfo = getNotificationData(userInfo: userInfo)
            NotificationCenter.default.post(name: Notification.Name.SharingInviteReceived, object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        case .SharingAccepted:
            let notificationInfo = getNotificationData(userInfo: userInfo)
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            NotificationCenter.default.post(name: Notification.Name.UserAcceptedSharing, object: nil, userInfo: nil)
            break
            
        case .CancelSharingBySharedUser:
            let notificationInfo = getNotificationData(userInfo: userInfo)
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        case .CancelSharingByOwner:
            let notificationInfo = getNotificationData(userInfo: userInfo)
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        case .ListItemAddedBySharedUser:
            let notificationInfo = getNotificationData(userInfo: userInfo)
            NotificationCenter.default.post(name: Notification.Name.PushNotificationReceived, object: nil, userInfo: notificationInfo)
            break
            
        case .DeclinedSharingInvitation:
            let notificationInfo = getNotificationData(userInfo: userInfo)
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
        
        downloadUserImage(senderID: senderID)
        
        let notificationInfo = ["notificationTitle": notificationTitle, "notificationMessage":notificationMessage, "senderID":senderID, "listID":listID]
        return notificationInfo
        
    }
    
    private func downloadUserImage(senderID: String) -> Void {
        
        if let _ = allUsers.index(where: { $0.id == senderID }) { }
        else {
            let sbUserService = ShoppingBuddyUserWebservice()
            sbUserService.ObserveUser(userID: senderID)
        }
        
    }
    
}
