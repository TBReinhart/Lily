//
//  WeightViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 4/4/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import Charts

class WeightViewController: UIViewController, ChartViewDelegate, SignInDelegate, DailyBarDelegate  {
    func signIn() {
            endDay = Calendar.current.date(byAdding:
    .day,
    value: -7,
    to: endDay)!
    
               startDay = Calendar.current.date(byAdding:
    .day,
    value: -7,
    to: startDay)!
        self.getWeightNWeeksAgo(weeksAgo: currentWeeksBack)

    }
    func weightForwardWeek() {
        endDay = Calendar.current.date(byAdding:
    .day,
    value: 7,
    to: endDay)!
    
               startDay = Calendar.current.date(byAdding:
    .day,
    value: 7,
    to: startDay)!

            self.getWeightNWeeksAgo(weeksAgo: currentWeeksBack)
    }
    func weightDayForward() {
     let df = DateFormatter()
     df.dateFormat = "yyyy-MM-dd"
     self.weightDay = Calendar.current.date(byAdding:
    .day,
    value: -1,
    to: self.weightDay)!
    self.dateString = df.string(from: self.weightDay)
    self.dailyBarView.dateRangeLabel.text = self.dateString

    
    }
    
    func weightDayBack() {

    let df = DateFormatter()
     df.dateFormat = "yyyy-MM-dd"
     self.weightDay = Calendar.current.date(byAdding:
    .day,
    value: 1,
    to: self.weightDay)!
    self.dateString = df.string(from: self.weightDay)
    self.dailyBarView.dateRangeLabel.text = self.dateString

    
    }


    @IBOutlet var weightLabel: UILabel!
    @IBOutlet weak var dailyBarView: DailyBarView!
    @IBOutlet weak var weeklyBarView: WeeklyBarView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var advicePanelView: AdvicePanelView!
    var fbreqs = FitbitRequests()
    var weightsArray = [Double]()
    var weightsArray2 = [Double]()
    var weightDatesArray = [String]()
    var ys2 = [Double]()
    var dateString = ""

    var currentWeeksBack = 0
    
    var currentDaysWeight = 0.0
    var roundedWeight = 0.0
    var intWeight = 0
    var convertedWeight = 0.0
		
    var stringWeight = ""

    var endDay = Date()
    var startDay = Date()
    var today = Date()
    var today1 = Date()
    var weightDay = Date()

    var goalWeight = 0.0
    var x = 0






    let entryDates = ["1/15", "1/17", "1/20", "1/22", "1/23", "1/25", "1/28"]
    let entries : [Double] = [140,144,144,146,148,150, 150]
//    override func viewWillAppear(_ animated: Bool) {
//        self.lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
//    }
override func viewDidDisappear(_ animated: Bool){
        if let app = UIApplication.shared.delegate as? AppDelegate {
            app.verifyWeight = false
        }
}
    override func viewDidLoad() {
        super.viewDidLoad()
        weeklyBarView.delegate = self
        dailyBarView.delegate = self

        let calendar = Calendar.current

        
         startDay = calendar.date(byAdding: .day, value: -7, to: Date())!
        if let app = UIApplication.shared.delegate as? AppDelegate {
            app.verifyWeight = true
        }
        

//        self.forwardButtonWeek.addTarget(self, action: #selector(self.swipeLeftWeek), for: .touchUpInside)
//        self.backButtonWeek.addTarget(self, action: #selector(self.swipeRightWeek), for: .touchUpInside)
//        self.forwardButtonDay.addTarget(self, action: #selector(self.swipeLeftSpecificDate), for: .touchUpInside)
//        self.backButtonDay.addTarget(self, action: #selector(self.swipeRightSpecificDate), for: .touchUpInside)

        // Do any additional setup after loading the view.
//        let ys1 : [Double] = [144, 146, 148, 150, 150]
//        let ys2 : [Double] = [144,144.5, 145, 145.5, 146, 146.5, 147, 147.5, 148, 148.5,149, 149.5,150]
//        let yse1 = ys1.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
//        let yse2 = ys2.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
//
//        let goalSet = LineChartDataSet(values: yse2, label: "goal")
//        goalSet.mode = .cubicBezier
//        
//        let data = LineChartData()
//        let ds1 = LineChartDataSet(values: yse1, label: "your progress")
//        ds1.axisDependency = .left
//        ds1.setColor(Helpers.UIColorFromRGB(rgbValue: 0xAECF8C))
//        ds1.setCircleColor(Helpers.UIColorFromRGB(rgbValue: 0xAECF8C))
//        ds1.lineWidth = 2.0
//        // 0xF24338
//        ds1.circleRadius = 4.0
//        ds1.fillAlpha = 65 / 255.0
//        data.addDataSet(ds1)
//        self.lineChartView.rightAxis.enabled = false
//        self.lineChartView.xAxis.enabled = false
//        self.lineChartView.xAxis.labelPosition = .top
//        
//        goalSet.colors = [NSUIColor.blue]
//        goalSet.lineWidth = 2.0
//        goalSet.fillAlpha = 65 / 255.0
//        goalSet.circleRadius = 0.0
//        data.addDataSet(goalSet)
//        self.lineChartView.data = data
//        
//        self.lineChartView.gridBackgroundColor = NSUIColor.white
        
        self.getWeightNWeeksAgo(weeksAgo: 0)
        self.getTodaysWeight()


//        self.lineChartView.chartDescription?.text = "Weight Progress"
    
    }

    @IBAction func swipeLeftWeek() {

           endDay = Calendar.current.date(byAdding:
    .day,
    value: -7,
    to: endDay)!
    
               startDay = Calendar.current.date(byAdding:
    .day,
    value: -7,
    to: startDay)!

        self.getWeightNWeeksAgo(weeksAgo: currentWeeksBack)
    }
    
   @IBAction func swipeRightWeek() {
    
    
           endDay = Calendar.current.date(byAdding:
    .day,
    value: 7,
    to: endDay)!
    
               startDay = Calendar.current.date(byAdding:
    .day,
    value: 7,
    to: startDay)!

                self.getWeightNWeeksAgo(weeksAgo: currentWeeksBack)

    }
    // change to get weight by date to date then swipe left and right simply changes dates, weeks ago very confusing...  then have to add in entering weight data manually
    func getWeightNWeeksAgo(weeksAgo: Int){
    
//        let past = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo)
//        let date = past.date
//        let labelRange = Helpers.getShortDateRangeString(date: date)
//        let dateString = pas`t.dateString
//        let calendar = Calendar.current
//
//        let endDay = calendar.date(byAdding: .day, value: (weeksAgo * -7), to: Date())
//        let startDay = calendar.date(byAdding: .day, value: (weeksAgo * -7 - 7), to: Date())
//        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let startDateString = df.string(from: startDay)
        let endateString = df.string(from: endDay)

        let df1 = DateFormatter()
        df1.dateFormat = "M/d"
        let startDateString1 = df1.string(from: startDay)
        let endateString1 = df1.string(from: endDay)
        
        self.weightsArray.removeAll()

        
        self.fbreqs.getWeightFromStartEndDates(startDate: startDateString, endDate: endateString) { weights, error in
        
        
         for item in (weights?["weight"].arrayValue)! {
        let specificWeightString = item["weight"].doubleValue * 2.20462262185
//        print(item["weight"].stringValue)
//        print(item["date"].stringValue)
        self.weightsArray.append(specificWeightString)
    }
    if self.weightsArray.isEmpty {
            print("No weights from last week")
        
    }
                            let defaults = UserDefaults.standard
self.goalWeight = defaults.double(forKey: "goalWeightValue")
while (self.x<self.weightsArray.count) {
self.ys2.append(self.goalWeight)
self.x += 1

}


        let yse1 = self.weightsArray.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
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
        
        

        let yse2 = self.ys2.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }

        let goalSet = LineChartDataSet(values: yse2, label: "goal")
        goalSet.mode = .cubicBezier
        
        goalSet.colors = [NSUIColor.blue]
        goalSet.lineWidth = 2.0
        goalSet.fillAlpha = 65 / 255.0
        goalSet.circleRadius = 0.0
        data.addDataSet(goalSet)

        self.weeklyBarView.dateRangeLabel.text = (startDateString1 + "- " + endateString1)
        
        self.lineChartView.data = data
        
        self.lineChartView.gridBackgroundColor = NSUIColor.white
        self.lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)

//        for weight in weights! {
//        let daysWeight = weight
//        print(daysWeight)
//        
//        }
        }
//        self.weekRangeLabel.text = labelRange
//        self.weekRangeLabel.adjustsFontSizeToFitWidth = true
    
    }
     func getTodaysWeight() {
       let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let startDateString = df.string(from: startDay)
        let endateString = df.string(from: weightDay)

        


     self.fbreqs.getWeightFromStartEndDates(startDate: startDateString, endDate: endateString) { weights, error in
        
        
         for item in (weights?["weight"].arrayValue)! {
        let specificWeightString = item["weight"].doubleValue * 2.20462262185
        let specificDateString = item["date"].stringValue
//        print(item["weight"].stringValue)
//        print(item["date"].stringValue)
        self.weightsArray2.append(specificWeightString)
        self.weightDatesArray.append(specificDateString)
    }
    if !self.weightsArray2.isEmpty {

        self.currentDaysWeight = self.weightsArray2.last!
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.dateString = df.string(from: self.today1)
        self.dailyBarView.dateRangeLabel.text = self.weightDatesArray.last!
        print(self.currentDaysWeight)
        self.roundedWeight = round(self.currentDaysWeight)
      
        self.intWeight = Int(self.roundedWeight)
        let str1 = "\(self.intWeight)"
        self.weightLabel.text = str1
        }
        
     
     }
 }
     @IBAction func addToWeight(_ sender: Any) {
        self.intWeight = self.intWeight + 1
        self.currentDaysWeight = self.currentDaysWeight+1
     
        
        let str1 = "\(self.intWeight)"
        self.weightLabel.text = str1
     

    }
    @IBAction func subtractFromWeight(_ sender: Any) {
        self.intWeight = self.intWeight - 1

        self.currentDaysWeight = self.currentDaysWeight-1

        
        let str1 = "\(self.intWeight)"
        self.weightLabel.text = str1
        
     


    }
    @IBAction func logWeight(_ sender: Any) {
    self.currentDaysWeight = self.currentDaysWeight/2.20462262185

    self.stringWeight = "\(self.currentDaysWeight)"
    print(self.stringWeight)
    self.fbreqs.logWeight(weight: self.stringWeight, date: self.dateString) { response, err in


        
        }
    }

}
