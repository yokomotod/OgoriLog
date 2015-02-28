//
//  BillAddViewController.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit
import CoreData

class BillAddViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext? = nil
    var friend: Friend?
    var bill: Bill?

    var amountTextField: UITextField?
    var titleTextField: UITextField?

    class func billAddViewController() -> Self {
        return self.init(style: .Grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem().bk_initWithBarButtonSystemItem(.Cancel, handler: { sender in
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

    func give(sender: AnyObject) {
        self.save(1)
    }

    func get(sender: AnyObject) {
        self.save(-1)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 3
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.selectionStyle = .None

        switch (indexPath.row) {
        case 0:
            let textField = UITextField()
            textField.textAlignment = .Center
            textField.placeholder = "¥ 0"
            textField.keyboardType = .DecimalPad
            if self.bill != nil {
                textField.text = NSString(format: "%d", Int(fabs(self.bill!.amount.doubleValue)))
            }
            cell.contentView.addSubview(textField)
            textField.snp_makeConstraints { make in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.left.equalTo(cell.contentView.snp_leftMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)
                make.right.equalTo(cell.contentView.snp_rightMargin)
            }

            self.amountTextField = textField

        case 1:
            let textField = UITextField()
            textField.textAlignment = .Center
            textField.placeholder = "Title (Optional)"
            if self.bill?.title != nil {
                textField.text = self.bill!.title!
            }
            cell.contentView.addSubview(textField)
            textField.snp_makeConstraints { make in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.left.equalTo(cell.contentView.snp_leftMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)
                make.right.equalTo(cell.contentView.snp_rightMargin)
            }

            self.titleTextField = textField
            
        case 2:
            let giveButton = UIButton.buttonWithType(.System) as UIButton
            giveButton.setTitle("Give", forState: .Normal)
            giveButton.bk_addEventHandler({ [weak self](sender) in
                self?.give(sender)
                return
                }, forControlEvents: .TouchUpInside)
            let getButton = UIButton.buttonWithType(.System) as UIButton
            getButton.setTitle("Get", forState: .Normal)
            getButton.bk_addEventHandler({ [weak self](sender) in
                self?.get(sender)
                return
                }, forControlEvents: .TouchUpInside)
            cell.contentView.addSubview(giveButton)
            cell.contentView.addSubview(getButton)
            giveButton.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)

                make.left.equalTo(cell.contentView.snp_leftMargin)
            })
            getButton.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)

                make.left.equalTo(giveButton.snp_right)
                make.width.equalTo(giveButton.snp_width)
                make.right.equalTo(cell.contentView.snp_rightMargin)
            })
        default:
            break
        }

        return cell
    }

    func save(multiplier: Double) {
        if self.amountTextField == nil || self.amountTextField!.text.isEmpty {
            return
        }

        let amount = atof(self.amountTextField!.text) * multiplier
        let title = self.titleTextField?.text

        if self.bill != nil {
            if self.bill!.amount != amount || self.bill!.title != title {
                self.bill!.amount = amount
                self.bill!.title = title

                self.friend!.totalBill = self.friend!.calculateTotalBill()

                // Save the context.
                var error: NSError? = nil
                if !self.managedObjectContext!.save(&error) {
                    abort()
                }
            }
        } else {
            self.friend?.addNewBill(amount, title)
            // Save the context.
            var error: NSError? = nil
            if !self.managedObjectContext!.save(&error) {
                abort()
            }
        }

        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
