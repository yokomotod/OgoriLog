//
//  BillAddViewController.swift
//  OgoriLog
//
//  Created by yokomotod on 2/22/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit

class BillAddViewController: UITableViewController {

    var friend: Friend!
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

        self.navigationItem.leftBarButtonItem = UIBarButtonItem().bk_initWithBarButtonSystemItem(.Cancel) { [weak self] sender in
            self?.resignAllFirstResponder()
            self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        } as? UIBarButtonItem

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
            textField.placeholder = String(format: "%@ 0", NSLocalizedString("BillPrefix", comment: ""))
            textField.keyboardType = .DecimalPad
            textField.returnKeyType = .Done
            textField.bk_shouldReturnBlock = { textField -> Bool in
                textField.resignFirstResponder()
                return true
            }
            if let bill = self.bill {
                textField.text = formatDoubleString(abs(bill.amount.doubleValue))
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
            if let title = self.bill?.title {
                textField.text = title
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
            giveButton.setTitleColor(ColorScheme.positiveColor(), forState: .Normal)
            giveButton.setTitleColor(ColorScheme.weakTextColor(), forState: .Disabled)
            giveButton.bk_addEventHandler({ [weak self] sender in
                self?.give(sender)
                return
                }, forControlEvents: .TouchUpInside)
            let getButton = UIButton.buttonWithType(.System) as UIButton
            getButton.setTitle(NSLocalizedString("Get", comment: ""), forState: .Normal)
            getButton.setTitleColor(ColorScheme.negativeColor(), forState: .Normal)
            getButton.setTitleColor(ColorScheme.weakTextColor(), forState: .Disabled)
            getButton.bk_addEventHandler({ [weak self] sender in
                self?.get(sender)
                return
                }, forControlEvents: .TouchUpInside)
            if let bill = self.bill {
                if bill.amount.doubleValue >= 0 {
                    giveButton.titleLabel?.font = UIFont.systemFontOfSize(UIFont.buttonFontSize())
                } else {
                    getButton.titleLabel?.font = UIFont.systemFontOfSize(UIFont.buttonFontSize())
                }
            }
            cell.contentView.addSubview(giveButton)
            cell.contentView.addSubview(getButton)
            giveButton.snp_makeConstraints { make in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)

                make.left.equalTo(cell.contentView.snp_leftMargin)
            }
            getButton.snp_makeConstraints { make in
                make.top.equalTo(cell.contentView.snp_topMargin)
                make.bottom.equalTo(cell.contentView.snp_bottomMargin)

                make.left.equalTo(giveButton.snp_right)
                make.width.equalTo(giveButton.snp_width)
                make.right.equalTo(cell.contentView.snp_rightMargin)
            }
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

        if let bill = self.bill {
            if bill.amount != amount || bill.title != title {
                let context = CoreDataManager.sharedInstance.temporaryManagedObjectContext()
                let friend = self.friend
                context.performBlock { () in
                    bill.amount = amount
                    bill.title = title

                    friend.totalBill = friend.calculateTotalBill()

                    CoreDataManager.sharedInstance.saveContext(context)
                }
            }
        } else {
            let context = CoreDataManager.sharedInstance.temporaryManagedObjectContext()
            let friend = self.friend
            context.performBlock { () in
                friend.createNewBill(amount, title)
                CoreDataManager.sharedInstance.saveContext(context)
            }
        }

        self.resignAllFirstResponder()
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func resignAllFirstResponder() {
        if let amountTextField = self.amountTextField {
            if amountTextField.isFirstResponder() {
                amountTextField.resignFirstResponder()
            }
        }

        if let titleTextField = self.titleTextField {
            if titleTextField.isFirstResponder() {
                titleTextField.resignFirstResponder()
            }
        }
    }
}
