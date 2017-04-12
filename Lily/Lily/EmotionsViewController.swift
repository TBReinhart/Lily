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
class EmotionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var weeklyBarView: WeeklyBarView!
    @IBOutlet weak var chartWeeklyBarView: WeeklyBarView!
    @IBOutlet weak var logButton: UIButton!
    var log_enabled = false
    @IBOutlet weak var advicePanelView: AdvicePanelView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    
    let advice = "A new baby may add emotional stress to your life. It’s natural to feel worried, exhausted, and anxious all at once.\n\nDuring the first trimester, you may experience mood swings and sudden weepiness. You should seek understanding and emotional support from your partner and be candid with your physician.\n\nDuring the second trimester, bodily changes may affect your emotions. You may feel frustrated and worry about labor and delivery. Focus on making healthy lifestyle choices and educate yourself about your pregnancy.\n\nDuring the third trimester, the reality of motherhood may begin to sink in. You may feel anxious and overwhelmed. Consider journaling your thoughts and planning aheald for delivery."
    let sourceLink = "http://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/pregnancy/art-20047732?pg=2"
    let adviceTitle = "HOW SHOULD I BE FEELING?"
    let source = "Mayo Clinic"
    var daysAgo = 0
    
    
    let reds : [Double]    = [0,1,2,1,3,0,0]
    let yellows : [Double] = [3,2,1,0,0,1,1]
    let blues : [Double]   = [1,2,3,3,2,1,0]
    let greens : [Double]  = [3,3,3,2,2,1,1]
    var dailyEmotionsDict = [String: String]()

    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

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
        

        fetchEmotions()
        
        
        
        
        
    }
    
    func fetchEmotions() {
        // set once loaded
        setChartProperties()
        setChart()

    }
    
    
    func setChartProperties() {


        self.lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
        self.lineChartView.xAxis.granularity = 1
        self.lineChartView.xAxis.centerAxisLabelsEnabled = true

        let redsEntry = reds.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        let yellowsEntry = yellows.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        let bluesEntry = blues.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        let greensEntry = greens.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }

        self.lineChartView.leftAxis.axisMinimum = 0
        self.lineChartView.leftAxis.axisMaximum = 3
        self.lineChartView.leftAxis.granularityEnabled = true
        self.lineChartView.leftAxis.granularity = 1.0
        
        
    
        
        let redsSet = LineChartDataSet(values: redsEntry, label: "Red")
        redsSet.mode = .cubicBezier
        redsSet.setColor(Helpers.UIColorFromRGB(rgbValue: 0xF24338))
        redsSet.lineWidth = 3.0
        redsSet.drawValuesEnabled = false
        redsSet.setCircleColor(Helpers.UIColorFromRGB(rgbValue: 0xF24338))
        redsSet.circleRadius = 4.0
        redsSet.fillAlpha = 65 / 255.0
        
        
        let yellowsSet = LineChartDataSet(values: yellowsEntry, label: "Yellow")
        yellowsSet.mode = .cubicBezier
        yellowsSet.setColor(Helpers.UIColorFromRGB(rgbValue: 0xF8DF0C))
        yellowsSet.lineWidth = 3.0
        yellowsSet.drawValuesEnabled = false
        yellowsSet.setCircleColor(Helpers.UIColorFromRGB(rgbValue: 0xF8DF0C))
        yellowsSet.circleRadius = 4.0
        yellowsSet.fillAlpha = 65 / 255.0
        
        let bluesSet = LineChartDataSet(values: bluesEntry, label: "Blue")
        bluesSet.mode = .cubicBezier
        bluesSet.setColor(Helpers.UIColorFromRGB(rgbValue: 0x82B7DF))
        bluesSet.lineWidth = 3.0
        bluesSet.drawValuesEnabled = false
        bluesSet.setCircleColor(Helpers.UIColorFromRGB(rgbValue: 0x82B7DF))
        bluesSet.circleRadius = 4.0
        bluesSet.fillAlpha = 65 / 255.0
        
        let greensSet = LineChartDataSet(values: greensEntry, label: "Green")
        greensSet.mode = .cubicBezier
        greensSet.setColor(Helpers.UIColorFromRGB(rgbValue: 0xACD285))
        greensSet.lineWidth = 3.0
        greensSet.drawValuesEnabled = false
        greensSet.setCircleColor(Helpers.UIColorFromRGB(rgbValue: 0xACD285))
        greensSet.circleRadius = 4.0
        greensSet.fillAlpha = 65 / 255.0

        self.lineChartView.legend.position = .aboveChartRight
        let data = LineChartData()

        // 0xF24338
        data.addDataSet(redsSet)
        data.addDataSet(yellowsSet)
        data.addDataSet(bluesSet)
        data.addDataSet(greensSet)

        self.lineChartView.rightAxis.enabled = false
        self.lineChartView.xAxis.enabled = true
        self.lineChartView.xAxis.drawAxisLineEnabled = true
        self.lineChartView.xAxis.labelPosition = .bottom
        self.lineChartView.data = data
        
        self.lineChartView.gridBackgroundColor = NSUIColor.white
        self.lineChartView.chartDescription?.text = ""

    }
    
    func setChart() {
        self.lineChartView.noDataText = "You need to provide data for the chart."
        
        
        
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
        logEmotions()
    }
    
    func logEmotions() {
        
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
    
    
    func getTitle(index: Int) -> String {
        switch index {
        case 0:
            return "frustrated"
        case 8:
            return "overwhelmed"
        case 16:
            return "sad"
        case 24:
            return "happy"
        case 32:
            return "angry"
        case 40:
            return "nervous"
        case 48:
            return "like crying"
        case 56:
            return "excited"
        case 64:
            return "irate"
        case 72:
            return "scared"
        case 80:
            return "miserable"
        case 88:
            return "like laughing"
        default:
            return "other"
        }
    }
    
    func getColor(index: Int) -> UIColor {
        var color = UIColor.black
        if index < 24 {
            return UIColor.red
        } else if index < 48 {
            return UIColor.yellow
        } else if index < 72 {
            return UIColor.blue
        } else {
            return UIColor.green
        }
        
        return color
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
