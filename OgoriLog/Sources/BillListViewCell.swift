//
//  BillListViewCell.swift
//  OgoriLog
//
//  Created by yokomotod on 2/28/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit

class BillListViewCell: UITableViewCell {

    var timeStampLabel: UILabel!
    var titleLabel: UILabel!
    var amountLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
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

        let titleLabel = UILabel()
        titleLabel.textColor = ColorScheme.normalTextColor()
        self.contentView.addSubview(titleLabel)

        let amountLabel = UILabel()
        amountLabel.textAlignment = .Right
        self.contentView.addSubview(amountLabel)

        timeStampLabel.snp_makeConstraints { make in
            make.height.equalTo(20.0)
            make.top.equalTo(timeStampLabel.superview!.snp_topMargin)
            make.left.equalTo(timeStampLabel.superview!.snp_leftMargin)
        }

        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(timeStampLabel.snp_bottom).offset(8)

            make.left.equalTo(titleLabel.superview!.snp_leftMargin)
            make.bottom.equalTo(titleLabel.superview!.snp_bottomMargin)
        }
        // FIXME: due to iOS8 SDK bug, UILayoutPriorityDefaultLow can't be used
        titleLabel.setContentCompressionResistancePriority(250, forAxis: UILayoutConstraintAxis.Horizontal)

        amountLabel.snp_makeConstraints { make in
            make.left.equalTo(titleLabel.snp_right).offset(20)

            make.right.equalTo(amountLabel.superview!.snp_rightMargin)
            make.bottom.equalTo(amountLabel.superview!.snp_bottomMargin)
        }

        self.timeStampLabel = timeStampLabel
        self.titleLabel = titleLabel
        self.amountLabel = amountLabel
    }

    func configureView(bill: Bill) {
        self.timeStampLabel.text = formatDateString(bill.timeStamp)

        self.titleLabel.text = bill.title

        self.amountLabel.text = formatBillString(abs(bill.amount.doubleValue))

        if bill.amount.doubleValue >= 0 {
            self.amountLabel.textColor = ColorScheme.positiveColor()
        } else {
            self.amountLabel.textColor = ColorScheme.negativeColor()
        }
    }
}
