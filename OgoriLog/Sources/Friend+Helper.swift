//
//  Friend+Helper.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import Foundation
import CoreData

extension Friend {

    func lastIdentifier() -> Int {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Friend", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1

        let lastFriend = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)?.first as Friend?
        return lastFriend != nil ? lastFriend!.identifier.integerValue : -1
    }
}