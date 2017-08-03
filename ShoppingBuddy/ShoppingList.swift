//
//  ShoppingList.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 28.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

struct ShoppingList {
    var ID:String?
    var Name:String?
    var RelatedStore:String?
    var ItemsArray:[ShoppingListItem]?
    
    init() {
        ItemsArray = []
    }
}
