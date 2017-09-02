//
//  ShoppingList.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 28.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

struct ShoppingList{
    var id:String?
    var owneruid:String?
    var name:String?
    var ownerImageURL:String?
    var ownerImage:UIImage?
    var relatedStore:String?
    var itemsArray:[ShoppingListItem]!
    var membersArray:[ShoppingBuddyUser]!
    
    init() {
        itemsArray = []
        membersArray = []
    }
    
}
