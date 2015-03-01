//
//  FriendListViewController.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit
import CoreData

class FriendListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    var tableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func loadView() {
        super.loadView()

        self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.view.backgroundColor = UIColor.whiteColor()

        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(FriendListViewCell.self, forCellReuseIdentifier: "Cell")

        let addFriendButton = UIButton.buttonWithType(.System) as UIButton
        addFriendButton.setTitle(NSLocalizedString("Add Friend", comment: ""), forState: .Normal)
        addFriendButton.bk_addEventHandler({ sender in
            let controller = FriendAddViewController.friendAddViewController()
            self.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
            }, forControlEvents: .TouchUpInside)

        self.view.addSubview(tableView)
        self.view.addSubview(addFriendButton)

        tableView.snp_makeConstraints { make in
            make.top.equalTo(tableView.superview!.snp_top)
            make.left.equalTo(tableView.superview!.snp_left)
            make.right.equalTo(tableView.superview!.snp_right)
            return
        }
        addFriendButton.snp_makeConstraints { make in
            make.height.equalTo(60.0)

            make.top.equalTo(tableView.snp_bottom)
            make.left.equalTo(addFriendButton.superview!.snp_left)
            make.right.equalTo(addFriendButton.superview!.snp_right)
            make.bottom.equalTo(addFriendButton.superview!.snp_bottom)
        }

        self.tableView = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        self.tableView.setEditing(editing, animated: animated)
    }

    // MARK: - Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as FriendListViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = CoreDataManager.sharedInstance.temporaryManagedObjectContext()
            let friend = self.fetchedResultsController.objectAtIndexPath(indexPath) as Friend
            context.performBlock({ () in
                context.deleteObject(context.objectWithID(friend.objectID))

                CoreDataManager.sharedInstance.saveContext(context)
            })
        }
    }

    func configureCell(cell: FriendListViewCell, atIndexPath indexPath: NSIndexPath) {
        let friend = self.fetchedResultsController.objectAtIndexPath(indexPath) as Friend

        cell.configureView(friend)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friend = self.fetchedResultsController.objectAtIndexPath(indexPath) as Friend
        let controller = FriendDetailViewController()
        controller.friend = friend
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true

        self.showDetailViewController(UINavigationController(rootViewController: controller), sender: self)
    }

    // MARK: - Fetched results controller

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let context = CoreDataManager.sharedInstance.mainManagedObjectContext

        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        fetchRequest.entity = NSEntityDescription.entityForName("Friend", inManagedObjectContext: context)
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "FriendList")
        aFetchedResultsController.delegate = self

        var error: NSError? = nil
        if !aFetchedResultsController.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
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
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as FriendListViewCell
                self.configureCell(cell, atIndexPath: indexPath!)
            case .Move:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}

