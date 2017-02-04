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

class SleepViewController: UIViewController {

    var fbreqs = FitbitRequests()
    var sleepObject = Sleep()
    var weekSleepObjects = [Sleep?](repeating: nil, count:7)

    @IBOutlet weak var recommendedSleepLabel: UILabel!
    
    @IBOutlet weak var specificDateLabel: UILabel!
    @IBOutlet weak var specificNightProgressRing: UICircularProgressRingView!
    @IBOutlet weak var specificRestlessLabel: UILabel!
    
    @IBOutlet weak var specificEfficiencyLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

        loadSleepFitbit()
        self.getLastWeekSleep()
        // Swift

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
                self.loadSleepLastNight() { sleep, err in
                    let minutesRestless = sleep?.restlessCount
                    let sleepEfficiency = sleep?.efficiency
                    let specificTimeSlept = String(format:"%.1f", sleep?.sleepTimeRounded ?? 0.0)
                    self.specificDateLabel.text = sleep?.dateLong ?? "January 1, 2017"
                    
                    print("SPECIFIC SLEEP: \(specificTimeSlept)")
//                    self.specificNightProgressRing.animationStyle = kCAMediaTimingFunctionLinear
                    self.setProgressRing(ring: self.specificNightProgressRing, value: Double(specificTimeSlept)!)
                    self.specificRestlessLabel.text = "\(minutesRestless ?? 0)"
                    self.specificEfficiencyLabel.text = "\(sleepEfficiency ?? 100)"
                    
                }
            }
        }
       
    }
    
    func setProgressRing(ring: UICircularProgressRingView, value: Double) {
        ring.viewStyle = 2
        ring.setProgress(value: CGFloat(value), animationDuration: 3, completion: nil)
        
    }
    
    func getLastWeekSleep() {
        self.fbreqs.getSleepLastWeek() { sleeps, error in
            if sleeps != nil {
                self.weekSleepObjects = sleeps!
                print("PRINTING SLEEPS")
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

    func loadSleepLastNight(completionHandler: @escaping (Sleep?, Error?) -> ()) {
        self.fbreqs.getSleepLogs() { sleep, error in
            completionHandler(sleep ?? Sleep(), nil)
            
         
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
