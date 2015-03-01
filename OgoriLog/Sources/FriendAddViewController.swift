//
//  FriendAddViewController.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit

class FriendAddViewController: UITableViewController {

    var friend: Friend?

    var nameTextField: UITextField?
    var saveButton: UIButton?

    class func friendAddViewController() -> Self {
        return self.init(style: .Grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem().bk_initWithBarButtonSystemItem(.Cancel, handler: { [weak self] sender in
            self?.resignAllFirstResponder()
            self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
                let context = CoreDataManager.sharedInstance.temporaryManagedObjectContext()
                context.performBlock { () in
                    self.friend!.name = name
                    CoreDataManager.sharedInstance.saveContext(context)
                }
            }

        } else {
            let context = CoreDataManager.sharedInstance.temporaryManagedObjectContext()
            context.performBlock { () in
                Friend.friendWithName(name, context:context)
                CoreDataManager.sharedInstance.saveContext(context)
            }

        }

        self.resignAllFirstResponder()
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
            textField.returnKeyType = .Done
            textField.bk_shouldReturnBlock = { textField -> Bool in
                textField.resignFirstResponder()
                return true
            }
            if self.friend != nil {
                textField.text = self.friend!.name
            }
            textField.bk_addEventHandler({ [weak self] sender in
                self?.updateControlState()
                return
                }, forControlEvents: .EditingChanged)
            cell.contentView.addSubview(textField)
            textField.snp_makeConstraints { make in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.left.equalTo(cell.contentView.snp_leftMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)
                make.right.equalTo(cell.contentView.snp_rightMargin)
            }

            self.nameTextField = textField

        case 1:
            let saveButton = UIButton.buttonWithType(.System) as UIButton
            saveButton.setTitle(NSLocalizedString("Save", comment: ""), forState: .Normal)
            saveButton.bk_addEventHandler({ [weak self](sender) in
                self?.add(sender)
                return
            }, forControlEvents: .TouchUpInside)
            cell.contentView.addSubview(saveButton)
            saveButton.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.left.equalTo(cell.contentView.snp_leftMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)
                make.right.equalTo(cell.contentView.snp_rightMargin)
            })
            self.saveButton = saveButton

            self.updateControlState()
        default:
            break
        }

        return cell
    }

    func updateControlState() {
        if let nameTextField = self.nameTextField {
            let count = countElements(nameTextField.text)
            if 0 < count && count <= 15 {
                self.saveButton?.enabled = true
                return
            }
        }

        self.saveButton?.enabled = false
    }

    func resignAllFirstResponder() {
        if let nameTextField = self.nameTextField {
            if nameTextField.isFirstResponder() {
                nameTextField.resignFirstResponder()
            }
        }
    }
}
