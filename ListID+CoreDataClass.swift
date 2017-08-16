//
//  ListID+CoreDataClass.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 13.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import CoreData


public class ListID: NSManagedObject {
    static let EntityName = "ListID"
    
    static func InsertIntoManagedObjectContext(context:NSManagedObjectContext)->ListID{
        let obj = (NSEntityDescription.insertNewObject(forEntityName: ListID.EntityName, into: context)) as! ListID
        NSLog("\(ListID.EntityName) Entity object created in NSManagedObjectContext")
        return obj
    }

    static func SaveListID(listID:ListID, context:NSManagedObjectContext) -> Void {
        do{
            try context.save()
            NSLog("successfully saved \(listID.listID!) to CoreData")
        }
        catch let error as NSError{
            NSLog(error.localizedDescription)
        }
    }
    
    static func FetchListID(userID: String, context:NSManagedObjectContext) -> [ListID]? {
        do{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ListID.EntityName)
             fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
            let fetchResults = try context.fetch(fetchRequest) as? [ListID]
            NSLog("\(fetchResults!.count) \(ListID.EntityName) objects fetched from Core Data")
            
            return fetchResults!
        }
        catch let error as NSError{
            NSLog(error.localizedDescription)
        }
        return []
    }
    static func FetchListID(userID: String, idToFetch:String, context:NSManagedObjectContext) -> [ListID]? {
        do{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ListID.EntityName)
            let listIDPredicate = NSPredicate(format: "listID == %@", idToFetch)
            let userIDPredicate = NSPredicate(format: "userID == %@", userID)
            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [listIDPredicate, userIDPredicate])
            let fetchResults = try context.fetch(fetchRequest) as? [ListID]
            NSLog("\(fetchResults!.count) \(ListID.EntityName) objects fetched from Core Data")
            
            return fetchResults!
        }
        catch let error as NSError{
            NSLog(error.localizedDescription)
        }
        return []
    }
    
    static func DeleteListID(listID:ListID, context:NSManagedObjectContext)->Void{
        context.delete(listID)
        do {
            try context.save()
            NSLog("Deleted \(listID) from CoreData")
        } catch let error as NSError  {
            NSLog("Could not delete \(listID) from CoreData \(error), \(error.userInfo)")
        }
    }

}
