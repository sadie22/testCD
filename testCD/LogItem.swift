//
//  LogItem.swift
//  testCD
//
//  Created by Mercedes Streeter on 2/11/15.
//  Copyright (c) 2015 Mercedes Streeter. All rights reserved.
//

import Foundation
import CoreData

class LogItem: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var notes: String

    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, text: String) -> LogItem{
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("LogItem", inManagedObjectContext: moc) as LogItem
        newItem.name = title
        newItem.notes = text
        return newItem
    }
    
}
