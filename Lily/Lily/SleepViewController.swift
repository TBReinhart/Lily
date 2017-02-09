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
import Dropper
import SafariServices

class SleepViewController: UIViewController, UIGestureRecognizerDelegate {
    let dropper = Dropper(width: 75, height: 200)
    var currentWeeksBack = 0
    var currentDaysBack = 0
    var fbreqs = FitbitRequests()
    var sleepObject = Sleep()
    var weekSleepObjects = [Sleep?](repeating: nil, count:7)

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
    
    @IBOutlet weak var sleepOptionDropdownButton: UIButton!
    override func viewDidLoad() {
        self.title = "Lily"
        self.previousWeekDateRangeLabel.text = Helpers.getShortDateRangeString(date: Date())
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
        self.specificDateLabel.sizeToFit()
        self.previousWeekDateRangeLabel.sizeToFit()
        self.recommendedSleepLabel.sizeToFit()
        self.specificEfficiencyLabel.sizeToFit()
        self.specificRestlessLabel.sizeToFit()
        loadSleepFitbit()
        self.getSleepNumberOfWeeksAgo(weeksAgo: 0)
        super.viewDidLoad()


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
        print("Hello World")
    }
    @IBAction func adviceButtonLinkPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string:"http://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/sleep-during-pregnancy/art-20043827" )!)
        present(svc, animated: true, completion: nil)
    }

    
    func swipeLeftSpecificDate() {
        print("go forward day")
        if currentDaysBack == 0 {
            return
        }
        currentDaysBack -= 1
        print(currentDaysBack)
        
        if currentDaysBack == 0 {
            self.forwardButtonSpecificDate.isHidden = true
            self.specificDateLabel.text = "Last Night"
        }
        self.setSpecificDateSleep(daysAgo: currentDaysBack)
        
    }
    
    func swipeRightSpecificDate() {
        // this means go back
        print("go back day")
        self.forwardButtonSpecificDate.isHidden = false
        currentDaysBack += 1
        print(currentDaysBack)
        self.specificDateLabel.text = ""
        self.setSpecificDateSleep(daysAgo: currentDaysBack)
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
        self.getSleepNumberOfWeeksAgo(weeksAgo: currentWeeksBack)
    }
    
    func swipeRightWeek() {
        // this means go back
        print("go back week")
        print(currentWeeksBack)
        self.forwardButtonWeek.isHidden = false
        currentWeeksBack += 1
        self.getSleepNumberOfWeeksAgo(weeksAgo: currentWeeksBack)

    }

    func loadSleepFitbit() {
        self.loadSleepGoal() { sleepGoal, error in
            if let goal = sleepGoal {
                print("GOAL PRINT: \(goal)")
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
            print("TIME SPECIFIC: \(sleep?.dateLong)")
            
            self.specificLongDateLabel.text = sleep?.dateLong ?? "January 1, 2017"
            
            print("SPECIFIC SLEEP: \(specificTimeSlept)")
            self.setProgressRing(ring: self.specificNightProgressRing, value: Double(specificTimeSlept)!)
            self.specificRestlessLabel.text = "\(minutesRestless ?? 0)"
            self.specificEfficiencyLabel.text = "\(sleepEfficiency ?? 100)%"
            
        }
    }
    
    func setProgressRing(ring: UICircularProgressRingView, value: Double) {
        ring.viewStyle = 2
        ring.setProgress(value: CGFloat(value), animationDuration: 3, completion: nil)
        
    }
    
    func getSleepNumberOfWeeksAgo(weeksAgo: Int) {
        let past = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo)
        let date = past.date
        let labelRange = Helpers.getShortDateRangeString(date: date)
        let dateString = past.dateString
        self.previousWeekDateRangeLabel.text = labelRange
        print("Label: \(labelRange)")
        print("Date String: \(dateString)")
        self.fbreqs.getSleepLastWeek(date: dateString) { sleeps, error in
            if sleeps != nil {
                self.weekSleepObjects = sleeps!
                print("PRINTING SLEEPS IN WEEKS AGO: \(weeksAgo)")
                var i = 0
                for sleep in self.weekSleepObjects {
                    let dow = sleep?.dayOfWeek ?? "NONE"
                    let sleepTimeRounded = sleep?.sleepTimeRounded ?? 0.0
                    let shortDateString = sleep?.shortDateString ?? "1/1"
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
        let date = past.date
        let dateString = past.dateString
        self.fbreqs.getSleepLogs(date: dateString) { sleep, error in
            completionHandler(sleep ?? Sleep(), nil)
            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sleepOptionDropdownPressed(_ sender: Any) {
        
        if dropper.status == .hidden {
            dropper.items = ["Hours of Sleep", "Minutes of Restless Sleep", "Sleep Efficiency"]
            dropper.theme = Dropper.Themes.black(UIColor.lightGray) // Uses Black UIColor
            dropper.backgroundColor = UIColor.lightGray
            dropper.cellTextSize = CGFloat(10)
            dropper.delegate = self
            dropper.spacing = CGFloat(1)
            dropper.trimCorners = true
            dropper.showWithAnimation(0.15, options: Dropper.Alignment.center, button: sleepOptionDropdownButton)
        } else {
            dropper.hideWithAnimation(0.1)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (dropper.isHidden == false) { // Checks if Dropper is visible
            dropper.hideWithAnimation(0.1) // Hides Dropper
        }
    }

}

extension SleepViewController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        sleepOptionDropdownButton.setTitle(contents, for: UIControlState.normal)
    }
}
