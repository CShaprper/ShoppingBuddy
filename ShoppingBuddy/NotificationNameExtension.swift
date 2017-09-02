//
//  NotificationNameExtension.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 23.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

public extension Notification.Name{
    static let SegueToLogInController = Notification.Name("SegueToLogInController")
    static let SegueToDashboardController = Notification.Name("SegueToDashboardController")
    static let ImageUploadFinished = Notification.Name("ImageUploadFinished")
    static let PerformLocalShopSearch = Notification.Name("PerformLocalShopSearch")
    static let RefreshMessagesBadgeValue = Notification.Name("RefreshMessagesBadgeValue")
    static let SharingInvitationNotification = Notification.Name("SharingInvitationNotification")
    static let ReloadInvitesTableView = Notification.Name("ReloadInvitesTableView")
    static let UserProfileImageDownloadFinished = Notification.Name("UserProfileImageDownloadFinished")
    static let ShoppingBuddyUserLoggedOut = Notification.Name("ShoppingBuddyUserLoggedOut")
    static let ShoppingBuddyUserLoggedIn = Notification.Name("ShoppingBuddyUserLoggedIn")
    static let ShoppingBuddyListDataReceived = Notification.Name("ShoppingBuddyListDataReceived")
    static let ListItemSaved = Notification.Name("ListItemSaved")
    static let ListItemReceived = Notification.Name("ListItemReceived")
    static let AddedFriendsListAfterSharingAccept = Notification.Name("AddedFriendsListAfterSharingAccept")
}
