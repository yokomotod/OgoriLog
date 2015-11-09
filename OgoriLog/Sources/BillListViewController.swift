//
//  BillListViewController.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit
import CoreData

class BillListViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var friend: Friend!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.tableView.registerClass(BillListViewCell.self, forCellReuseIdentifier: "Cell")

        self.updateControlState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        self.updateControlState()
    }
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! BillListViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = CoreDataManager.sharedInstance.temporaryManagedObjectContext()
            let fetchedResultsController = self.fetchedResultsController
            let friend = self.friend
            context.performBlock { () in
                let bill = fetchedResultsController.objectAtIndexPath(indexPath) as! Bill
                context.deleteObject(context.objectWithID(bill.objectID))

                friend.totalBill = friend.calculateTotalBill(context)

                CoreDataManager.sharedInstance.saveContext(context)
            }
        }
    }

    func configureCell(cell: BillListViewCell, atIndexPath indexPath: NSIndexPath) {
        let bill = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Bill
        cell.configureView(bill)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = BillAddViewController()
        controller.friend = self.friend
        controller.bill = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Bill

        self.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
    // MARK: - Fetched results controller

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let context = CoreDataManager.sharedInstance.mainManagedObjectContext

        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        fetchRequest.entity = NSEntityDescription.entityForName("Bill", inManagedObjectContext: context)

        fetchRequest.predicate = NSPredicate(format: "friend = %@", context.objectWithID(self.friend.objectID))

        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20

        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [sortDescriptor]

        fetchRequest.sortDescriptors = [sortDescriptor]

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: String(format: "BillList.%ld", self.friend.identifier.integerValue))
        aFetchedResultsController.delegate = self

        do {
            try aFetchedResultsController.performFetch()
        } catch let error as NSError {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        } catch {
            fatalError()
        }

        return aFetchedResultsController
    }()

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! BillListViewCell
            self.configureCell(cell, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()

        self.updateControlState()
    }

    // MARK: - Private

    func updateControlState() {

        if self.editing {
            // Enabled during editing
            self.navigationItem.rightBarButtonItem?.enabled = true
            return
        }

        if let numberOfObjects = self.fetchedResultsController.sections?.first?.numberOfObjects {
            if numberOfObjects > 0 {
                // Enabled if friend exists
                self.navigationItem.rightBarButtonItem?.enabled = true
                return
            }
        }

        // Otherwise, Disabled
        self.navigationItem.rightBarButtonItem?.enabled = false
    }

}

