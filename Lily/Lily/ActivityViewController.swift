//
//  ActivityViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 2/9/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SafariServices
import Dropper

class ActivityViewController: UIViewController {

    
    @IBOutlet weak var day01View: UIView!    
    @IBOutlet weak var day02View: UIView!
    @IBOutlet weak var day03View: UIView!
    @IBOutlet weak var day04View: UIView!
    @IBOutlet weak var day05View: UIView!
    @IBOutlet weak var day06View: UIView!
    @IBOutlet weak var day07View: UIView!
    @IBOutlet weak var weekTotalView: UIView!
    
    @IBOutlet weak var dayOfWeek01Label: UILabel!
    @IBOutlet weak var dayOfWeek02Label: UILabel!
    @IBOutlet weak var dayOfWeek03Label: UILabel!
    @IBOutlet weak var dayOfWeek04Label: UILabel!
    @IBOutlet weak var dayOfWeek05Label: UILabel!
    @IBOutlet weak var dayOfWeek06Label: UILabel!
    @IBOutlet weak var dayOfWeek07Label: UILabel!
    
    @IBOutlet weak var day01TimeLabel: UILabel!
    @IBOutlet weak var day02TimeLabel: UILabel!
    @IBOutlet weak var day03TimeLabel: UILabel!
    @IBOutlet weak var day04TimeLabel: UILabel!
    @IBOutlet weak var day05TimeLabel: UILabel!
    @IBOutlet weak var day06TimeLabel: UILabel!
    @IBOutlet weak var day07TimeLabel: UILabel!
    @IBOutlet weak var weekTotalTimeLabel: UILabel!

    @IBOutlet weak var weekRangeLabel: UILabel!
    
    @IBOutlet weak var weekForwardButton: UIButton!
    @IBOutlet weak var weekBackButton: UIButton!
    @IBOutlet weak var selectActivityTypeButton: UIButton!
    
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var dayBackButton: UIButton!
    @IBOutlet weak var dayForwardButton: UIButton!
    @IBOutlet weak var dayLongDateLabel: UILabel!
    @IBOutlet weak var sedentaryView: UIView!
    @IBOutlet weak var lightlyActiveView: UIView!
    @IBOutlet weak var fairlyActiveView: UIView!
    @IBOutlet weak var veryActiveView: UIView!
    
    @IBOutlet weak var sedentaryTimeLabel: UILabel!
    @IBOutlet weak var lightlyActiveTimeLabel: UILabel!
    @IBOutlet weak var fairlyActiveTimeLabel: UILabel!
    @IBOutlet weak var veryActiveTimeLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var specificDayView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var weeklyActivityImage: UIImageView!
    var dayViews = [UIView]()
    var pastWeekActivityTimeLabels = [UILabel]()
    var pastWeekDaysOfWeekLabels = [UILabel]()
    let fbreqs = FitbitRequests()
    var currentWeeksBack = 0
    var currentDaysBack = 0
    var currentActivityType = "minutesVeryActive"
    let alertController = UIAlertController(title: nil, message: "Choose your activity level", preferredStyle: .actionSheet)


    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dayViews = [self.day01View, self.day02View, self.day03View, self.day04View,self.day05View,self.day06View, self.day07View, self.weekTotalView]
        
        for v in self.dayViews {
            v.layer.borderWidth = 0.5
            v.layer.cornerRadius = 5
            v.layer.masksToBounds = true
            v.layer.borderColor = UIColor.black.cgColor
        }
        
        self.pastWeekDaysOfWeekLabels   = [self.dayOfWeek01Label,self.dayOfWeek02Label,self.dayOfWeek03Label,self.dayOfWeek04Label,self.dayOfWeek05Label,self.dayOfWeek06Label,self.dayOfWeek07Label]
        self.pastWeekActivityTimeLabels = [self.day01TimeLabel,self.day02TimeLabel,self.day03TimeLabel,self.day04TimeLabel,self.day05TimeLabel,self.day06TimeLabel,self.day07TimeLabel]
        // Do any additional setup after loading the view.
        self.makeViewSwipeable()
        self.weekRangeLabel.text = Helpers.getShortDateRangeString(date: Date())

        self.getActivityNDaysAgo(daysAgo: 0)
        self.getActivityNWeeksAgo(weeksAgo: 0, acitivityType: currentActivityType)
        
        let oneAction = UIAlertAction(title: "Sedentary", style: .default) { _ in
            print("Sedentary")
            self.selectActivityTypeButton.setTitle("Sedentary", for: .normal)

            self.weeklyActivityImage.image = UIImage(named: "sedentary")
            self.getActivityNWeeksAgo(weeksAgo: self.currentWeeksBack, acitivityType: "minutesSedentary")

        }
        let twoAction = UIAlertAction(title: "Lightly Active", style: .default) { _ in
            print("Lightly Active")
            self.selectActivityTypeButton.setTitle("Lightly Active", for: .normal)

            self.weeklyActivityImage.image = UIImage(named: "lightly")
            self.getActivityNWeeksAgo(weeksAgo: self.currentWeeksBack, acitivityType: "minutesLightlyActive")

        }
        let threeAction = UIAlertAction(title: "Fairly Active", style: .default) { _ in
            print("Fairly Active")
            self.selectActivityTypeButton.setTitle("Fairly Active", for: .normal)

            self.weeklyActivityImage.image = UIImage(named: "fairly")
            self.getActivityNWeeksAgo(weeksAgo: self.currentWeeksBack, acitivityType: "minutesFairlyActive")

        }
        let fourAction = UIAlertAction(title: "Very Active", style: .default) { _ in
            print("Very Active")
            self.selectActivityTypeButton.setTitle("Very Active", for: .normal)
            self.weeklyActivityImage.image = UIImage(named: "very")
            self.getActivityNWeeksAgo(weeksAgo: self.currentWeeksBack, acitivityType: "minutesVeryActive")

        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        
        alertController.addAction(oneAction)
        alertController.addAction(twoAction)
        alertController.addAction(threeAction)
        alertController.addAction(fourAction)
        alertController.addAction(cancelAction)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func adviceButtonLinkPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string:"http://americanpregnancy.org/pregnancy-health/exercise-during-pregnancy/" )!)
        present(svc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func activityTypeDropdownButtonPressed(_ sender: Any) {
        self.present(self.alertController, animated: true)
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
        self.weekForwardButton.addTarget(self, action: #selector(self.swipeLeftWeek), for: .touchUpInside)
        self.weekBackButton.addTarget(self, action: #selector(self.swipeRightWeek), for: .touchUpInside)
        self.dayForwardButton.addTarget(self, action: #selector(self.swipeLeftSpecificDate), for: .touchUpInside)
        self.dayBackButton.addTarget(self, action: #selector(self.swipeRightSpecificDate), for: .touchUpInside)
        self.dayForwardButton.isHidden = true
        self.weekForwardButton.isHidden = true
    }
    
    
    
    func swipeLeftSpecificDate() {
        print("go forward day")
        if currentDaysBack == 0 {
            return
        }
        
        currentDaysBack -= 1
        print(currentDaysBack)
        
        if currentDaysBack == 0 {
            self.dayForwardButton.isHidden = true
            self.todayLabel.text = "Today"
        }
        self.getActivityNDaysAgo(daysAgo: currentDaysBack)
        
    }
    
    func getActivityNDaysAgo(daysAgo: Int) {
        let date = Helpers.getDateNDaysAgo(daysAgo: daysAgo).dateString
        self.fbreqs.getDailyActivity(date: date) { activity, err in
            self.dayLongDateLabel.text = activity.longDate
            self.setLabelWithTime(label: self.sedentaryTimeLabel, minutes: activity.sedentaryMinutes)
            self.setLabelWithTime(label: self.lightlyActiveTimeLabel, minutes: activity.lightlyActiveMinutes)
            self.setLabelWithTime(label: self.fairlyActiveTimeLabel, minutes: activity.fairlyActiveMinutes)
            self.setLabelWithTime(label: self.veryActiveTimeLabel, minutes: activity.veryActiveMinutes)
            self.todayLabel.text = activity.dayOfWeek
        }

    }
    
    func setLabelWithTime(label: UILabel, minutes: Int) {
        let formattedTime = Helpers.minutesToHoursMinutes(minutes: Int(minutes) )
        label.text = "\(formattedTime.0)h \(formattedTime.1)m"
        label.sizeToFit()
        
    }
    
    
    func getActivityNWeeksAgo(weeksAgo: Int, acitivityType: String) { // activityType is
        let endDate = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo).dateString
        let past = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo)
        let date = past.date
        let labelRange = Helpers.getShortDateRangeString(date: date)
        self.weekRangeLabel.text = labelRange
        var weeklyTotalMinutes = 0

        self.fbreqs.getActivityTimeSeriesFromPeriod(resourcePath: "\(acitivityType)", date: endDate, period: "7d") { activities, err in
            var i = 0
            for activity in activities {
                var time = "0"
                switch acitivityType {
                case "minutesSedentary":
                    time = "\(activity.sedentaryMinutes)"
                case "minutesLightlyActive":
                    time =  "\(activity.lightlyActiveMinutes)"
                case "minutesFairlyActive":
                    time =  "\(activity.fairlyActiveMinutes)"
                case "minutesVeryActive":
                    time =  "\(activity.veryActiveMinutes)"
                default:
                    debugPrint("error in switch statement")
                }
                let minutes = Int(time) ?? 0
                weeklyTotalMinutes += minutes
                let formattedTime = Helpers.minutesToHoursMinutes(minutes: minutes)
                
                self.pastWeekActivityTimeLabels[i].text = "\(formattedTime.0)h \(formattedTime.1)m"
                self.pastWeekDaysOfWeekLabels[i].text = "\(activity.dayOfWeek)"
                self.pastWeekDaysOfWeekLabels[i].adjustsFontSizeToFitWidth = true
                i += 1
                

            }
            let formattedTime = Helpers.minutesToHoursMinutes(minutes: weeklyTotalMinutes)
            self.weekTotalTimeLabel.text = "\(formattedTime.0)h \(formattedTime.1)m"
        
        }

        
    }
    
    
    
    func swipeRightSpecificDate() {
        // this means go back
        print("go back day")
        self.dayForwardButton.isHidden = false
        currentDaysBack += 1
        print(currentDaysBack)
        self.getActivityNDaysAgo(daysAgo: currentDaysBack)
        
    }
    
    func swipeLeftWeek() {
        print("go forward week")
        if currentWeeksBack == 0 {
            return
        }
        currentWeeksBack -= 1
        print(currentWeeksBack)
        if currentWeeksBack == 0 {
            self.weekForwardButton.isHidden = true
        }
        self.getActivityNWeeksAgo(weeksAgo: currentWeeksBack, acitivityType: currentActivityType)

    }
    
    func swipeRightWeek() {
        // this means go back
        print("go back week")
        print(currentWeeksBack)
        self.weekForwardButton.isHidden = false
        currentWeeksBack += 1
        self.getActivityNWeeksAgo(weeksAgo: currentWeeksBack, acitivityType: currentActivityType)
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

