//
//  AboutViewController.swift
//  OgoriLog
//
//  Created by yokomotod on 3/1/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController {

    init() {
        super.init(style: .Grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("About", comment: "")
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.row) {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("Value1Cell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Value1Cell")
            }

            // Configure the cell...
            if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
                cell?.textLabel?.text = NSLocalizedString("Version", comment: "")
                cell?.detailTextLabel?.text = version
            }
            cell?.selectionStyle = .None
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.textLabel?.text = NSLocalizedString("Acknowledgements", comment: "")
            cell.accessoryType = .DisclosureIndicator
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 1:
            let controller = AcknowledgementViewController()
            self.showViewController(controller, sender: self)
        default:
            break
        }
    }
}
