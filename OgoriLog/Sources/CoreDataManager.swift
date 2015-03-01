//
//  CoreDataManager.swift
//  OgoriLog
//
//  Created by yokomotod on 3/1/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import CoreData

final class CoreDataManager {

    // MARK: Singleton

    private init() {}

    class var sharedInstance: CoreDataManager {
        // FIXME: use static property after Swift 1.2
        struct Singleton {
            static let instance = CoreDataManager()
        }
        return Singleton.instance
    }

    // MARK: Core Data


    lazy var writeManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()

    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.writeManagedObjectContext
        return managedObjectContext
        }()

    func temporaryManagedObjectContext() -> NSManagedObjectContext {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = self.mainManagedObjectContext
        return managedObjectContext
    }

    func saveContext(temporaryContext: NSManagedObjectContext) {
        var error: NSError? = nil
        if !temporaryContext.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }

        self.mainManagedObjectContext.performBlock({ () in
            var error: NSError? = nil
            if !self.mainManagedObjectContext.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }

            self.writeManagedObjectContext.performBlock({ () in
                var error: NSError? = nil
                if !self.writeManagedObjectContext.save(&error) {
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            })
        })
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "net.bookside.Ogorilog" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("OgoriLog", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("OgoriLog.sqlite")
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ];
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }

        return coordinator
        }()
}
