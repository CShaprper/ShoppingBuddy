//
//  IShoppingListItemWebService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 18.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

@objc protocol IShoppingBuddyListItemWebService {
    @objc optional var shoppingListItemWebServiceDelegate:IShoppingBuddyListItemWebService? { get set }
    @objc optional func ListItemSaved() 
    @objc optional func ListItemReceived()
}
