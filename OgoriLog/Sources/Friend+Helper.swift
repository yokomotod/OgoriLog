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

    class func friendWithName(name: String, context: NSManagedObjectContext) {
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as Friend

        // If appropriate, configure the new managed object.
        newManagedObject.identifier = newManagedObject.lastIdentifier() + 1;
        newManagedObject.name = name
        newManagedObject.timeStamp = NSDate()
        newManagedObject.totalBill = 0.0;
    }

    func lastIdentifier() -> Int {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Friend", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1

        let lastFriend = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil)?.first as Friend?
        return lastFriend != nil ? lastFriend!.identifier.integerValue : -1
    }

    func addNewBill(amount: Double, _ title: String?) {
        let newBill = NSEntityDescription.insertNewObjectForEntityForName("Bill", inManagedObjectContext: self.managedObjectContext!) as Bill

        // If appropriate, configure the new managed object.
        newBill.identifier = newBill.lastIdentifier() + 1
        newBill.amount = amount
        newBill.timeStamp = NSDate()
        newBill.title = title;
        newBill.friend = self

        self.totalBill = self.calculateTotalBill()
    }

    func calculateTotalBill() -> Double {
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Bill", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity

        fetchRequest.predicate = NSPredicate(format: "friend = %@", self)

        let bills = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as Array<Bill>

        var totalBill = 0.0
        for bill in bills {
            totalBill += bill.amount.doubleValue
        }

        return totalBill
    }
}