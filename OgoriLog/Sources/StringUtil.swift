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

    return String(format: "¥ %@", formatter.stringFromNumber(NSNumber(double: double))!)
}

func formatDateString(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm::ss"

    return formatter.stringFromDate(date)
}