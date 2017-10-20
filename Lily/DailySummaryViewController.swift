//
//  DailySummaryViewController.swift
//  Lily
//
//  Created by Brian Fisher on 10/6/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import UICircularProgressRing

class DailySummaryViewController: UIViewController {
    var fbreqs = FitbitRequests()
    var today = Date()
    var emotionsArray = [Bool]()
    var miserable = false
    var likeLaughing = false
    var angry = false
    var frustrated = false
    var likeCrying = false
    var irate = false
    var sad = false
    var scared = false
    var overwhelmed = false
    var excited = false
    var happy = false
    var nervous = false
    var todayDateString = ""
    var currentWeeksBack = 0
    var currentDaysBack = 0
    var theDay = 0
    @IBOutlet weak var miserableLabel: UILabel!
    @IBOutlet weak var likeLaughingLabel: UILabel!
    @IBOutlet weak var angryLabel: UILabel!
    @IBOutlet weak var frustratedLabel: UILabel!
    @IBOutlet weak var likeCryingLabel: UILabel!
    @IBOutlet weak var irateLabel: UILabel!
    @IBOutlet weak var sadLabel: UILabel!
    @IBOutlet weak var scaredLabel: UILabel!
    @IBOutlet weak var overwhelmedLabel: UILabel!
    @IBOutlet weak var excitedLabel: UILabel!
    @IBOutlet weak var happyLabel: UILabel!
    @IBOutlet weak var nervousLabel: UILabel!
    
    
    
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var dayBackButton: UIButton!
    @IBOutlet weak var dayForwardButton: UIButton!
    @IBOutlet weak var sedentaryTimeLabel: UILabel!
    @IBOutlet weak var lightlyActiveTimeLabel: UILabel!
    @IBOutlet weak var fairlyActiveTimeLabel: UILabel!
    @IBOutlet weak var veryActiveTimeLabel: UILabel!
    @IBOutlet weak var dayLongDateLabel: UILabel!
    @IBOutlet weak var babyKicksLabel: UILabel!
    @IBOutlet weak var specificDateWaterView: UICircularProgressRingView!
    @IBOutlet weak var specificNightProgressRing: UICircularProgressRingView!
    @IBOutlet weak var heartRateLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.miserableLabel.isHidden = true
        self.likeLaughingLabel.isHidden = true
        self.angryLabel.isHidden = true
        self.frustratedLabel.isHidden = true
        self.likeCryingLabel.isHidden = true
        self.irateLabel.isHidden = true
        self.sadLabel.isHidden = true
        self.scaredLabel.isHidden = true
        self.overwhelmedLabel.isHidden = true
        self.excitedLabel.isHidden = true
        self.happyLabel.isHidden = true
        self.nervousLabel.isHidden = true

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        todayDateString = df.string(from: today)
        self.todayLabel.text = todayDateString
        
        
        self.getWater()
        self.getSleep()
        self.getHeartRate()
        self.getActivityNDaysAgo(daysAgo: 0)
        self.getEmotions(daysAgo: 0)
        self.getTimeToTenKicks()

        // Do any additional setup after loading the view.
    }
    func getWater() {
    self.fbreqs.getWaterLogs(date: todayDateString) { water, error in
            if water != nil {
                let waterValue = Double("\(water?.cupsConsumed ?? 0)")
                self.setProgressRing(ring: self.specificDateWaterView, value: waterValue!)
                print(waterValue!)
            }
         }
    
    }
        func setProgressRing(ring: UICircularProgressRingView, value: Double, animationDuration: Double = 3) {
        ring.viewStyle = 2
        ring.valueIndicator = ""
        ring.maxValue = 10
        ring.setProgress(value: CGFloat(value), animationDuration: TimeInterval(animationDuration), completion: nil)
    }
    func getSleep() {
    self.fbreqs.getSleepLogs(date: todayDateString) { sleep, error in
            if sleep != nil {
                let sleepValue = Double("\(sleep?.sleepTimeRounded ?? 0)")
                self.setProgressRing(ring: self.specificNightProgressRing, value: sleepValue!)
                print(sleepValue!)
            }
    
        }
    
    }
    func getHeartRate() {
    self.fbreqs.getHeartRateTimeSeriesFrom1DayPeriod(date: todayDateString, period: "1d") { heartRate, err in
                var heartRateValue = "\(heartRate?.averageBPM ?? 0)"
                self.heartRateLabel.text = heartRateValue
                print(heartRateValue)
        }
    
    }
    func getActivityNDaysAgo(daysAgo: Int) {
        let date = Helpers.getDateNDaysAgo(daysAgo: daysAgo).dateString
        self.fbreqs.getDailyActivity(date: date) { activity, err in
            self.setLabelWithTime(label: self.sedentaryTimeLabel, minutes: activity.sedentaryMinutes)
            self.setLabelWithTime(label: self.lightlyActiveTimeLabel, minutes: activity.lightlyActiveMinutes)
            self.setLabelWithTime(label: self.fairlyActiveTimeLabel, minutes: activity.fairlyActiveMinutes)
            self.setLabelWithTime(label: self.veryActiveTimeLabel, minutes: activity.veryActiveMinutes)
            self.todayLabel.adjustsFontSizeToFitWidth = true

        }

    }
        func setLabelWithTime(label: UILabel, minutes: Int) {
        let formattedTime = Helpers.minutesToHoursMinutes(minutes: Int(minutes) )
        label.text = "\(formattedTime.0)h \(formattedTime.1)m"
        label.adjustsFontSizeToFitWidth = true

    }
    func getEmotions(daysAgo: Int) {
    self.emotionsArray.removeAll()
        self.miserableLabel.isHidden = true
        self.likeLaughingLabel.isHidden = true
        self.angryLabel.isHidden = true
        self.frustratedLabel.isHidden = true
        self.likeCryingLabel.isHidden = true
        self.irateLabel.isHidden = true
        self.sadLabel.isHidden = true
        self.scaredLabel.isHidden = true
        self.overwhelmedLabel.isHidden = true
        self.excitedLabel.isHidden = true
        self.happyLabel.isHidden = true
        self.nervousLabel.isHidden = true
    
    Helpers.loadDailyLogFromFirebase(key: "emotions", providedDate: self.today) { json, error in
            print("load daily log: \(json)")
            if json != nil {
                for (key, value) in json {
                   // print(key)
                    print(value)
                    self.emotionsArray.append(value.boolValue)
                  // self.setEmotionCell(emotion: key, selected: value.boolValue)
                  // create array to hold bool values then connect each one to emotion separately through ifs (array[num]) to access...
                }

            }
                print(self.emotionsArray)
                if(self.emotionsArray.count > 0){
                if (self.emotionsArray[0]) {
                self.miserableLabel.isHidden = false
                }
                if (self.emotionsArray[1]) {
                self.likeLaughingLabel.isHidden = false
                }
                if (self.emotionsArray[2]) {
                self.angryLabel.isHidden = false
                }
                if (self.emotionsArray[3]) {
                self.frustratedLabel.isHidden = false
                }
                if (self.emotionsArray[4]) {
                self.likeCryingLabel.isHidden = false
                }
                if (self.emotionsArray[5]) {
                self.irateLabel.isHidden = false
                }
                if (self.emotionsArray[6]) {
                self.sadLabel.isHidden = false
                }
                if (self.emotionsArray[7]) {
                self.scaredLabel.isHidden = false
                }
                if (self.emotionsArray[8]) {
                self.overwhelmedLabel.isHidden = false
                }
                if (self.emotionsArray[9]) {
                self.excitedLabel.isHidden = false
                }
                if (self.emotionsArray[10]) {
                self.happyLabel.isHidden = false
                }
                if (self.emotionsArray[11]) {
                self.nervousLabel.isHidden = false
                }
}
            }

    
    }
    
    
     func getTimeToTenKicks() {
     // currently doesn't work as baby movement screen doesn't work...
        let user = FIRAuth.auth()?.currentUser
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let todaysDateString = dateFormatter.string(from: today)
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        if let uid = user?.uid {
            ref.child("users").child(uid).child("logs/\(todaysDateString)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let json = JSON(snapshot.value!)
                print("JSON resp \(json)")
                let kicksTotal = json["kicksTotal"].intValue
                let kicksTotalTime = json["kicksTotalTime"].intValue
                var avg = 0.0
                if kicksTotalTime != 0 {
                    avg = Double(kicksTotal) / Double(kicksTotalTime)
                    avg *= 10
                    let avgStr = Helpers.timeString(time: Int(avg))
                    self.babyKicksLabel.text = avgStr
                    print(avg)
                }
               // Helpers.postDailyLogToFirebase  (key: "kicks10Average", value: Int(avg))

            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    @IBAction func swipeLeftSpecificDate() {
        if currentDaysBack == 0 {
            return
        }
        self.theDay = self.theDay + 1
        currentDaysBack -= 1
        if currentDaysBack == 0 {
            self.dayForwardButton.isHidden = true
            self.todayLabel.text = "Today"
        } else {
            let date = Helpers.getDateNDaysAgo(daysAgo: currentDaysBack)
            self.todayLabel.text = Helpers.getWeekDayFromDate(date: date.0)
        }
                print("forward")
         let df = DateFormatter()
     df.dateFormat = "yyyy-MM-dd"
     self.today = Calendar.current.date(byAdding:
    .day,
    value: +1,
    to: self.today)!
    self.todayDateString = df.string(from: self.today)
    self.todayLabel.text = self.todayDateString

        self.getActivityNDaysAgo(daysAgo: currentDaysBack)
        self.getWater()
        self.getSleep()
        self.getHeartRate()
        self.getEmotions(daysAgo: currentDaysBack)
        self.getTimeToTenKicks()
        
    }
    @IBAction func swipeRightSpecificDate() {
        // this means go back
        self.dayForwardButton.isHidden = false
        currentDaysBack += 1
                print("back")

        self.getActivityNDaysAgo(daysAgo: currentDaysBack)
         let df = DateFormatter()
     df.dateFormat = "yyyy-MM-dd"
     self.today = Calendar.current.date(byAdding:
    .day,
    value: -1,
    to: self.today)!
    self.todayDateString = df.string(from: self.today)
    self.todayLabel.text = self.todayDateString
        self.getActivityNDaysAgo(daysAgo: currentDaysBack)
        self.getWater()
        self.getSleep()
        self.getHeartRate()
        self.getEmotions(daysAgo: currentDaysBack)
        self.getTimeToTenKicks()
        
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
