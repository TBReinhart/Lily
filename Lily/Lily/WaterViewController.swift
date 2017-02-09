//
//  WaterViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 1/31/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import UICircularProgressRing
import SafariServices

class WaterViewController: UIViewController {

    var fbreqs = FitbitRequests()
    var waterObject = Water()
    @IBOutlet weak var scrollView: UIScrollView!
    var weekWaterObjects = [Water?](repeating: nil, count:7)
    var currentWeeksBack = 0
    var currentDaysBack = 0
    var glassesOfWaterConsumed = 0.0
    var glassesOfOtherConsumed = 0.0
    var totalGlassesConsumed = 0.0
    var totalFitbitWaterConsumedToday = 0.0
    var specificWater = Water()
    @IBOutlet weak var specificDateLabel: UILabel!
    @IBOutlet weak var glassesOfOtherConsumedLabel: UILabel!
    @IBOutlet weak var glassesOfWaterConsumedLabel: UILabel!
    
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var specificDayView: UIView!
    @IBOutlet weak var specificDateWaterView: UICircularProgressRingView!
    @IBOutlet weak var dayView01: UICircularProgressRingView!
    @IBOutlet weak var dayView02: UICircularProgressRingView!
    @IBOutlet weak var dayView03: UICircularProgressRingView!
    @IBOutlet weak var recommendedGlassesLabel: UILabel!
    @IBOutlet weak var dayView04: UICircularProgressRingView!
    @IBOutlet weak var dayView05: UICircularProgressRingView!
    @IBOutlet weak var dayView06: UICircularProgressRingView!
    @IBOutlet weak var dayView07: UICircularProgressRingView!
    
    var dayLabels = [UILabel]()
    var dayViews = [UICircularProgressRingView]()
    
    
    
    @IBOutlet weak var day01Label: UILabel!
    @IBOutlet weak var day02Label: UILabel!
    @IBOutlet weak var day03Label: UILabel!
    @IBOutlet weak var day04Label: UILabel!
    @IBOutlet weak var day05Label: UILabel!
    @IBOutlet weak var day06Label: UILabel!
    @IBOutlet weak var day07Label: UILabel!
    @IBOutlet weak var backButtonDay: UIButton!
    @IBOutlet weak var forwardButtonDay: UIButton!
    
    @IBOutlet weak var weekRangeLabel: UILabel!
    @IBOutlet weak var specificLongDateLabel: UILabel!
    @IBOutlet weak var backButtonWeek: UIButton!
    @IBOutlet weak var forwardButtonWeek: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.enteredBackground(notification:)), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillTerminate(notification:)), name:NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillResign(notification:)), name:NSNotification.Name.UIApplicationWillResignActive, object: nil)

        dayLabels = [self.day01Label,
                  self.day02Label,
                  self.day03Label,
                  self.day04Label,
                  self.day05Label,
                  self.day06Label,
                  self.day07Label]
        
        dayViews = [self.dayView01,
                         self.dayView02,
                         self.dayView03,
                         self.dayView04,
                         self.dayView05,
                         self.dayView06,
                         self.dayView07]
        self.makeViewSwipeable()
        self.getWaterGoal()

        self.getWaterNWeeksAgo(weeksAgo: 0)
        // Do any additional setup after loading the view.
        self.setSpecificDate(daysAgo: 0)

    }
    
    func enteredBackground(notification : NSNotification) {
        print("Observer method called")
    }
    
    func appWillTerminate(notification: NSNotification) {
        print("WILL TERM")
    }
    func appWillResign(notification: NSNotification) {
        print("RESIGN")
        self.saveWaterLogsToFitbit()
    }
    
    func saveWaterLogsToFitbit() {
        let newCups = self.glassesOfWaterConsumed - self.totalFitbitWaterConsumedToday
        print("NEW CUPS OF WATER: \(newCups)")
        if newCups < 1 { return }
        self.fbreqs.logWater(date: self.specificWater.dateString, amount: "\(newCups)", unit: "cup") { response, err in
            print("RESPONSE: \(response), Error: \(err)")
            
        }
    }
    
    
    func makeViewSwipeable() {
        
        
        let swipeLeftSpecific = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftSpecificDate))
        swipeLeftSpecific.direction = .left
        self.specificDayView.addGestureRecognizer(swipeLeftSpecific)
        
        let swipeRightSpecific = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightSpecificDate))
        swipeRightSpecific.direction = .right
        self.specificDayView.addGestureRecognizer(swipeRightSpecific)
        
        let swipeLeftWeek = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftWeek))
        swipeLeftWeek.direction = .left
        self.weekView.addGestureRecognizer(swipeLeftWeek)
        
        let swipeRightWeek = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightWeek))
        swipeRightWeek.direction = .right
        self.weekView.addGestureRecognizer(swipeRightWeek)
        
        
        scrollView.panGestureRecognizer.require(toFail: swipeLeftSpecific)
        scrollView.panGestureRecognizer.require(toFail: swipeRightSpecific)
        scrollView.panGestureRecognizer.require(toFail: swipeLeftWeek)
        scrollView.panGestureRecognizer.require(toFail: swipeRightWeek)
        self.forwardButtonWeek.addTarget(self, action: #selector(self.swipeLeftWeek), for: .touchUpInside)
        self.backButtonWeek.addTarget(self, action: #selector(self.swipeRightWeek), for: .touchUpInside)
        self.forwardButtonDay.addTarget(self, action: #selector(self.swipeLeftSpecificDate), for: .touchUpInside)
        self.backButtonDay.addTarget(self, action: #selector(self.swipeRightSpecificDate), for: .touchUpInside)
        self.forwardButtonDay.isHidden = true
        self.forwardButtonWeek.isHidden = true
    }

    func swipeLeftSpecificDate() {
        print("go forward day")
        if currentDaysBack == 0 {
            return
        }
        self.saveWaterLogsToFitbit()

        currentDaysBack -= 1
        print(currentDaysBack)
        
        if currentDaysBack == 0 {
            self.forwardButtonDay.isHidden = true
            self.specificDateLabel.text = "Last Night"
        }
        self.setSpecificDate(daysAgo:currentDaysBack)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("WILL DISAPPEAR")
        self.saveWaterLogsToFitbit()
        // Show the navigation bar on other view controllers
    }
    
    func swipeRightSpecificDate() {
        // this means go back
        print("go back day")
        self.saveWaterLogsToFitbit()
        self.forwardButtonDay.isHidden = false
        currentDaysBack += 1
        print(currentDaysBack)
        self.specificDateLabel.text = ""
        self.setSpecificDate(daysAgo:currentDaysBack)
    }
    
    func swipeLeftWeek() {
        print("go forward week")
        if currentWeeksBack == 0 {
            return
        }
        currentWeeksBack -= 1
        print(currentWeeksBack)
        if currentWeeksBack == 0 {
            self.forwardButtonWeek.isHidden = true
        }
        self.getWaterNWeeksAgo(weeksAgo: currentWeeksBack)
    }
    
    func swipeRightWeek() {
        // this means go back
        print("go back week")
        print(currentWeeksBack)
        self.forwardButtonWeek.isHidden = false
        currentWeeksBack += 1
        self.getWaterNWeeksAgo(weeksAgo: currentWeeksBack)
        
    }
    
    func loadWaterFitibt() {

        
    }
    
    @IBAction func adviceButtonLinkPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string:"http://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/pregnancy-nutrition/art-20043844?pg=2" )!)
        present(svc, animated: true, completion: nil)

    }
    
    func getWaterGoal() {
        self.fbreqs.getWaterGoal() { waterGoal, error in
            if let goal = waterGoal {
                print("GOAL PRINT: \(goal)")
                self.recommendedGlassesLabel.text = "of recommended \(goal) glasses"
                 self.recommendedGlassesLabel.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
                self.recommendedGlassesLabel.numberOfLines = 0         // Do any additional setup after loading the view.
                self.specificDateWaterView.maxValue = CGFloat(Double(goal) ?? 10)
                for v in self.dayViews {
                    v.maxValue = CGFloat(Double(goal) ?? 10)
                }
                
                //self.recommendedSleepLabel.text = "of recommended \(goal) hours"

            }

        }
    }
    
    
    func setSpecificDate(daysAgo: Int) {
        self.loadWaterNDaysAgo(daysAgo: daysAgo) { water, err in
            self.specificWater = water ?? Water()
            self.specificWater.dateString = Helpers.getDateNDaysAgo(daysAgo: daysAgo).dateString
            
            let waterConsumed = water?.cupsConsumed ?? 0
            self.glassesOfWaterConsumed = waterConsumed
            self.totalFitbitWaterConsumedToday = waterConsumed
            self.totalGlassesConsumed = self.glassesOfWaterConsumed + self.glassesOfOtherConsumed
            self.glassesOfWaterConsumedLabel.text =  String(format:"%.0f", self.glassesOfWaterConsumed)
            self.glassesOfOtherConsumedLabel.text = String(format:"%.0f", self.glassesOfOtherConsumed)
            
            self.setProgressRing(ring: self.specificDateWaterView, value: self.totalGlassesConsumed)
            let nDaysAgo = Helpers.getDateNDaysAgo(daysAgo: daysAgo)
            
            self.specificLongDateLabel.text = Helpers.getLongDate(date: nDaysAgo.date)

            
        }
    }
    
    func loadWaterNDaysAgo(daysAgo: Int, completionHandler: @escaping (Water?, Error?) -> ()) {
        let past = Helpers.getDateNDaysAgo(daysAgo: daysAgo)
        let date = past.date
        let dateString = past.dateString
        self.fbreqs.getWaterLogs(date: dateString) { water, error in
            if let water = water {
                completionHandler(water , nil)
            }
            
            
        }
    }
    
    
    func getWaterNWeeksAgo(weeksAgo: Int) {
        let past = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo)
        let date = past.date
        let labelRange = Helpers.getShortDateRangeString(date: date)
        let dateString = past.dateString
        print("water date string: \(dateString)")
        self.weekRangeLabel.text = labelRange

        self.fbreqs.getWaterLastWeek(date: dateString) { waters, error in
            if waters != nil {
                var i = 0
                for water in waters! {
                    print("Water: \(water.cupsConsumed) DOW: \(water.dayOfWeek)")
                    let cupsConsumed = water.cupsConsumed
                    self.dayLabels[i].text = water.dayOfWeek
                    self.setProgressRing(ring: self.dayViews[i], value: cupsConsumed)
                    i += 1
                }
            }
        }
    }
    
    func setProgressRing(ring: UICircularProgressRingView, value: Double, animationDuration: Double = 3) {
        ring.viewStyle = 2
        ring.maxValue = 10
        ring.setProgress(value: CGFloat(value), animationDuration: TimeInterval(animationDuration), completion: nil)
        
    }
    func updateTotalGlassesConsumed() {
        self.setProgressRing(ring: self.specificDateWaterView, value: self.totalGlassesConsumed, animationDuration:  0)
    }
    
    @IBAction func increaseWaterGlassesButtonPressed(_ sender: Any) {
        self.glassesOfWaterConsumed += 1
        self.totalGlassesConsumed = self.glassesOfWaterConsumed + self.glassesOfOtherConsumed
        self.glassesOfWaterConsumedLabel.text = String(format:"%.0f", self.glassesOfWaterConsumed)
        self.updateTotalGlassesConsumed()
    }
    @IBAction func decreaseWaterGlassesButtonPressed(_ sender: Any) {
        if self.glassesOfWaterConsumed <= self.totalFitbitWaterConsumedToday {
            return
        } else {
            self.glassesOfWaterConsumed -= 1
            self.totalGlassesConsumed = self.glassesOfWaterConsumed + self.glassesOfOtherConsumed
            self.glassesOfWaterConsumedLabel.text = String(format:"%.0f", self.glassesOfWaterConsumed)
            self.updateTotalGlassesConsumed()
        }
    }
    @IBAction func increaseOtherGlassesButtonPressed(_ sender: Any) {
        self.glassesOfOtherConsumed += 1
        self.totalGlassesConsumed = self.glassesOfWaterConsumed + self.glassesOfOtherConsumed
        self.glassesOfOtherConsumedLabel.text = String(format:"%.0f", self.glassesOfOtherConsumed)
        self.updateTotalGlassesConsumed()
    }

    @IBAction func decreaseOtherGlassesButtonPressed(_ sender: Any) {
        if self.glassesOfOtherConsumed <= self.totalFitbitWaterConsumedToday {
            return
        } else {
            self.glassesOfOtherConsumed -= 1
            self.totalGlassesConsumed = self.glassesOfWaterConsumed + self.glassesOfOtherConsumed
            self.glassesOfOtherConsumedLabel.text = String(format:"%.0f", self.glassesOfOtherConsumed)
            self.updateTotalGlassesConsumed()
        }
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
