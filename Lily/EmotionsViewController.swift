//
//  EmotionsViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 3/25/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SafariServices
import Charts
import SwiftyJSON
import Firebase
import PKHUD


class EmotionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var todayIFeltLabel: UILabel!
    @IBOutlet weak var weeklyBarView: WeeklyBarView!
    @IBOutlet weak var chartWeeklyBarView: WeeklyBarView!
    @IBOutlet weak var logButton: UIButton!
    var log_enabled = false
    @IBOutlet weak var advicePanelView: AdvicePanelView!
    var firebaseRef: FIRDatabaseReference!

    @IBOutlet weak var bubbleChartView: BubbleChartView!
    
    let advice = "A new baby may add emotional stress to your life. It’s natural to feel worried, exhausted, and anxious all at once.\n\nDuring the first trimester, you may experience mood swings and sudden weepiness. You should seek understanding and emotional support from your partner and be candid with your physician.\n\nDuring the second trimester, bodily changes may affect your emotions. You may feel frustrated and worry about labor and delivery. Focus on making healthy lifestyle choices and educate yourself about your pregnancy.\n\nDuring the third trimester, the reality of motherhood may begin to sink in. You may feel anxious and overwhelmed. Consider journaling your thoughts and planning aheald for delivery."
    let sourceLink = "http://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/pregnancy/art-20047732?pg=2"
    let adviceTitle = "HOW SHOULD I BE FEELING?"
    let source = "Mayo Clinic"
    var daysAgo = 0
    var weeksAgo = 0
    

    
    var dailyEmotionsDict = [String: Bool]()

    let days = ["", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    @IBOutlet weak var barChartView: BarChartView!
    
    let margin: CGFloat = 5, cellsPerRowChart: CGFloat = 8, cellsPerRowEmotions: CGFloat = 4
    
    
    @IBOutlet weak var emotionsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emotionsCollectionView.dataSource = self
        self.emotionsCollectionView.delegate = self
        
        self.advicePanelView.adviceLinkButton.addTarget(self, action: #selector(self.adviceTapped), for: .touchUpInside)
        self.setAdvice(advice: self.advice)
        self.setAdviceLink(source: self.source)
        self.setAdviceTitle(title: self.adviceTitle)
        self.setAdviceURL(source: self.sourceLink)
        self.weeklyBarView.backButton.addTarget(self, action: #selector(self.goBackDay), for: .touchUpInside)
        self.weeklyBarView.forwardButton.addTarget(self, action: #selector(self.goForwardDay), for: .touchUpInside)
        self.chartWeeklyBarView.backButton.addTarget(self, action: #selector(self.goBackWeek), for: .touchUpInside)
        self.chartWeeklyBarView.forwardButton.addTarget(self, action: #selector(self.goForwardWeek), for: .touchUpInside)

        
        let endDate = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo).dateString
        let past = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo)
        let date = past.date
        let labelRange = Helpers.getShortDateRangeString(date: date)
        self.weeklyBarView.setDateRangeLabel(title: "Today")
        self.todayIFeltLabel.text = "Today I Felt..."
        self.chartWeeklyBarView.setDateRangeLabel(title: labelRange)
        self.chartWeeklyBarView.forwardButton.isEnabled = false
        self.weeklyBarView.forwardButton.isEnabled = false
        loadEmotionsFromFirebase(daysAgo: 0)

        fetchEmotions(weeksAgo: 0)

        
    }
    
    var myGroup = DispatchGroup()
    func fetchEmotions(weeksAgo: Int) {
        var weeklyEmotions: JSON = [:]
        
        let dateRange = Helpers.get7DayRangeInts(weeksAgo: weeksAgo)
        for i in  dateRange.0..<dateRange.1 + 1 {
            myGroup.enter()

            Helpers.loadDailyLogFromFirebase(key: "emotions", daysAgo: i) { json, error in
                self.myGroup.leave()
                if json != nil {
                    weeklyEmotions[String(i)] = json
                } else {
                    let j:JSON = [:]
                    weeklyEmotions[String(i)] = j
                }

            }
        }
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print("Finished all requests.")
            print(weeklyEmotions)
            self.setEmotionLevels(weeklyEmotions: weeklyEmotions)
        })
        
        setChartProperties()
        setChart()
        

    }
    
    func setEmotionLevels(weeklyEmotions: JSON) {
        var r : [Double]  = [0,0,0,0,0,0,0]
        var y : [Double]  = [0,0,0,0,0,0,0]
        var b : [Double]  = [0,0,0,0,0,0,0]
        var g : [Double]  = [0,0,0,0,0,0,0]
        
        // TODO fix this
        let dateRange = Helpers.get7DayRangeInts(weeksAgo: weeksAgo)

        for i in dateRange.0..<dateRange.1 + 1 {
            
            var json = weeklyEmotions[String(i)]
            
            var redCount = 0
            var yellowCount = 0
            var blueCount = 0
            var greenCount = 0

            if json["frustrated"].boolValue {
                redCount += 1
            }
            
            if json["angry"].boolValue {
                redCount += 1
            }
            
            if json["irate"].boolValue {
                redCount += 1
            }
            
            if json["overwhelmed"].boolValue {
                yellowCount += 1
            }
            
            if json["nervous"].boolValue {
                yellowCount += 1
            }
            
            if json["scared"].boolValue {
                yellowCount += 1
            }
            
            if json["sad"].boolValue {
                blueCount += 1
            }
            
            
            if json["like crying"].boolValue {
                blueCount += 1
            }
            
            if json["miserable"].boolValue {
                blueCount += 1
            }
            
            if json["happy"].boolValue {
                greenCount += 1
            }
            
            if json["excited"].boolValue {
                greenCount += 1
            }
            
            if json["like laughing"].boolValue {
                greenCount += 1
            }
            
            r[i%7] = Double(redCount)
            y[i%7] = Double(yellowCount)
            b[i%7] = Double(blueCount)
            g[i%7] = Double(greenCount)
        }
        r = r.reversed()
        r.insert(0, at: 0)
        
        y = y.reversed()
        y.insert(0, at: 0)

        b = b.reversed()
        b.insert(0, at: 0)

        g = g.reversed()
        g.insert(0, at: 0)
        print(r)
        print(y)
        print(b)
        print(g)
        setChartBubble(reds: r, yellows: y, blues: b, greens: g)

    }
    
    func initializeEmotionsDict() {
        dailyEmotionsDict["frustrated"] = false
        dailyEmotionsDict["angry"] = false
        dailyEmotionsDict["irate"] = false

        dailyEmotionsDict["overwhelmed"] = false
        dailyEmotionsDict["nervous"] = false
        dailyEmotionsDict["scared"] = false

        dailyEmotionsDict["sad"] = false
        dailyEmotionsDict["like crying"] = false
        dailyEmotionsDict["miserable"] = false

        dailyEmotionsDict["happy"] = false
        dailyEmotionsDict["excited"] = false
        dailyEmotionsDict["like laughing"] = false
    }
    
    func goBackWeek() {
        print("go back week")
        self.weeksAgo += 1
        self.fetchEmotions(weeksAgo: self.weeksAgo)
        
        if self.weeksAgo == 0 {
            self.chartWeeklyBarView.forwardButton.isEnabled = false
            
        }  else {
            self.chartWeeklyBarView.forwardButton.isEnabled = true
            
        }
        setChartDateRange()
    }
    
    func setChartDateRange() {
        let past = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo)
        let labelRange = Helpers.getShortDateRangeString(date: past.date)
        self.chartWeeklyBarView.setDateRangeLabel(title: labelRange)
        self.fetchEmotions(weeksAgo: self.weeksAgo)
    }
    
    func goForwardWeek() {
        if self.weeksAgo == 0 {
            return
        }
        self.weeksAgo -= 1
        
        if self.weeksAgo == 0 {
            self.chartWeeklyBarView.forwardButton.isEnabled = false

            
        }  else {
            self.chartWeeklyBarView.forwardButton.isEnabled = true
            
        }
        setChartDateRange()

    }
    
    func setEmotionsDict(emotion: String) {
        dailyEmotionsDict[emotion] = true
    }



    func setChartBubble(reds: [Double], yellows: [Double], blues: [Double], greens: [Double]) {
        let redsEntries = reds.enumerated().map { x, y in return BubbleChartDataEntry(x: Double(x), y: 0, size: CGFloat(y/2.5)) }
        let yellowsEntries = yellows.enumerated().map { x, y in return BubbleChartDataEntry(x: Double(x), y: 1, size: CGFloat(y/2.5)) }
        let greensEntries = greens.enumerated().map { x, y in return BubbleChartDataEntry(x: Double(x), y: 3, size: CGFloat(y/2.5)) }
        let bluesEntries = blues.enumerated().map { x, y in return BubbleChartDataEntry(x: Double(x), y: 2, size: CGFloat(y/2.5)) }

        
        
        let chartData1 = BubbleChartDataSet(values: redsEntries,label: "Anger" )
        chartData1.normalizeSizeEnabled = false
        let chartData2 = BubbleChartDataSet(values: yellowsEntries,label: "Nervous")
        chartData2.normalizeSizeEnabled = false

        let chartData3 = BubbleChartDataSet(values: greensEntries,label: "Happy")
        chartData3.normalizeSizeEnabled = false

        let chartData4 = BubbleChartDataSet(values: bluesEntries,label: "Sad")
        chartData4.normalizeSizeEnabled = false

        
        chartData1.colors =  [Helpers.UIColorFromRGB(rgbValue: 0xF24338)]
        chartData2.colors =  [Helpers.UIColorFromRGB(rgbValue: 0xF8DF0C)]
        chartData3.colors =  [Helpers.UIColorFromRGB(rgbValue: 0xACD285)]
        chartData4.colors =  [Helpers.UIColorFromRGB(rgbValue: 0x82B7DF)]

        let dataSets: [BubbleChartDataSet] = [chartData1,chartData2,chartData3,chartData4]
        for set in dataSets {
            set.drawValuesEnabled = false
        }
        
        let data = BubbleChartData(dataSets: (dataSets as [IChartDataSet]))
        bubbleChartView.data = data;
        bubbleChartView.chartDescription?.text = ""
        bubbleChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
    }

    func getLastWeekShortenedStrings() -> [String] {
        var days = [String]()
        for i in 0..<7 {
            let d = Helpers.getDateNDaysAgo(daysAgo: i).date
            days.append(self.getDayAbbreviation(date: d))
        }
        days = days.reversed()
        days.insert("", at: 0)
        return days
    }

    func setChartProperties() {
        bubbleChartView.drawGridBackgroundEnabled = false
        bubbleChartView.dragEnabled = false
        bubbleChartView.maxVisibleCount = 200
        bubbleChartView.pinchZoomEnabled = false
        
        self.bubbleChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:self.getLastWeekShortenedStrings())
        self.bubbleChartView.xAxis.granularity = 1
//        self.bubbleChartView.xAxis = true
        self.bubbleChartView.xAxis.labelPosition = .bottom
        self.bubbleChartView.leftAxis.valueFormatter = IndexAxisValueFormatter(values:["Anger","Nervous","Sad","Happy"])
        self.bubbleChartView.xAxis.axisMinimum = 0
        self.bubbleChartView.xAxis.axisMaximum = 8

        print(self.bubbleChartView.xAxis.axisMaximum)
        self.bubbleChartView.leftAxis.granularity = 1
        self.bubbleChartView.leftAxis.centerAxisLabelsEnabled = true

        self.bubbleChartView.legend.position = .belowChartRight
        self.bubbleChartView.xAxis.drawAxisLineEnabled = true
        
        // this replaces startAtZero = YES
        bubbleChartView.rightAxis.enabled = false


    }
    
    
    
    func getDayAbbreviation(date: Date) -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "EEEEE"
        
        return dayTimePeriodFormatter.string(from: date)
    }
    
    
    func setChart() {
        self.bubbleChartView.noDataText = "You need to provide data for the chart."
    }
    
    func goBackDay() {
        print("go back day")
        self.daysAgo += 1
        self.loadEmotionsFromFirebase(daysAgo: self.daysAgo)
        
        if self.daysAgo == 0 {
            self.weeklyBarView.forwardButton.isEnabled = false
            self.weeklyBarView.setDateRangeLabel(title: "Today")
            self.todayIFeltLabel.text = "Today I Felt..."

        }  else {
            self.weeklyBarView.forwardButton.isEnabled = true
            let date = Helpers.getDateNDaysAgo(daysAgo: self.daysAgo)
            self.weeklyBarView.setDateRangeLabel(title: Helpers.getWeekDayFromDate(date: date.0))
            self.todayIFeltLabel.text = "\(Helpers.getWeekDayFromDate(date: date.0)) I Felt..."

        }
        
        
    }
    func goForwardDay() {
        if self.daysAgo == 0 {
            return
        }
        self.daysAgo -= 1
        
        if self.daysAgo == 0 {
            self.weeklyBarView.forwardButton.isEnabled = false

            self.weeklyBarView.setDateRangeLabel(title: "Today")
            self.todayIFeltLabel.text = "Today I Felt..."

        }  else {
            self.weeklyBarView.forwardButton.isEnabled = true

            let date = Helpers.getDateNDaysAgo(daysAgo: self.daysAgo)
            self.weeklyBarView.setDateRangeLabel(title: Helpers.getWeekDayFromDate(date: date.0))
            self.todayIFeltLabel.text = "\(Helpers.getWeekDayFromDate(date: date.0)) I Felt..."

        }

        self.loadEmotionsFromFirebase(daysAgo: self.daysAgo)
    }
    func getEmotions(daysAgo: Int) {
        if self.daysAgo == 0 {
            self.weeklyBarView.forwardButton.isEnabled = false
        } else {
            self.weeklyBarView.forwardButton.isEnabled = true
        }
        let dateStr = Helpers.getLongDate(date: Helpers.getDateNDaysAgo(daysAgo: self.daysAgo).date)
        setDate(date: dateStr)
        
    }
    func setDate(date: String) {
        self.weeklyBarView.setDateRangeLabel(title: date)
    }
    // TODO
    @IBAction func logButtonPressed(_ sender: Any) {
        print("Log pressed")
        initializeEmotionsDict()
        trackSelectedEmotions()
        logEmotions()
        HUD.flash(.success)

    }
    
    // TODO save locally
    func loadEmotionsFromFirebase(daysAgo: Int) {
        Helpers.loadDailyLogFromFirebase(key: "emotions", daysAgo: daysAgo) { json, error in
            print("load daily log: \(json)")
            if json != nil {
                for (key, value) in json {
                    
                    self.setEmotionCell(emotion: key, selected: value.boolValue)
                }
            } else {
                print("nil this day so will try to log a blank")

                self.initializeEmotionsDict()
                for (key, value) in self.dailyEmotionsDict {
                    self.setEmotionCell(emotion: key, selected: value)
                }
                self.trackSelectedEmotions()
                self.logEmotions()
            }
        }
    }
    
    func setEmotionCell(emotion: String, selected: Bool) {
        for cell in self.emotionsCollectionView.visibleCells {
            let e = cell as! EmotionViewCollectionViewCell
            if e.getEmotion() == emotion {
                e.emotionView.setImage(emotion: emotion, selected: selected)
            }
        }
    }
    
    
    func trackSelectedEmotions() {
        var selectedEmotions = [String]()
        for cell in self.emotionsCollectionView.visibleCells {
            let e = cell as! EmotionViewCollectionViewCell
            if e.isEmotionSelected() == true {
                let emotion = e.getEmotion()
                
                selectedEmotions.append(emotion)
            }
        }
        for e in selectedEmotions {
            setEmotionsDict(emotion: e)
        }
    }
    
    
    func logEmotions() {
        
        Helpers.postDailyLogToFirebase(key: "emotions", value: self.dailyEmotionsDict, daysAgo: self.daysAgo)
        self.logButton.setImage(#imageLiteral(resourceName: "grey_log_button.png"), for: .normal)
        if self.weeksAgo == 0 {
            fetchEmotions(weeksAgo: 0)
        }

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var cellsPerRow: CGFloat
        
        cellsPerRow = self.cellsPerRowEmotions
        
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * (cellsPerRow - 1)
        let itemWidth = (collectionView.bounds.size.width - marginsAndInsets) / cellsPerRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmotionCell", for: indexPath) as! EmotionViewCollectionViewCell
        let emotion = self.getEmotion(index: indexPath.row)
        cell.emotionView.setLabel(emotion: emotion)
        cell.emotionView.button.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        
        return cell
        
        
    }
    
    func isAnyButtonSelected() -> Bool {
        var selected = false
        
        for cell in self.emotionsCollectionView.visibleCells {
            let e = cell as! EmotionViewCollectionViewCell
            if e.isEmotionSelected() == true {
                selected = true
            }
        }
        return selected
    }
    
    func buttonClicked(sender: UIButton) {
        if isAnyButtonSelected() {
            self.logButton.setImage(#imageLiteral(resourceName: "green_log_button.png"), for: .normal)
        }
//        else {
//            self.logButton.setImage(#imageLiteral(resourceName: "grey_log_button.png"), for: .normal)
//        }
    }
    
    func getEmotion(index: Int) -> String {
        switch index {
        case 0:
            return "frustrated"
        case 1:
            return "overwhelmed"
        case 2:
            return "sad"
        case 3:
            return "happy"
        case 4:
            return "angry"
        case 5:
            return "nervous"
        case 6:
            return "like crying"
        case 7:
            return "excited"
        case 8:
            return "irate"
        case 9:
            return "scared"
        case 10:
            return "miserable"
        case 11:
            return "like laughing"
        default:
            return "other"
        }
    }
    
    func adviceTapped() {
        let url = self.advicePanelView.adviceLinkSource
        let svc = SFSafariViewController(url: URL(string:url)!)
        present(svc, animated: true, completion: nil)
    }
    func setAdviceTitle(title: String) {
        self.advicePanelView.setTitleLabel(title: title)
    }
    func setAdvice(advice: String) {
        self.advicePanelView.setAdviceText(advice: advice)
    }
    func setAdviceLink(source: String) {
        self.advicePanelView.setAdviceButtonText(source: source)
    }
    func setAdviceURL(source: String) {
        self.advicePanelView.setAdviceLinkSource(source: source)
    }
}
