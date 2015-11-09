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
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = self.mainManagedObjectContext
        return managedObjectContext
    }

    func saveContext(temporaryContext: NSManagedObjectContext) {
        do {
            try temporaryContext.save()
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        }

        self.mainManagedObjectContext.performBlock { () in
            do {
                try self.mainManagedObjectContext.save()
            } catch let error as NSError {
                NSLog("Unresolved error \(error), \(error.userInfo)")
                abort()
            } catch {
                fatalError()
            }

            self.writeManagedObjectContext.performBlock { () in
                do {
                    try self.writeManagedObjectContext.save()
                } catch let error as NSError {
                    NSLog("Unresolved error \(error), \(error.userInfo)")
                    abort()
                } catch {
                    fatalError()
                }
            }
        }
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "net.bookside.Ogorilog" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
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
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch let error as NSError {
            coordinator = nil
            // Report any error we got.
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        } catch {
            fatalError()
        }

        return coordinator
        }()
}
