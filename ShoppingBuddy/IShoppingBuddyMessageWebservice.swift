//
//  IShoppingBuddyInvitationWebservice.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 30.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

@objc protocol IShoppingBuddyMessageWebservice {
    
    @objc optional func ShoppingBuddyInvitationReceived(invitation: ShoppingBuddyInvitation)
    @objc optional func ShoppingBuddyUserImageReceived()
    
}
