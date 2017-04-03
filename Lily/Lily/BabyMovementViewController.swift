//
//  BabyMovementViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 3/1/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SafariServices
import Firebase
import SwiftyJSON
class BabyMovementViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    var kicksView: KicksSoFarView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var weeklyTimesView: WeeklyTimesView!
    let cellReuseIdentifier = "cell"
    @IBOutlet weak var advicePanelView: AdvicePanelView!
    @IBOutlet weak var dailyKickView: DailyKickView!
    let advice = "According to the American Congress of Obstetricians and Gynecologists, you should record how long it takes you to feel 10 flutters or kicks beginning at 28 weeks.  You should be 1 at least 10 within 2 hours. If you do not, try again in a few hours, and if you still don’t feel 10 movements within 2 hours, contact your healthcare provider."
    let source = "American Pregnancy Association"
    let sourceLink = "http://americanpregnancy.org/while-pregnant/kick-counts/"
    let adviceTitle = "HOW OFTEN SHOULD THE BABY MOVE?"
    
    var dayTimes = [String]()
    var dayNames = [String]()
    var kicks = 0
    var kickDic: [Int: (String, String)] = [:]

    var weeklyKicks = 0
    var weeklyKicksTime = 0
    var daysRecorded = 0
    var weeksAgo = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        dayNames = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday","Week Average"]
        dayTimes = ["1:35:49", "1:42:04","1:25:14", "1:12:55", "1:02:02", "1:05:25", "1:42:20", "1:24:05"]

        self.setAdvice(advice: self.advice)
        self.setAdviceLink(source: self.source)
        self.setAdviceTitle(title: self.adviceTitle)
        self.setAdviceURL(source: self.sourceLink)
        
        setUpDaysAndTimes()
        self.dailyKickView.setDayLabel(title: Helpers.getLongDate(date: Date()))
        self.dailyKickView.cancelButton.addTarget(self, action: #selector(self.cancelPressed), for: .touchUpInside)
        self.dailyKickView.kickButton.addTarget(self, action: #selector(self.kickPressed), for: .touchUpInside)
        self.advicePanelView.adviceLinkButton.addTarget(self, action: #selector(self.adviceTapped), for: .touchUpInside)
        self.weeklyTimesView.weeklyView.weeklyBarView.backButton.addTarget(self, action: #selector(self.goBackWeek), for: .touchUpInside)
        self.weeklyTimesView.weeklyView.weeklyBarView.forwardButton.addTarget(self, action: #selector(self.goForwardWeek), for: .touchUpInside)

        
        self.getKicksNWeeksAgo(weeksAgo: self.weeksAgo)
    }
    func adviceTapped() {
        let url = self.advicePanelView.adviceLinkSource
        let svc = SFSafariViewController(url: URL(string:url)!)
        present(svc, animated: true, completion: nil)
    }

    
    
    func goBackWeek() {
        self.weeksAgo += 1
        self.getKicksNWeeksAgo(weeksAgo: self.weeksAgo)
    }
    func goForwardWeek() {
        if self.weeksAgo == 0 {
            return
        }
        self.weeksAgo -= 1
        self.getKicksNWeeksAgo(weeksAgo: self.weeksAgo)

    }
    

    
    func loadCustomViewIntoController() {
        let screenSize: CGRect = UIScreen.main.bounds
        kicksView = KicksSoFarView(frame: CGRect(x: 0, y: 0, width: screenSize.width , height: screenSize.height))
        kicksView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(kicksView)
        if kicks == 1 {
            kicksView.setMainLabel(title: "\(kicks) kick so far!")
        } else {
            kicksView.setMainLabel(title: "\(kicks) kicks so far!")
        }
        kicksView.isHidden = false
                
    }
    
    func setDateRange(range: String) {
        self.weeklyTimesView.weeklyView.weeklyBarView.setDateRangeLabel(title: range)
    }
    func cancelPressed() {
        print("in vc")
        doneWithKicks()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.getTimeToTenKicks()

    }
    
    func appWillResign(notification: NSNotification) {
        self.getTimeToTenKicks()
    }
    
    func kickPressed() {
        kicks += 1
        let df = DateFormatter()
        df.dateFormat = "hh mm a"
        let stringDate = df.string(from: NSDate() as Date)
        
        kickDic[kicks] = ("Kick \(kicks)", stringDate)
        print(kickDic)
        DispatchQueue.main.async{
            self.tableview.reloadData()
        }
        
        self.loadCustomViewIntoController()
    }
    
    func doneWithKicks() {
        Helpers.postDailyLogToFirebaseUpdateValue(key: "kicksTotal", value: kicks)
        Helpers.postDailyLogToFirebaseUpdateValue(key: "kicksTotalTime", value: self.dailyKickView.getFinalSeconds())
    }
    

    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kicks
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let c = Bundle.main.loadNibNamed("KickCellView", owner: self, options: nil)?.first as! KickTableViewCell
        c.timeLabel.text = kickDic[indexPath.row+1]?.1
        c.kickLabel.text = kickDic[indexPath.row+1]?.0
        return c
    }
    
    func getTimeToTenKicks() {
        let user = FIRAuth.auth()?.currentUser
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        if let uid = user?.uid {
            ref.child("users").child(uid).child("logs/\(dateInFormat)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let json = JSON(snapshot.value!)
                print("JSON resp \(json)")
                let kicksTotal = json["kicksTotal"].intValue
                let kicksTotalTime = json["kicksTotalTime"].intValue
                var avg = 0.0
                if kicksTotalTime != 0 {
                    avg = Double(kicksTotal) / Double(kicksTotalTime)
                    avg *= 10
                }
                print("avg kicks \(avg)")
                Helpers.postDailyLogToFirebase  (key: "kicks10Average", value: Int(avg))

            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    func getKicksNWeeksAgo(weeksAgo: Int) {
        setDateRange(range: Helpers.getShortDateRangeString(date: Date()))
        self.weeklyKicksTime = 0
        self.weeklyKicks = 0
        self.daysRecorded = 0
        let past = Helpers.getDateNWeeksAgo(weeksAgo: weeksAgo)
        let date = past.date
        let labelRange = Helpers.getShortDateRangeString(date: date)
        setDateRange(range: labelRange)
        let days = Helpers.get7DayRange(weeksAgo: weeksAgo)
        var i = 0
        print("Days: \(days)")
        for v in self.weeklyTimesView.views {
            if i == 7 {
                v.setDayLabel(title: "Week Average")
            } else {
                v.setDayLabel(title: days[i].0)
                getWeeklyAverage(dayStr: days[i].1, index: i)
            }
            i += 1
        }
    }
    
    func getWeeklyAverage(dayStr: String, index: Int) {
        let user = FIRAuth.auth()?.currentUser
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        if let uid = user?.uid {
            ref.child("users").child(uid).child("logs/\(dayStr)").observeSingleEvent(of: .value, with: { (snapshot) in
                let json = JSON(snapshot.value!)
                let kickAvgSeconds = json["kicks10Average"].intValue
                print("Kicks avg seconds \(kickAvgSeconds)")
                self.weeklyKicks += json["kicksTotal"].intValue
                self.weeklyKicksTime += json["kicksTotalTime"].intValue
                self.daysRecorded += 1
                let avgStr = Helpers.timeString(time: kickAvgSeconds)
                print(avgStr)
                self.weeklyTimesView.views[index].setTimeLabel(time: self.dayTimes[index])
                // TODO uncomment
               // self.weeklyTimesView.views[index].setTimeLabel(time: avgStr)
                if self.daysRecorded == 7 {
                    var weeklyAvgTime = 0
                    if self.weeklyKicks != 0 {
                        weeklyAvgTime = (self.weeklyKicksTime / self.weeklyKicks) * 10
                    }
                    print(weeklyAvgTime)
                    // TODO uncomment
                   // self.weeklyTimesView.weeklyView.weeklyMiddleView.setMainStatLabel(text: String(self.weeklyKicks / 7))
                    self.weeklyTimesView.weeklyView.weeklyMiddleView.setMainStatLabel(text: "10")

                    //self.weeklyTimesView.weeklyView.weeklyMiddleView.setStatDetailLabel(text: "Kicks/day")
                    self.weeklyTimesView.views[7].setTimeLabel(time: self.dayTimes[index])
                    // TODO uncomment
                    //self.weeklyTimesView.views[7].setTimeLabel(time: Helpers.timeString(time: weeklyAvgTime))
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func setUpDaysAndTimes() {
        var i = 0
        for v in self.weeklyTimesView.views {
            v.setDayLabel(title: dayNames[i])
            v.setTimeLabel(time: dayTimes[i])
            i += 1
        }
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
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    @IBAction func adviceButtonLinkPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string:"http://americanpregnancy.org/while-pregnant/kick-counts/" )!)
        present(svc, animated: true, completion: nil)
        
    }
    
    

}
