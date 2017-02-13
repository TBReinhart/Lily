//
//  HeartRateViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 2/8/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SafariServices

class HeartRateViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var restingBPMLabel: UILabel!
    @IBOutlet weak var maximumBPMLabel: UILabel!
    @IBOutlet weak var averageBPMLabel: UILabel!
    @IBOutlet weak var weekRange: UILabel!
    
    var pastHeartRateLabels = [UILabel]()
    var pastDayOfWeekLabels = [UILabel]()
    
    @IBOutlet weak var day01View: UIView!
    @IBOutlet weak var day02View: UIView!
    @IBOutlet weak var day03View: UIView!
    @IBOutlet weak var day04View: UIView!
    @IBOutlet weak var day05View: UIView!
    @IBOutlet weak var day06View: UIView!
    @IBOutlet weak var day07View: UIView!
    
    @IBOutlet weak var day01HeartRate: UILabel!
    @IBOutlet weak var day01DayOfWeek: UILabel!
    
    @IBOutlet weak var day02HeartRate: UILabel!
    @IBOutlet weak var day02DayOfWeek: UILabel!
    
    @IBOutlet weak var day03HeartRate: UILabel!
    @IBOutlet weak var day03DayOfWeek: UILabel!
    
    @IBOutlet weak var day04HeartRate: UILabel!
    @IBOutlet weak var day04DayOfWeek: UILabel!
    
    @IBOutlet weak var day05HeartRate: UILabel!
    @IBOutlet weak var day05DayOfWeek: UILabel!
    
    @IBOutlet weak var day06HeartRate: UILabel!
    @IBOutlet weak var day06DayOfWeek: UILabel!
    
    @IBOutlet weak var day07HeartRate: UILabel!
    @IBOutlet weak var day07DayOfWeek: UILabel!
    
    let fbreqs = FitbitRequests()
    var currentWeeksBack = 0
    var currentDaysBack = 0
    
    @IBOutlet weak var backDayButton: UIButton!
    @IBOutlet weak var forwardDayButton: UIButton!
    
    @IBOutlet weak var backWeekButton: UIButton!
    @IBOutlet weak var forwardWeekButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pastDayOfWeekLabels = [self.day01DayOfWeek,self.day02DayOfWeek,self.day03DayOfWeek,self.day04DayOfWeek,self.day05DayOfWeek,self.day06DayOfWeek,self.day07DayOfWeek]
        self.pastHeartRateLabels = [self.day01HeartRate,self.day02HeartRate,self.day03HeartRate,self.day04HeartRate,self.day05HeartRate,self.day06HeartRate,self.day07HeartRate]
        self.makeViewSwipeable()
        self.getHeartRateNWeeksAgo(weeksAgo: 0)
        self.getHeartRateNDaysAgo(daysAgo: 0)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func adviceButtonLinkPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string:"http://www.merckmanuals.com/home/women-s-health-issues/normal-pregnancy/physical-changes-during-pregnancy" )!)
        present(svc, animated: true, completion: nil)
        
    }
    
    
    func getHeartRateNWeeksAgo(weeksAgo: Int) {
        let endDate = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo).dateString
        
        self.fbreqs.getHeartRateTimeSeriesFromPeriod(date: endDate, period: "7d") { heartRates, err in
            if let hrs = heartRates {
                var i = 0
                for hr in hrs {
                    self.pastHeartRateLabels[i].text = "\(hr.restingHeartRate )"
                    self.pastDayOfWeekLabels[i].text = "\(hr.dayOfWeek)"
//                    self.pastDayOfWeekLabels[i].sizeToFit()
                    self.pastDayOfWeekLabels[i].adjustsFontSizeToFitWidth = true

                    i += 1
                }
            }
        }
        
    }
    func getHeartRateNDaysAgo(daysAgo: Int) {
        let date = Helpers.getDateNDaysAgo(daysAgo: daysAgo).dateString
        self.fbreqs.getHeartRateTimeSeriesFrom1DayPeriod(date: date, period: "1d") { heartRate, err in
            print("HR: \(heartRate)")
            self.restingBPMLabel.text = "\(heartRate?.restingHeartRate ?? 0)"
            self.averageBPMLabel.text = "\(heartRate?.averageBPM ?? 0)"
            self.maximumBPMLabel.text = "\(heartRate?.maximumBPM ?? 0)"
        }
    }
    
    
    
    
    func makeViewSwipeable() {
        
        
        let swipeLeftSpecific = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftSpecificDate))
        swipeLeftSpecific.direction = .left
        self.dayView.addGestureRecognizer(swipeLeftSpecific)
        
        let swipeRightSpecific = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightSpecificDate))
        swipeRightSpecific.direction = .right
        self.dayView.addGestureRecognizer(swipeRightSpecific)
        
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
        self.forwardWeekButton.addTarget(self, action: #selector(self.swipeLeftWeek), for: .touchUpInside)
        self.backWeekButton.addTarget(self, action: #selector(self.swipeRightWeek), for: .touchUpInside)
        self.forwardDayButton.addTarget(self, action: #selector(self.swipeLeftSpecificDate), for: .touchUpInside)
        self.backDayButton.addTarget(self, action: #selector(self.swipeRightSpecificDate), for: .touchUpInside)
        self.forwardDayButton.isHidden = true
        self.forwardWeekButton.isHidden = true
    }
    
    
    
    func swipeLeftSpecificDate() {
        print("go forward day")
        if currentDaysBack == 0 {
            return
        }
        
        currentDaysBack -= 1
        print(currentDaysBack)
        
        if currentDaysBack == 0 {
            self.forwardDayButton.isHidden = true
            self.dayLabel.text = "Today"
        }
        self.getHeartRateNDaysAgo(daysAgo: currentDaysBack)

        
    }
    
    func swipeRightSpecificDate() {
        // this means go back
        print("go back day")
        self.forwardDayButton.isHidden = false
        currentDaysBack += 1
        print(currentDaysBack)
        self.dayLabel.text = ""
        self.getHeartRateNDaysAgo(daysAgo: currentDaysBack)

    }
    
    func swipeLeftWeek() {
        print("go forward week")
        if currentWeeksBack == 0 {
            return
        }
        currentWeeksBack -= 1
        print(currentWeeksBack)
        if currentWeeksBack == 0 {
            self.forwardWeekButton.isHidden = true
        }
        self.getHeartRateNWeeksAgo(weeksAgo: currentWeeksBack)
    }
    
    func swipeRightWeek() {
        // this means go back
        print("go back week")
        print(currentWeeksBack)
        self.forwardWeekButton.isHidden = false
        currentWeeksBack += 1
        self.getHeartRateNWeeksAgo(weeksAgo: currentWeeksBack)
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
