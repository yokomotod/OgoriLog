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
    var nameButton: UIButton?
    var totalBillButton: UIButton?


    var friend: Friend? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let friend = self.friend {
            if let button = self.nameButton {
                button.setTitle(friend.name, forState: .Normal)
            }
            if let button = self.totalBillButton {
                button.setTitle(friend.totalBill.stringValue, forState: .Normal)
            }
        }
    }

    override func loadView() {
        super.loadView()

        self.view.backgroundColor = UIColor.whiteColor()

        let nameButton = UIButton.buttonWithType(.System) as UIButton
        nameButton.bk_addEventHandler({ sender in
            let controller = FriendAddViewController.friendAddViewController()
            controller.managedObjectContext = self.managedObjectContext
            controller.friend = self.friend
            self.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
        }, forControlEvents: .TouchUpInside)

        let totalBillButton = UIButton.buttonWithType(.System) as UIButton
        totalBillButton.bk_addEventHandler({ sender in
            let controller = BillListViewController()
            controller.managedObjectContext = self.managedObjectContext
            controller.friend = self.friend
            self.showDetailViewController(controller, sender: self)
        }, forControlEvents: .TouchUpInside)

        let addBillButton = UIButton.buttonWithType(.System) as UIButton
        addBillButton.setTitle("Add Bill", forState: .Normal)
        addBillButton.bk_addEventHandler({ sender in
            let controller = BillAddViewController.billAddViewController()
            controller.managedObjectContext = self.managedObjectContext
            controller.friend = self.friend
            self.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
            }, forControlEvents: .TouchUpInside)

        self.view.addSubview(nameButton)
        self.view.addSubview(totalBillButton)
        self.view.addSubview(addBillButton)
        nameButton.snp_makeConstraints { make in
            make.centerX.equalTo(nameButton.superview!)
            make.bottom.equalTo(totalBillButton.snp_top)
        }
        totalBillButton.snp_makeConstraints { make in
            make.centerX.equalTo(nameButton.superview!)
            make.centerY.equalTo(nameButton.superview!)
        }
        addBillButton.snp_makeConstraints { make in
            make.height.equalTo(60.0)

            make.left.equalTo(addBillButton.superview!.snp_left)
            make.right.equalTo(addBillButton.superview!.snp_right)
            make.bottom.equalTo(addBillButton.superview!.snp_bottom)
        }

        self.nameButton = nameButton
        self.totalBillButton = totalBillButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.configureView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

