//
//  NotificationNameExtension.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 23.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

public extension Notification.Name {
    
    static let SegueToLogInController = Notification.Name("SegueToLogInController")
    static let SegueToDashboardController = Notification.Name("SegueToDashboardController") 
    static let PerformLocalShopSearch = Notification.Name("PerformLocalShopSearch")
    static let RefreshMessagesBadgeValue = Notification.Name("RefreshMessagesBadgeValue")
    
    //Notification names on ListWebservice
    static let ShoppingBuddyStoreReceived = Notification.Name("ShoppingBuddyStoreReceived")
    static let ShoppingBuddyListDataReceived = Notification.Name("ShoppingBuddyListDataReceived")
    
    //Notification names on UserWebservice
    static let PushNotificationReceived = Notification.Name("PushNotificationReceived") 
    static let ShoppingBuddyUserLoggedOut = Notification.Name("ShoppingBuddyUserLoggedOut")
    static let ShoppingBuddyUserLoggedIn = Notification.Name("ShoppingBuddyUserLoggedIn")
    static let UserProfileImageDownloadFinished = Notification.Name("UserProfileImageDownloadFinished")
    static let CurrentUserReceived = Notification.Name("CurrentUserReceived")
    
    //Notification names on Invites / Messages
    static let AllInvitesReceived = Notification.Name("AllInvitesReceived")
    
    //Notification names on ItemsWebservice
    static let ListItemSaved = Notification.Name("ListItemSaved")
    static let ListItemReceived = Notification.Name("ListItemReceived")
    
    static let UserAcceptedSharing = Notification.Name("UserAcceptedSharing")
    
    static let CurrentUserCreated = Notification.Name("CurrentUserCreated")
    static let SharingInviteReceived = Notification.Name("SharingInviteReceived")
    
    //Notification names on UserProfileImageDownloads
    static let UserProfileImageDLForPushNotificationFinished = Notification.Name("UserProfileImageDLForPushNotificationFinished")
    
    static let UserEmailNotFoundForSharing = Notification.Name("UserEmailNotFoundForSharing")
    
    static let ShowOnboardingPopUp_LoginController = Notification.Name("ShowOnboardingPopUp_LoginController")
}
