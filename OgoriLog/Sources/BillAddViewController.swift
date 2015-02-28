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
    var giveButton: UIButton?
    var getButton: UIButton?

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
            textField.placeholder = NSLocalizedString("Amount", comment: "")
            textField.keyboardType = .DecimalPad
            textField.returnKeyType = .Done
            textField.bk_shouldReturnBlock = { textField -> Bool in
                textField.resignFirstResponder()
                return true
            }
            if self.bill != nil {
                textField.text = NSString(format: "%d", Int(fabs(self.bill!.amount.doubleValue)))
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

            self.amountTextField = textField

        case 1:
            let textField = UITextField()
            textField.textAlignment = .Center
            textField.placeholder = NSLocalizedString("Title", comment: "")
            textField.returnKeyType = .Done
            textField.bk_shouldReturnBlock = { textField -> Bool in
                textField.resignFirstResponder()
                return true
            }
            if self.bill?.title != nil {
                textField.text = self.bill!.title!
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

            self.titleTextField = textField
            
        case 2:
            let giveButton = UIButton.buttonWithType(.System) as UIButton
            giveButton.setTitle(NSLocalizedString("Give", comment: ""), forState: .Normal)
            giveButton.bk_addEventHandler({ [weak self](sender) in
                self?.give(sender)
                return
                }, forControlEvents: .TouchUpInside)
            let getButton = UIButton.buttonWithType(.System) as UIButton
            getButton.setTitle(NSLocalizedString("Get", comment: ""), forState: .Normal)
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
            self.giveButton = giveButton
            self.getButton = getButton

            self.updateControlState()
        default:
            break
        }

        return cell
    }

    func updateControlState() {
        if let amountTextField = self.amountTextField {
            let amount = atof(amountTextField.text)
            if 0 < amount && amount < 1000000 {
                if let titleTextField = self.titleTextField {
                    let count = countElements(titleTextField.text)
                    if 0 <= count && count < 15 {
                        self.giveButton?.enabled = true
                        self.getButton?.enabled = true
                        return
                    }
                }
            }
        }
        self.giveButton?.enabled = false
        self.getButton?.enabled = false
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
