//
//  ShoppingBuddyInvitations.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 30.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

struct ShoppingBuddyMessage {
    
    var id:String?
    var message:String?
    var title:String?
    var listID:String?
    var senderID:String?
    var messageType:String?
    var date:String?
    var receipts:[ShoppingListMember]!
    
    init() {
        receipts = []
    }
    
}
