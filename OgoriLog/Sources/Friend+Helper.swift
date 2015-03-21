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

    class func lastIdentifier(context: NSManagedObjectContext) -> Int {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Friend", inManagedObjectContext: context)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1

        let lastFriend = context.executeFetchRequest(fetchRequest, error: nil)?.first as Friend?
        return lastFriend != nil ? lastFriend!.identifier.integerValue : -1
    }

    class func createNewFriend(context: NSManagedObjectContext, name: String) -> Friend {
        let newFriend = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as Friend

        // If appropriate, configure the new managed object.
        newFriend.identifier = Friend.lastIdentifier(context) + 1;
        newFriend.name = name
        newFriend.timeStamp = NSDate()
        newFriend.totalBill = 0.0;

        return newFriend
    }

    func createNewBill(context: NSManagedObjectContext, amount: Double, title: String?) -> Bill {
        let newBill = NSEntityDescription.insertNewObjectForEntityForName("Bill", inManagedObjectContext: context) as Bill

        // If appropriate, configure the new managed object.
        newBill.identifier = Bill.lastIdentifier(context) + 1
        newBill.amount = amount
        newBill.timeStamp = NSDate()
        newBill.title = title;
        newBill.friend = context.objectWithID(self.objectID) as Friend

        self.totalBill = self.calculateTotalBill(context)

        return newBill
    }

    func calculateTotalBill(context: NSManagedObjectContext) -> Double {

        let billArray = self.billArray(context)
        var totalBill = 0.0
        for bill in billArray {
            totalBill += bill.amount.doubleValue
        }

        return totalBill
    }

    func billArray(context: NSManagedObjectContext) -> Array<Bill> {
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Bill", inManagedObjectContext: context)
        fetchRequest.entity = entity

        fetchRequest.predicate = NSPredicate(format: "friend = %@", self)

        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        return context.executeFetchRequest(fetchRequest, error: nil) as Array<Bill>

    }
}
