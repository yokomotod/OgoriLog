//
//  AcknowledgementViewController.swift
//  OgoriLog
//
//  Created by yokomotod on 3/1/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit

class AcknowledgementViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        let textView = UITextView()
        textView.editable = false
        textView.text = self.acknowledgementsText()
        textView.textColor = ColorScheme.weakTextColor()
        textView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        textView.font = UIFont.systemFontOfSize(15)
        self.view.addSubview(textView)

        textView.snp_makeConstraints { make in
            make.edges.equalTo(textView.superview!)
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func acknowledgementsText() -> String {
        var textArray = Array<String>()
        if let acknowledgementsArray = self.acknowledgementsArray() {
            for acknowledgements in acknowledgementsArray {
                let title = acknowledgements["Title"] ?? ""
                let footerText = acknowledgements["FooterText"] ?? ""
                let text = title + "\n\n" + footerText
                textArray.append(text)
            }
        }
        return join("\n\n\n",textArray)
    }

    func acknowledgementsArray() -> Array<Dictionary<String, String>>? {
        let settingsBundlePath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Settings.bundle")
        let settingsBundle = NSBundle(path: settingsBundlePath)
        if let file = settingsBundle?.pathForResource("Acknowledgements", ofType: "plist") {
            if let infoPlistDictionary =  NSDictionary(contentsOfFile: file) as? Dictionary<String, AnyObject> {
                return infoPlistDictionary["PreferenceSpecifiers"] as? Array
            }
        }
        return nil
    }

}
