//
//  FriendAddViewController.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit
import CoreData

class FriendAddViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext? = nil
    var friend: Friend?

    var nameTextField: UITextField?

    class func friendAddViewController() -> Self {
        return self.init(style: .Grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem().bk_initWithBarButtonSystemItem(.Cancel, handler: { (sender) -> Void in
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }) as? UIBarButtonItem


        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Action

    func add(sender: AnyObject) {
        if self.nameTextField == nil || self.nameTextField!.text.isEmpty {
            return
        }

        let name = self.nameTextField!.text

        if self.friend != nil {
            if self.friend!.name != name {
                self.friend!.name = name

                // Save the context.
                var error: NSError? = nil
                if !self.managedObjectContext!.save(&error) {
                    abort()
                }
            }

        } else {
            Friend.friendWithName(name, context:self.managedObjectContext!)
            // Save the context.
            var error: NSError? = nil
            if !self.managedObjectContext!.save(&error) {
                abort()
            }
        }

        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 2
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.selectionStyle = .None

        switch (indexPath.row) {
        case 0:
            let textField = UITextField()
            textField.textAlignment = .Center
            textField.placeholder = NSLocalizedString("Name", comment: "")
            if self.friend != nil {
                textField.text = self.friend!.name
            }
            cell.contentView.addSubview(textField)
            textField.snp_makeConstraints { make in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.left.equalTo(cell.contentView.snp_leftMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)
                make.right.equalTo(cell.contentView.snp_rightMargin)
            }

            self.nameTextField = textField

        case 1:
            let button = UIButton.buttonWithType(.System) as UIButton
            button.setTitle(NSLocalizedString("Save", comment: ""), forState: .Normal)
            button.bk_addEventHandler({ [weak self](sender) in
                self?.add(sender)
                return
            }, forControlEvents: .TouchUpInside)
            cell.contentView.addSubview(button)
            button.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.left.equalTo(cell.contentView.snp_leftMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)
                make.right.equalTo(cell.contentView.snp_rightMargin)
            })
        default:
            break
        }

        return cell
    }

}
