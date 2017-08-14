//
//  ListID+CoreDataProperties.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 14.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import CoreData


extension ListID {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListID> {
        return NSFetchRequest<ListID>(entityName: "ListID")
    }

    @NSManaged public var listID: String?
    @NSManaged public var relatedStore: String?
    @NSManaged public var userID: String?

}
