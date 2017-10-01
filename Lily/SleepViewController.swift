//
//  SleepViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 1/31/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SwiftyJSON
import UICircularProgressRing
import SafariServices
import BusyNavigationBar

class SleepViewController: UIViewController, UIGestureRecognizerDelegate {
    var currentWeeksBack = 0
    var currentDaysBack = 0
    var fbreqs = FitbitRequests()
    var sleepObject = Sleep()
    var weekSleepObjects = [Sleep?](repeating: nil, count:7)

    var options = BusyNavigationBarOptions()

    // TODO
    // create a "cache" of this screen and refresh every so often
    // http://stackoverflow.com/questions/28418035/synchronizing-remote-json-data-to-local-cache-storage-in-ios-swift
    
    @IBOutlet weak var specificDateLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var specificDateView: UIView!
    @IBOutlet weak var previousWeekDateRangeLabel: UILabel!
    @IBOutlet weak var specificDateImageView: UIImageView!
    @IBOutlet weak var previousWeekView: UIView!
    @IBOutlet weak var recommendedSleepLabel: UILabel!
    
    @IBOutlet weak var specificLongDateLabel: UILabel!
    @IBOutlet weak var specificNightProgressRing: UICircularProgressRingView!
    @IBOutlet weak var specificRestlessLabel: UILabel!
    
    @IBOutlet weak var specificEfficiencyLabel: UILabel!
    
    @IBOutlet weak var forwardButtonSpecificDate: UIButton!
    @IBOutlet weak var backButtonSpecificDate: UIButton!
    @IBOutlet weak var forwardButtonWeek: UIButton!
    @IBOutlet weak var backButtonWeek: UIButton!
    @IBOutlet weak var dayLabel07: UILabel!
    @IBOutlet weak var dayLabel06: UILabel!
    @IBOutlet weak var dayLabel05: UILabel!
    @IBOutlet weak var dayLabel04: UILabel!
    @IBOutlet weak var dayLabel03: UILabel!
    @IBOutlet weak var dayLabel02: UILabel!
    @IBOutlet weak var dayLabel01: UILabel!
    var labels = [UILabel]()
    
    var lastWeekViews = [UICircularProgressRingView]()
    @IBOutlet weak var dayView01: UICircularProgressRingView!
    @IBOutlet weak var dayView02: UICircularProgressRingView!
    @IBOutlet weak var dayView03: UICircularProgressRingView!
    @IBOutlet weak var dayView04: UICircularProgressRingView!
    @IBOutlet weak var dayView05: UICircularProgressRingView!
    @IBOutlet weak var dayView06: UICircularProgressRingView!
    @IBOutlet weak var dayView07: UICircularProgressRingView!
    let alertController = UIAlertController(title: nil, message: "Choose your sleep metric", preferredStyle: .actionSheet)

    @IBOutlet weak var sleepOptionDropdownButton: UIButton!
    
    override func viewDidLoad() {
        self.title = "Lily"
        self.previousWeekDateRangeLabel.text = Helpers.getShortDateRangeString(date: Date())
        self.previousWeekDateRangeLabel.adjustsFontSizeToFitWidth = true
        self.options.animationType = .stripes
        /// Color of the shapes. Defaults to gray.
        self.options.color = UIColor.gray
        /// Alpha of the animation layer. Remember that there is also an additional (constant) gradient mask over the animation layer. Defaults to 0.5.
        self.options.alpha = 0.5
        /// Width of the bar. Defaults to 20.
        self.options.barWidth = 20
        /// Gap between bars. Defaults to 30.
        self.options.gapWidth = 30
        /// Speed of the animation. 1 corresponds to 0.5 sec. Defaults to 1.
        self.options.speed = 1
        /// Flag for enabling the transparent masking layer over the animation layer.
        self.options.transparentMaskEnabled = true
        self.navigationController?.navigationBar.start(options)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.navigationController?.navigationBar.stop()
        })
        
        self.makeViewSwipeable()
        self.forwardButtonSpecificDate.isHidden = true
        self.forwardButtonWeek.isHidden = true
        labels = [self.dayLabel01,
                  self.dayLabel02,
                  self.dayLabel03,
                  self.dayLabel04,
                  self.dayLabel05,
                  self.dayLabel06,
                  self.dayLabel07]
        lastWeekViews = [self.dayView01,
                  self.dayView02,
                  self.dayView03,
                  self.dayView04,
                  self.dayView05,
                  self.dayView06,
                  self.dayView07]

        for l in labels {
            l.sizeToFit()
        }
        
        for v in lastWeekViews {
            v.valueIndicator = ""
        }
        
        self.specificDateLabel.sizeToFit()
        self.previousWeekDateRangeLabel.sizeToFit()
        self.recommendedSleepLabel.sizeToFit()
        self.specificEfficiencyLabel.sizeToFit()
        self.specificRestlessLabel.sizeToFit()
        loadSleepFitbit()
        self.getSleepNumberOfWeeksAgo(weeksAgo: 0)
        super.viewDidLoad()

        let oneAction = UIAlertAction(title: "Hours of Sleep", style: .default) { _ in
        }
        let twoAction = UIAlertAction(title: "Minutes of Restless Sleep", style: .default) { _ in
        }
        let threeAction = UIAlertAction(title: "Sleep Efficiency", style: .default) { _ in
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }

        alertController.addAction(oneAction)
        alertController.addAction(twoAction)
        alertController.addAction(threeAction)
        alertController.addAction(cancelAction)

    }
    
    func makeViewSwipeable() {
        
        
        let swipeLeftSpecific = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftSpecificDate))
        swipeLeftSpecific.direction = .left
        self.specificDateView.addGestureRecognizer(swipeLeftSpecific)
        
        let swipeRightSpecific = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightSpecificDate))
        swipeRightSpecific.direction = .right
        self.specificDateView.addGestureRecognizer(swipeRightSpecific)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SleepViewController.handleTap(_:)))
        tap.delegate = self
        self.specificDateView.addGestureRecognizer(tap)
        
        let swipeLeftWeek = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftWeek))
        swipeLeftWeek.direction = .left
        self.previousWeekView.addGestureRecognizer(swipeLeftWeek)
        
        let swipeRightWeek = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightWeek))
        swipeRightWeek.direction = .right
        self.previousWeekView.addGestureRecognizer(swipeRightWeek)
        scrollView.panGestureRecognizer.require(toFail: swipeLeftSpecific)
        scrollView.panGestureRecognizer.require(toFail: swipeRightSpecific)
        scrollView.panGestureRecognizer.require(toFail: swipeLeftWeek)
        scrollView.panGestureRecognizer.require(toFail: swipeRightWeek)
        scrollView.panGestureRecognizer.require(toFail: tap)
        self.forwardButtonWeek.addTarget(self, action: #selector(self.swipeLeftWeek), for: .touchUpInside)
        self.backButtonWeek.addTarget(self, action: #selector(self.swipeRightWeek), for: .touchUpInside)
        self.forwardButtonSpecificDate.addTarget(self, action: #selector(self.swipeLeftSpecificDate), for: .touchUpInside)
        self.backButtonSpecificDate.addTarget(self, action: #selector(self.swipeRightSpecificDate), for: .touchUpInside)
        self.getSleepNumberOfWeeksAgo(weeksAgo: 0)

    }
    

    func handleTap(_ sender: UITapGestureRecognizer) {
    }
    @IBAction func adviceButtonLinkPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string:"http://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/sleep-during-pregnancy/art-20043827" )!)
        present(svc, animated: true, completion: nil)
    }

    
    func swipeLeftSpecificDate() {
        if currentDaysBack == 0 {
            return
        }
        currentDaysBack -= 1
        
        if currentDaysBack == 0 {
            self.forwardButtonSpecificDate.isHidden = true
            self.specificDateLabel.text = "Last Night"
        }  else {
            let date = Helpers.getDateNDaysAgo(daysAgo: currentDaysBack)
            self.specificDateLabel.text = Helpers.getWeekDayFromDate(date: date.0)
        }
        self.specificDateLabel.adjustsFontSizeToFitWidth = true

        self.setSpecificDateSleep(daysAgo: currentDaysBack)
        
    }
    
    func swipeRightSpecificDate() {
        // this means go back
        self.forwardButtonSpecificDate.isHidden = false
        currentDaysBack += 1
        let date = Helpers.getDateNDaysAgo(daysAgo: currentDaysBack)
        self.specificDateLabel.text = Helpers.getWeekDayFromDate(date: date.0)
        self.specificDateLabel.adjustsFontSizeToFitWidth = true

        self.setSpecificDateSleep(daysAgo: currentDaysBack)
    }
    
    func swipeLeftWeek() {
        if currentWeeksBack == 0 {
            return
        }
        currentWeeksBack -= 1
        if currentWeeksBack == 0 {
            self.forwardButtonWeek.isHidden = true
        }
        self.getSleepNumberOfWeeksAgo(weeksAgo: currentWeeksBack)
    }
    
    func swipeRightWeek() {
        // this means go back
        self.forwardButtonWeek.isHidden = false
        currentWeeksBack += 1
        self.getSleepNumberOfWeeksAgo(weeksAgo: currentWeeksBack)

    }

    func loadSleepFitbit() {
        self.loadSleepGoal() { sleepGoal, error in
            if let goal = sleepGoal {
                self.specificNightProgressRing.maxValue = CGFloat(goal)
                for v in self.lastWeekViews {
                    v.maxValue = CGFloat(goal)
                }
                self.recommendedSleepLabel.text = "of recommended \(goal) hours"
                self.recommendedSleepLabel.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
                self.recommendedSleepLabel.numberOfLines = 0         // Do any additional setup after loading the view.
                self.setSpecificDateSleep(daysAgo: 0)
            }
        }
       
    }
    
    func setSpecificDateSleep(daysAgo: Int) {
        self.loadSleepNDaysAgo(daysAgo: daysAgo) { sleep, err in
            let minutesRestless = sleep?.restlessCount
            let sleepEfficiency = sleep?.efficiency
            let specificTimeSlept = String(format:"%.1f", sleep?.sleepTimeRounded ?? 0.0)
            
            self.specificLongDateLabel.text = sleep?.dateLong ?? "January 1, 2017"
            
            self.setProgressRing(ring: self.specificNightProgressRing, value: Double(specificTimeSlept)!)
            self.specificRestlessLabel.text = "\(minutesRestless ?? 0)"
            self.specificEfficiencyLabel.text = "\(sleepEfficiency ?? 100)%"
            
        }
    }
    
    func setProgressRing(ring: UICircularProgressRingView, value: Double,  animationDuration: Double = 3) {
        ring.viewStyle = 2
        ring.valueIndicator = ""
        ring.setProgress(value: CGFloat(value), animationDuration: TimeInterval(animationDuration), completion: nil)
    }
    
    func getSleepNumberOfWeeksAgo(weeksAgo: Int) {
        let past = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo)
        let date = past.date
        let labelRange = Helpers.getShortDateRangeString(date: date)
        let dateString = past.dateString
        self.previousWeekDateRangeLabel.text = labelRange
        self.fbreqs.getSleepLastWeek(date: dateString) { sleeps, error in
            if sleeps != nil {
                self.weekSleepObjects = sleeps!
                var i = 0
                for sleep in self.weekSleepObjects {
                    let dow = sleep?.dayOfWeek ?? "NONE"
                    let sleepTimeRounded = sleep?.sleepTimeRounded ?? 0.0
                    self.labels[i].text = dow
                    self.setProgressRing(ring: self.lastWeekViews[i], value: sleepTimeRounded)
                    i += 1
                    
                }
            }
        }
    }
    
    func loadSleepGoal(completionHandler: @escaping (Double?, Error?) -> ()) {
        self.fbreqs.getSleepGoal() { minutes, error in
            var mins = 480.0
            if minutes != nil {
                mins = Double(minutes!)!
            }
            let sleepGoalRounded = round(10.0 * mins/60.0) / 10.0
            completionHandler(sleepGoalRounded, nil)
        }
    }

    
    func loadSleepNDaysAgo(daysAgo: Int, completionHandler: @escaping (Sleep?, Error?) -> ()) {
        let past = Helpers.getDateNDaysAgo(daysAgo: daysAgo)
        let dateString = past.dateString
        self.fbreqs.getSleepLogs(date: dateString) { sleep, error in
            completionHandler(sleep ?? Sleep(), nil)
            
            
        }
    }
    
    @IBAction func sleepOptionDropdownPressed(_ sender: Any) {
        self.present(self.alertController, animated: true)


    }
}
