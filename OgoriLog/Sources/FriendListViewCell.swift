//
//  FriendListViewCell.swift
//  OgoriLog
//
//  Created by yokomotod on 2/28/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit

class FriendListViewCell: UITableViewCell {

    var timeStampLabel: UILabel!
    var nameLabel: UILabel!
    var totalBillLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    func setupView() {
        let timeStampLabel = UILabel()
        timeStampLabel.textColor = ColorScheme.weakTextColor()
        timeStampLabel.font = UIFont.systemFontOfSize(13)
        self.contentView.addSubview(timeStampLabel)

        let nameLabel = UILabel()
        nameLabel.textColor = ColorScheme.normalTextColor()
        self.contentView.addSubview(nameLabel)

        let totalBillLabel = UILabel()
        totalBillLabel.textAlignment = .Right
        self.contentView.addSubview(totalBillLabel)

        timeStampLabel.snp_makeConstraints { make in
            make.height.equalTo(20.0)
            make.top.equalTo(timeStampLabel.superview!.snp_topMargin)
            make.left.equalTo(timeStampLabel.superview!.snp_leftMargin)
        }

        nameLabel.snp_makeConstraints { make in
            make.top.equalTo(timeStampLabel.snp_bottom).width.offset(8)

            make.left.equalTo(nameLabel.superview!.snp_leftMargin)
            make.bottom.equalTo(nameLabel.superview!.snp_bottomMargin)
        }

        totalBillLabel.snp_makeConstraints { make in
            make.left.equalTo(nameLabel.snp_right).offset(20)

            make.right.equalTo(totalBillLabel.superview!.snp_rightMargin)
            make.bottom.equalTo(totalBillLabel.superview!.snp_bottomMargin)
        }

        self.timeStampLabel = timeStampLabel
        self.nameLabel = nameLabel
        self.totalBillLabel = totalBillLabel
    }

    func configureView(friend: Friend) {
        self.timeStampLabel.text = formatDateString(friend.timeStamp)

        self.nameLabel.text = friend.name

        self.totalBillLabel.text = formatBillString(abs(friend.totalBill.doubleValue))

        if friend.totalBill.doubleValue > 0 {
            self.totalBillLabel.textColor = ColorScheme.positiveColor()
        } else if friend.totalBill.doubleValue < 0 {
            self.totalBillLabel.textColor = ColorScheme.negativeColor()
        } else {
            self.totalBillLabel.textColor = ColorScheme.weakTextColor()
        }
    }
}
