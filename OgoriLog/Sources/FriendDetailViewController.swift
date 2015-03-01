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

    var friend: Friend!

    var nameButton: UIButton?
    var graphView: FriendDetailGraphWrapperView?
    var totalBillButton: UIButton?

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
    }

    override func loadView() {
        super.loadView()

        self.view.backgroundColor = UIColor.whiteColor()

        let nameButton = UIButton.buttonWithType(.System) as UIButton
        nameButton.titleLabel?.font = UIFont.systemFontOfSize(20)
        nameButton.bk_addEventHandler({ [weak self] sender in
            let controller = FriendAddViewController.friendAddViewController()
            controller.friend = self?.friend
            self?.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
        }, forControlEvents: .TouchUpInside)

        let graphView = FriendDetailGraphWrapperView(friend: self.friend) { [weak self] in
            self?.presentBillList()
            return
        }
        self.graphView = graphView

        let totalBillButton = UIButton.buttonWithType(.System) as UIButton
        totalBillButton.bk_addEventHandler({ [weak self] sender in
            self?.presentBillList()
            return
        }, forControlEvents: .TouchUpInside)

        let addBillButton = UIButton.buttonWithType(.System) as UIButton
        addBillButton.setTitle(NSLocalizedString("Add Bill", comment: ""), forState: .Normal)
        addBillButton.bk_addEventHandler({ [weak self] sender in
            let controller = BillAddViewController.billAddViewController()
            controller.friend = self?.friend
            self?.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
        }, forControlEvents: .TouchUpInside)

        self.view.addSubview(nameButton)
        self.view.addSubview(graphView)
        self.view.addSubview(totalBillButton)
        self.view.addSubview(addBillButton)
        nameButton.snp_makeConstraints { [weak self] make in
            make.centerX.equalTo(nameButton.superview!)
            make.top.equalTo(self!.topLayoutGuide).with.offset(70)
            make.height.equalTo(24)
        }
        graphView.snp_makeConstraints { make in
            make.top.greaterThanOrEqualTo(nameButton.snp_bottom).with.offset(20)
            make.left.equalTo(addBillButton.superview!.snp_leftMargin)
            make.right.equalTo(addBillButton.superview!.snp_rightMargin)
            make.centerY.equalTo(graphView.superview!.snp_centerY).with.priority(999)
            make.height.equalTo(graphView.snp_width).and.multipliedBy(9.0/16.0).with.priority(999)
            make.height.lessThanOrEqualTo(graphView.snp_width).and.multipliedBy(9.0/16.0)  // 16:9
        }

        totalBillButton.snp_makeConstraints { make in
            make.centerX.equalTo(nameButton.superview!)
            make.top.equalTo(graphView.snp_bottom).with.offset(20)
            make.bottom.lessThanOrEqualTo(addBillButton.snp_top).with.offset(-20)
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
                    status = NSLocalizedString("Giving", comment: "")
                    button.setTitleColor(ColorScheme.positiveColor(), forState: .Normal)
                } else if totalBill < 0 {
                    status = NSLocalizedString("Getting", comment: "")
                    button.setTitleColor(ColorScheme.negativeColor(), forState: .Normal)
                } else {
                    status = NSLocalizedString("Even", comment: "")
                    button.setTitleColor(ColorScheme.weakTextColor(), forState: .Normal)
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
        controller.friend = self.friend
        self.showDetailViewController(controller, sender: self)
    }
}
