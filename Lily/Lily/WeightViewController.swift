//
//  WeightViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 4/4/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import Charts

class WeightViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var dailyBarView: WeeklyBarView!
    @IBOutlet weak var weeklyBarView: WeeklyBarView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var advicePanelView: AdvicePanelView!

    let entryDates = ["1/15", "1/17", "1/20", "1/22", "1/23", "1/25", "1/28"]
    let entries : [Double] = [140,144,144,146,148,150, 150]
    override func viewWillAppear(_ animated: Bool) {
        self.lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let ys1 : [Double] = [144, 146, 148, 150, 150]
        let ys2 : [Double] = [144,144.5, 145, 145.5, 146, 146.5, 147, 147.5, 148, 148.5,149, 149.5,150]
        let yse1 = ys1.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        let yse2 = ys2.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }

        let goalSet = LineChartDataSet(values: yse2, label: "goal")
        goalSet.mode = .cubicBezier
        
        let data = LineChartData()
        let ds1 = LineChartDataSet(values: yse1, label: "your progress")
        ds1.axisDependency = .left
        ds1.setColor(Helpers.UIColorFromRGB(rgbValue: 0xAECF8C))
        ds1.setCircleColor(Helpers.UIColorFromRGB(rgbValue: 0xAECF8C))
        ds1.lineWidth = 2.0
        // 0xF24338
        ds1.circleRadius = 4.0
        ds1.fillAlpha = 65 / 255.0
        data.addDataSet(ds1)
        self.lineChartView.rightAxis.enabled = false
        self.lineChartView.xAxis.enabled = false
        self.lineChartView.xAxis.labelPosition = .top
        
        goalSet.colors = [NSUIColor.blue]
        goalSet.lineWidth = 2.0
        goalSet.fillAlpha = 65 / 255.0
        goalSet.circleRadius = 0.0
        data.addDataSet(goalSet)
        self.lineChartView.data = data
        
        self.lineChartView.gridBackgroundColor = NSUIColor.white
        
//        self.lineChartView.chartDescription?.text = "Weight Progress"
    
    }


}
