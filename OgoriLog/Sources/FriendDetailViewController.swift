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
    var graphView: FriendDetailGraphWrapperView?
    var totalBillButton: UIButton?


    var friend: Friend! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
    }

    override func loadView() {
        super.loadView()

        self.view.backgroundColor = UIColor.whiteColor()

        let nameButton = UIButton.buttonWithType(.System) as UIButton
        nameButton.bk_addEventHandler({ [weak self] sender in
            let controller = FriendAddViewController.friendAddViewController()
            controller.managedObjectContext = self?.managedObjectContext
            controller.friend = self?.friend
            self?.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
        }, forControlEvents: .TouchUpInside)

        let graphView = FriendDetailGraphWrapperView(friend: self.friend, touchGraphBlock: { [weak self] in
            self?.presentBillList()
            return
        })
        self.graphView = graphView

        let totalBillButton = UIButton.buttonWithType(.System) as UIButton
        totalBillButton.bk_addEventHandler({ [weak self] sender in
            self?.presentBillList()
            return
        }, forControlEvents: .TouchUpInside)

        let addBillButton = UIButton.buttonWithType(.System) as UIButton
        addBillButton.setTitle("Add Bill", forState: .Normal)
        addBillButton.bk_addEventHandler({ [weak self] sender in
            let controller = BillAddViewController.billAddViewController()
            controller.managedObjectContext = self?.managedObjectContext
            controller.friend = self?.friend
            self?.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
        }, forControlEvents: .TouchUpInside)

        self.view.addSubview(nameButton)
        self.view.addSubview(graphView)
        self.view.addSubview(totalBillButton)
        self.view.addSubview(addBillButton)
        nameButton.snp_makeConstraints { [weak self] make in
            make.centerX.equalTo(nameButton.superview!)
            make.top.equalTo(self!.topLayoutGuide).with.offset(80)
        }
        graphView.snp_makeConstraints { make in
            make.left.equalTo(addBillButton.superview!.snp_leftMargin)
            make.right.equalTo(addBillButton.superview!.snp_rightMargin)
            make.width.equalTo(graphView.snp_height).and.multipliedBy(16.0/9.0)  // 16:9
            make.top.equalTo(nameButton.snp_bottom).with.offset(20)
        }

        totalBillButton.snp_makeConstraints { make in
            make.centerX.equalTo(nameButton.superview!)
            make.top.equalTo(graphView.snp_bottom).with.offset(20)
        }
        addBillButton.snp_makeConstraints { make in
            make.height.equalTo(60.0)

            make.left.equalTo(addBillButton.superview!.snp_left)
            make.right.equalTo(addBillButton.superview!.snp_right)
            make.bottom.equalTo(addBillButton.superview!.snp_bottom)
        }

        self.nameButton = nameButton
        self.graphView = graphView
        self.totalBillButton = totalBillButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] notification in
            self?.configureView()
            return
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.configureView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.graphView!.graphHostingView!.frame = CGRectMake(0, 0, self.graphView!.frame.size.width, self.graphView!.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let friend = self.friend {
            if let button = self.nameButton {
                button.setTitle(friend.name, forState: .Normal)
            }
            if let button = self.totalBillButton {
                let totalBill = friend.totalBill.doubleValue
                var status: String
                if totalBill > 0 {
                    status = "Giving"
                } else if totalBill < 0 {
                    status = "Getting"
                } else {
                    status = "Even"
                }

                let title = String(format: "%@ %@", formatBillString((abs(totalBill))), status)

                button.setTitle(title, forState: .Normal)
            }
            if let graph = self.graphView {
                graph.resetGraph(self.friend)
            }
        }
    }

    func presentBillList() {
        let controller = BillListViewController()
        controller.managedObjectContext = self.managedObjectContext
        controller.friend = self.friend
        self.showDetailViewController(controller, sender: self)
    }
}
