//
//  ColorScheme.swift
//  OgoriLog
//
//  Created by yokomotod on 2/28/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit

class ColorScheme: NSObject {

    class func positiveColor() -> UIColor {
        return rgb(0x0b, 0xd3, 0x18)
    }

    class func negativeColor() -> UIColor {
        return rgb(0xff, 0x2d, 0x55)
    }

    class func rgb(r: Int, _ g: Int, _ b: Int) -> UIColor {
        let red = CGFloat(r)/255.0
        let green = CGFloat(g)/255.0
        let blue = CGFloat(b)/255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
