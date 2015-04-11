//
//  Bill+Helper.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import Foundation
import CoreData

extension Bill {
    class func lastIdentifier(context: NSManagedObjectContext) -> Int {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Bill", inManagedObjectContext: context)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1

        let lastBill = context.executeFetchRequest(fetchRequest, error: nil)?.first as! Bill?
        return lastBill != nil ? lastBill!.identifier.integerValue : -1
    }

}