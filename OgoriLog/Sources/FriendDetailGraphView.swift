//
//  FriendDetailGraphView.swift
//  OgoriLog
//
//  Created by yokomotod on 2/24/15.
//  Copyright (c) 2015 bookside.net. All rights reserved.
//

import UIKit
import CorePlot

class FriendDetailGraphWrapperView: UIView, CPTPlotSpaceDelegate, CPTPlotDataSource {

    var totalBillHistoryArray: Array<Double>!
    var maxTotalBill: Double!
    var minTotalBill: Double!

    var xPlotRange: CPTPlotRange!
    var yPlotRange: CPTPlotRange!
    var yMajorIntervalLength: Int!
    var lineColor : CPTColor!

    var didTouchGraphBlock: (() -> Void)!

    var graphHostingView: CPTGraphHostingView?

    convenience init(friend: Friend, touchGraphBlock: () -> Void) {
        self.init()

        self.resetGraph(friend)

        self.didTouchGraphBlock = touchGraphBlock
    }

    func resetGraph(friend: Friend) {
        self.analayzeBillArray(friend.billArray())

        if self.graphHostingView != nil {
            self.graphHostingView?.removeFromSuperview()
            self.graphHostingView = nil
        }

        self.graphHostingView = self.friendDetailGraphHostingView()

        self.addSubview(self.graphHostingView!)
    }

    // mark Plot Data Source Methods

    // グラフに使用する折れ線グラフのデータ数を返す
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        // 折れ線グラフのidentifierにより返すデータ数を変える（複数グラフを表示する場合に必要）
        return UInt(self.totalBillHistoryArray.count)
    }

    // グラフに使用する折れ線グラフのX軸とY軸のデータを返す
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject! {
        // 折れ線グラフのidentifierにより返すデータ数を変える（複数グラフを表示する場合に必要）
        switch (CPTScatterPlotField(rawValue: Int(fieldEnum))!) {
        case .X:  // X軸の場合
            return NSNumber(unsignedLong: idx)
        case .Y:  // Y軸の場合
            return self.totalBillHistoryArray[Int(idx)]
        }
    }

    // mark Plot Data Space Methods

    func plotSpace(space: CPTPlotSpace!, shouldHandlePointingDeviceDownEvent event: UIEvent!, atPoint point: CGPoint) -> Bool {

        self.didTouchGraphBlock()

        return true;
    }

    func analayzeBillArray(billArray: Array<Bill>) {
        var mutableArray = Array<Double>()

        var totalBill = 0.0
        var maxTotalBill = Double.infinity * -1
        var minTotalBill = Double.infinity

        mutableArray.append(totalBill)

        for bill in billArray {
            totalBill += bill.amount.doubleValue
            mutableArray.append(totalBill)
            if totalBill > maxTotalBill {
                maxTotalBill = totalBill
            }
            if totalBill < minTotalBill {
                minTotalBill = totalBill
            }
        }

        self.totalBillHistoryArray = mutableArray
        self.maxTotalBill = maxTotalBill
        self.minTotalBill = minTotalBill

        self.xPlotRange = self.calculateXPlotRange(plotCount: self.totalBillHistoryArray.count)
        self.yPlotRange = self.calculateYPlotRange(min: self.minTotalBill, max: self.maxTotalBill)
        self.yMajorIntervalLength = self.calculateYMajerIntervalLength(yPlotRangeLength: self.yPlotRange.length.integerValue)

        self.lineColor = self.calculateLineColor(totalBillArray: self.totalBillHistoryArray)
    }

    func calculateXPlotRange(# plotCount: Int) -> CPTPlotRange {
        let length = plotCount > 5 ? plotCount : 5
        return CPTPlotRange(location: 0, length:length)
    }

    func calculateYPlotRange(# min: Double, max: Double) -> CPTPlotRange {
        let bottom = min < 0 ? min : 0
        let top = max > 0 ? max : 0
        let diff = top - bottom
        let length = diff > 0 ? diff : 1000

        return CPTPlotRange(location:bottom * 1.1, length:length * 1.1)
    }

    func calculateYMajerIntervalLength(# yPlotRangeLength: Int) -> Int {
        var eff = yPlotRangeLength
        var sft = 1 as Int

        while (eff >= 10) {
            eff /= 10; sft *= 10;
        }
        while (eff < 1) {
            eff *= 10; sft /= 10;
        }

//        if eff >= 5 {
//            return sft
//        } else if eff >= 2 {
//            return sft / 2
//        } else {
//            return sft / 5
//        }

        return eff * sft / 2
    }

    func calculateLineColor(# totalBillArray: Array<Double>) -> CPTColor {
        let currentTotalBill = totalBillArray.last

        if currentTotalBill >= 0 {
            return CPTColor(CGColor: UIColor.greenColor().CGColor)
        } else {
            return CPTColor(CGColor: UIColor.redColor().CGColor)
        }
    }

    func friendDetailGraphHostingView() -> CPTGraphHostingView {
        // グラフを生成
        let graph = CPTXYGraph(frame: self.frame)

        // グラフのボーダー設定
        graph.plotAreaFrame.borderLineStyle = nil
        graph.plotAreaFrame.cornerRadius    = 0.0
        graph.plotAreaFrame.masksToBorder   = false

        // パディング
        graph.paddingLeft   = 0.0
        graph.paddingRight  = 0.0
        graph.paddingTop    = 0.0
        graph.paddingBottom = 0.0

        graph.plotAreaFrame.paddingLeft   = 30.0
//        graph.plotAreaFrame.paddingTop    = 60.0
//        graph.plotAreaFrame.paddingRight  = 20.0
//        graph.plotAreaFrame.paddingBottom = 65.0

        //プロット間隔の設定
        let plotSpace = graph.defaultPlotSpace as CPTXYPlotSpace
        plotSpace.delegate = self
        //Y軸は0〜10の値で設定
        plotSpace.yRange = self.yPlotRange
        //X軸は0〜10の値で設定
        plotSpace.xRange = self.xPlotRange

        // テキストスタイル
        //    CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle]
        //    textStyle.color                = [CPTColor colorWithComponentRed:0.447f green:0.443f blue:0.443f alpha:1.0f]
        //    textStyle.fontSize             = 13.0f
        //    textStyle.textAlignment        = CPTTextAlignmentCenter

        // ラインスタイル
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor            = CPTColor(componentRed: 0.788, green:0.792, blue:0.792, alpha:1.0)
        lineStyle.lineWidth            = 1.0

        // X軸のメモリ・ラベルなどの設定
        let axisSet = graph.axisSet as CPTXYAxisSet
        let x       = axisSet.xAxis
        x.axisLineStyle               = lineStyle      // X軸の線にラインスタイルを適用
        x.majorTickLineStyle          = lineStyle      // X軸の大きいメモリにラインスタイルを適用
        x.minorTickLineStyle          = lineStyle      // X軸の小さいメモリにラインスタイルを適用
        x.majorIntervalLength         = 0 // X軸ラベルの表示間隔
        //        x.orthogonalCoordinateDecimal = 0 // X軸のY位置
        //    x.title                       = @"X軸"
        //    x.titleTextStyle = textStyle
        //    x.titleLocation               = CPTDecimalFromFloat(5.0f)
        //    x.titleOffset                 = 36.0f
        //    x.minorTickLength = 5.0f                   // X軸のメモリの長さ ラベルを設定しているため無効ぽい
        //    x.majorTickLength = 9.0f                   // X軸のメモリの長さ ラベルを設定しているため無効ぽい
        //    x.labelTextStyle = textStyle

        // Y軸のメモリ・ラベルなどの設定
        let y = axisSet.yAxis
        y.axisLineStyle               = lineStyle      // Y軸の線にラインスタイルを適用
        y.majorTickLineStyle          = lineStyle      // Y軸の大きいメモリにラインスタイルを適用
        y.minorTickLineStyle          = lineStyle      // Y軸の小さいメモリにラインスタイルを適用
        y.majorTickLength = 9.0                   // Y軸の大きいメモリの長さ
        y.minorTickLength = 5.0                   // Y軸の小さいメモリの長さ
        y.majorIntervalLength         = self.yMajorIntervalLength  // Y軸ラベルの表示間隔
        //        y.orthogonalCoordinateDecimal = 0  // Y軸のX位置
        //    y.title                       = @"Y軸"
        //    y.titleTextStyle = textStyle
        //    y.titleRotation = M_PI*2
        //    y.titleLocation               = CPTDecimalFromFloat(11.0f)
        //    y.titleOffset                 = 15.0f
        lineStyle.lineWidth = 0.5
        y.majorGridLineStyle = lineStyle
        //    y.labelTextStyle = textStyle
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 0
        y.labelFormatter = formatter

        // 折れ線グラフのインスタンスを生成
        let scatterPlot = CPTScatterPlot(frame: CGRectZero)
        scatterPlot.identifier      = "Plot" // 折れ線グラフを識別するために識別子を設定
        scatterPlot.dataSource      = self               // 折れ線グラフのデータソースを設定

        // 折れ線グラフのスタイルを設定
        let graphlineStyle = scatterPlot.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        graphlineStyle.lineWidth = 3                    // 太さ
        graphlineStyle.lineColor = self.lineColor
        scatterPlot.dataLineStyle = graphlineStyle

        // グラフに折れ線グラフを追加
        graph.addPlot(scatterPlot)

        let graphHostingView = CPTGraphHostingView()
        graphHostingView.hostedGraph = graph

        return graphHostingView
    }
}
