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
            return
            
        case .SharingInvitation:
            sendSharingInvitationNotification(userInfo: userInfo)
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
            
        default:
            return eNotificationType.NotSet
        }
        
    }
    
    private func sendSharingInvitationNotification(userInfo: [AnyHashable : Any]) -> Void {
 
        NotificationCenter.default.post(name: Notification.Name.SharingInvitationNotification, object: nil, userInfo: userInfo)
        
    }
    
    func createChoppingBuddyIntitationObject(userInfo: [AnyHashable : Any]) -> ShoppingBuddyInvitation? {
        
        guard let sbID = userInfo["gcm.notification.sbID"] as? String,
            let senderID = userInfo["gcm.notification.senderID"] as? String,
            let listID = userInfo["gcm.notification.listID"] as? String,
            let receiptID = userInfo["gcm.notification.receiptID"] as? String else { return nil }
        guard let aps = userInfo["aps"] as? NSDictionary else { return nil }
        guard let alert = aps["alert"] as? NSDictionary else { return nil }
        guard let title = alert["title"] as? String,
            let body = alert["body"] as? String else { return nil }
        
        var sbi = ShoppingBuddyInvitation()
        sbi.id = sbID
        sbi.listID = listID
        sbi.inviteMessage = body
        sbi.inviteTitle = title
        // sbi.sender = senderID
        // sbi.receipt = receiptID
        
        return sbi
    }
}
