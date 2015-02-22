//
//  FriendDetailViewController.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit
import CoreData

class FriendDetailViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext? = nil
    var totalBillButton: UIButton!


    var friend: Friend? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let friend = self.friend {
            if let button = self.totalBillButton {
                button.setTitle(friend.totalBill.stringValue, forState: .Normal)
            }
        }
    }

    override func loadView() {
        super.loadView()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addBill:")

        self.view.backgroundColor = UIColor.whiteColor()
        self.totalBillButton = UIButton.buttonWithType(.System) as UIButton
        self.totalBillButton.frame =  CGRectMake(50, 100, 300, 50)
        self.totalBillButton.addTarget(self, action: "listBills:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.totalBillButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addBill(sender: AnyObject) {
        let controller = BillAddViewController.billAddViewController()
        controller.managedObjectContext = self.managedObjectContext
        controller.friend = self.friend
        self.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }

    func listBills(sender: AnyObject) {
        let controller = BillListViewController()
        controller.managedObjectContext = self.managedObjectContext
        controller.friend = self.friend
        self.showDetailViewController(controller, sender: self)
    }

}

