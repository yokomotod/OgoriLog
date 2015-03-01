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

    class func friendWithName(name: String, context: NSManagedObjectContext) -> Friend {
        let newFriend = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as Friend

        // If appropriate, configure the new managed object.
        newFriend.identifier = newFriend.lastIdentifier() + 1;
        newFriend.name = name
        newFriend.timeStamp = NSDate()
        newFriend.totalBill = 0.0;

        return newFriend
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

    func createNewBill(amount: Double, _ title: String?) -> Bill {
        let newBill = NSEntityDescription.insertNewObjectForEntityForName("Bill", inManagedObjectContext: self.managedObjectContext!) as Bill

        // If appropriate, configure the new managed object.
        newBill.identifier = newBill.lastIdentifier() + 1
        newBill.amount = amount
        newBill.timeStamp = NSDate()
        newBill.title = title;
        newBill.friend = self.managedObjectContext!.objectWithID(self.objectID) as Friend

        self.totalBill = self.calculateTotalBill()

        return newBill
    }

    func calculateTotalBill() -> Double {

        let billArray = self.billArray()
        var totalBill = 0.0
        for bill in billArray {
            totalBill += bill.amount.doubleValue
        }

        return totalBill
    }

    func billArray() -> Array<Bill> {
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Bill", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity

        fetchRequest.predicate = NSPredicate(format: "friend = %@", self)

        return self.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as Array<Bill>
    }

}
