//
//  IShoppingBuddyListWebService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 15.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

@objc protocol IShoppingBuddyListWebService{
    @objc optional var shoppingBuddyListWebServiceDelegate:IShoppingBuddyListWebService? { get set }
    @objc optional func ShoppingBuddyListDataReceived()
}
