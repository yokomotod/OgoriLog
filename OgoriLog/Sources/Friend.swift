//
//  Friend.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import Foundation
import CoreData

class Friend: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var timeStamp: NSDate
    @NSManaged var totalBill: NSNumber
    @NSManaged var identifier: NSNumber
    @NSManaged var bills: NSSet

}
