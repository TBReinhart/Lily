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
class EmotionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
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
    
    
    let reds : [Double]    = [0,0,1,2,1,3,0,0]
    let yellows : [Double] = [0,3,2,1,0,0,1,1]
    let blues : [Double]   = [0,1,2,3,3,2,1,0]
    let greens : [Double]  = [0, 3,3,3,2,2,1,1]
    
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
        self.getEmotions(daysAgo: 0)
        
        
        loadEmotionsFromFirebase(daysAgo: 0)

        fetchEmotions()
        
        
    }
    
    func fetchEmotions() {
        // set once loaded
        setChartProperties()
        setChart()
        

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
    
    func setEmotionsDict(emotion: String) {
        dailyEmotionsDict[emotion] = true
    }
    func setChartBubble() {
        

        
        let redsEntries = reds.enumerated().map { x, y in return BubbleChartDataEntry(x: Double(x), y: 0, size: CGFloat(y)) }
        let yellowsEntries = yellows.enumerated().map { x, y in return BubbleChartDataEntry(x: Double(x), y: 1, size: CGFloat(y)) }
        let greensEntries = greens.enumerated().map { x, y in return BubbleChartDataEntry(x: Double(x), y: 3, size: CGFloat(y)) }
        let bluesEntries = blues.enumerated().map { x, y in return BubbleChartDataEntry(x: Double(x), y: 2, size: CGFloat(y)) }

        
        
        let chartData1 = BubbleChartDataSet(values: redsEntries,label: "Anger" )
        
        let chartData2 = BubbleChartDataSet(values: yellowsEntries,label: "Nervous")
        
        let chartData3 = BubbleChartDataSet(values: greensEntries,label: "Happy")
        let chartData4 = BubbleChartDataSet(values: bluesEntries,label: "Sad")
        
        
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
        days.append("")
        for i in 0..<7 {
            let d = Helpers.getDateNDaysAgo(daysAgo: i).date
            days.append(self.getDayAbbreviation(date: d))
        }
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
        setChartBubble()


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
        self.daysAgo += 1
        self.getEmotions(daysAgo: self.daysAgo)
        
    }
    func goForwardDay() {
        if self.daysAgo == 0 {
            return
        }
        self.daysAgo -= 1
        self.getEmotions(daysAgo: self.daysAgo)
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
    }
    
    // TODO save locally
    func loadEmotionsFromFirebase(daysAgo: Int) {
        Helpers.loadDailyLogFromFirebase(key: "emotions", daysAgo: daysAgo) { json, error in
            for (key, value) in json! {
                self.setEmotionCell(emotion: key, selected: value.boolValue)
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
        Helpers.postDailyLogToFirebase(key: "emotions", value: self.dailyEmotionsDict)
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
        } else {
            self.logButton.setImage(#imageLiteral(resourceName: "grey_log_button.png"), for: .normal)
        }
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
