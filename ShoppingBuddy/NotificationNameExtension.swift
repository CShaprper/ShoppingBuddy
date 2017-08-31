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
}
