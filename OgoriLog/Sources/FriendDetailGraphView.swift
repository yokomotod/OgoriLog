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
    var fillGradientBeginningColor : CPTColor!
    var fillGradientEndingColor : CPTColor!


    var didTouchGraphBlock: (() -> Void)!

    var graphHostingView: CPTGraphHostingView?

    convenience init(friend: Friend, touchGraphBlock: () -> Void) {
        self.init()

        self.resetGraph(friend)

        self.didTouchGraphBlock = touchGraphBlock
    }

    func resetGraph(friend: Friend) {
        self.analayzeBillArray(friend.billArray(friend.managedObjectContext!))

        if  let graphHostingView = self.graphHostingView {
            graphHostingView.removeFromSuperview()
        }

        self.graphHostingView = self.friendDetailGraphHostingView()

        self.addSubview(self.graphHostingView!)
    }

    // mark Plot Data Source Methods

    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return UInt(self.totalBillHistoryArray.count)
    }

    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject! {
        switch (CPTScatterPlotField(rawValue: Int(fieldEnum))!) {
        case .X:
            return NSNumber(unsignedLong: idx)
        case .Y:
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
        self.fillGradientBeginningColor = self.calculateFillGradientBeginningColor(totalBillArray: self.totalBillHistoryArray)
        self.fillGradientEndingColor = self.calculateFillGradientEndingColor(totalBillArray: self.totalBillHistoryArray)
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
            return CPTColor(CGColor: ColorScheme.positiveColor().CGColor)
        } else {
            return CPTColor(CGColor: ColorScheme.negativeColor().CGColor)
        }
    }

    func calculateFillGradientBeginningColor(# totalBillArray: Array<Double>) -> CPTColor {
        let currentTotalBill = totalBillArray.last

        if currentTotalBill >= 0 {
            return CPTColor(CGColor: ColorScheme.positiveGradientBeginningGraphFillColor().CGColor)
        } else {
            return CPTColor(CGColor: ColorScheme.negativeGradientBeginningGraphFillColor().CGColor)
        }
    }

    func calculateFillGradientEndingColor(# totalBillArray: Array<Double>) -> CPTColor {
        let currentTotalBill = totalBillArray.last

        if currentTotalBill >= 0 {
            return CPTColor(CGColor: ColorScheme.positiveGradientEndingGraphFillColor().CGColor)
        } else {
            return CPTColor(CGColor: ColorScheme.negativeGradientEndingGraphFillColor().CGColor)
        }
    }

    func friendDetailGraphHostingView() -> CPTGraphHostingView {
        let graph = CPTXYGraph(frame: self.frame)

        // border
        graph.plotAreaFrame.borderLineStyle = nil
        graph.plotAreaFrame.masksToBorder = false
        graph.plotAreaFrame.paddingLeft   = 40.0

        // padding
        graph.paddingLeft = 0.0
        graph.paddingRight = 0.0
        graph.paddingTop = 0.0
        graph.paddingBottom = 0.0

        // plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.delegate = self
        plotSpace.yRange = self.yPlotRange
        plotSpace.xRange = self.xPlotRange

        // axis
        let axisSet = graph.axisSet as! CPTXYAxisSet
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineColor = CPTColor(CGColor: ColorScheme.baseGraphColor().CGColor)
        axisLineStyle.lineWidth = 1
        let x = axisSet.xAxis
        x.axisLineStyle = axisLineStyle
        x.majorTickLineStyle = axisLineStyle
        x.minorTickLineStyle = axisLineStyle
        x.majorIntervalLength = 0
        let y = axisSet.yAxis
        y.axisLineStyle = axisLineStyle
        y.majorTickLineStyle = axisLineStyle
        y.minorTickLineStyle = axisLineStyle
        y.majorTickLength = 9.0
        y.minorTickLength = 5.0
        y.majorIntervalLength = self.yMajorIntervalLength

        let gridLineStyle = CPTMutableLineStyle()
        gridLineStyle.lineColor = CPTColor(CGColor: ColorScheme.baseGraphColor().CGColor)
        gridLineStyle.lineWidth = 0.5
        y.majorGridLineStyle = gridLineStyle

        let textStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor(CGColor: ColorScheme.baseGraphColor().CGColor)
        y.labelTextStyle = textStyle
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 0
        y.labelFormatter = formatter

        // plot
        let scatterPlot = CPTScatterPlot(frame: CGRectZero)
        scatterPlot.identifier = "Plot"
        scatterPlot.dataSource = self

        let graphlineStyle = scatterPlot.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        graphlineStyle.lineWidth = 1
        graphlineStyle.lineColor = self.lineColor
        scatterPlot.dataLineStyle = graphlineStyle
        var gradient = CPTGradient(beginningColor: self.fillGradientBeginningColor, endingColor: self.fillGradientEndingColor)
        gradient.angle = -90.0
        var gradientFill = CPTFill(gradient: gradient)
        scatterPlot.areaFill = gradientFill
        scatterPlot.areaBaseValue = 0

        graph.addPlot(scatterPlot)

        // hosting view
        let graphHostingView = CPTGraphHostingView()
        graphHostingView.hostedGraph = graph

        return graphHostingView
    }
}
