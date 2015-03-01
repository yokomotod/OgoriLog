//
//  StringUtil.swift
//  OgoriLog
//
//  Created by yokomotod on 2/28/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import Foundation


func formatBillString(double: Double) -> String {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
    formatter.groupingSeparator = ","
    formatter.groupingSize = 3

    let numberString = formatter.stringFromNumber(NSNumber(double: double)) ?? "0"
    return String(format: "%@ %@", NSLocalizedString("BillPrefix", comment: ""), numberString)
}

func formatDoubleString(double: Double) -> String {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle

    return formatter.stringFromNumber(NSNumber(double: double)) ?? "0"
}

func formatDateString(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"

    return formatter.stringFromDate(date)
}