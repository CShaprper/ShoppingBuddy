//
//  IShoppingBuddyUserWebService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

@objc protocol IShoppingBuddyUserWebservice {
    @objc optional var shoppingBuddyUserWebserviceDelegate:IShoppingBuddyUserWebservice? { get  set }
    @objc optional func UserProfileImageDownloadFinished()
    @objc optional func ShoppingBuddyUserLoggedIn()
    @objc optional func ShoppingBuddyUserLoggedOut()
    @objc optional func ShoppingBuddyUserDataReceived()
}
