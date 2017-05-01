//
//  HomeViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 2/23/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SCLAlertView
import SendGrid
import UserNotifications
import SwiftyJSON

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var voiceView: VoiceView!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 50.0, right: 20.0)
    var fbreqs = FitbitRequests()
    var refreshControl:UIRefreshControl!

    var waterConsumed: Double?
    var activityMinutes: Int?
    var heartRate: Int?
    var sleep: String?
    
    var pdfGenerator: PDFGenerator!
    var HTMLContent: String!
    
    @IBOutlet weak var TileCollectionView: UICollectionView!

    var images = ["water", "Activity", "Heart" ,  "balance", "Moon", "Checklist", "Calendar", "Baby", "journal", "CallDoctor", "Star"]
    
    
    let titles: [String: String] = ["Activity":"Activity", "balance":"Weight Log", "Checklist": "Emotion Log", "Baby":"Baby Movement Log", "Heart":"Heart Rate", "journal": "My Journal", "CallDoctor": "Call the Doctor", "Star": "My Goals", "water": "Water Consumption", "Calendar":"What happened that day?", "Moon":"Sleep"]
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.TileCollectionView.delegate = self
        self.TileCollectionView.dataSource = self
        self.navigationController?.navigationBar.stop()

        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        self.TileCollectionView.addGestureRecognizer(longPressGesture)
        self.automaticallyAdjustsScrollViewInsets = false
        self.loadNavBar()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        Session.shared.authentication = Authentication.apiKey("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")
        let screenSize: CGRect = UIScreen.main.bounds
        voiceView = VoiceView(frame: CGRect(x: 0, y: 0, width: screenSize.width , height: screenSize.height))
        voiceView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        voiceView.xButton.addTarget(self, action:#selector(self.xPressed), for: UIControlEvents.touchUpInside)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.TileCollectionView.addSubview(refreshControl)
    }
    
    func refresh() {
        print("refreshing")
        waterConsumed = nil
        activityMinutes = nil
        heartRate = nil
        sleep = nil
        self.TileCollectionView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO in case you come back to this screen and reload a lot
        refresh()
    }

    
    

    func loadNavBar() {
        ///
        let micButton = UIButton.init(type: .custom)
        micButton.setImage(UIImage.init(named: "microphone.png"), for: UIControlState.normal)
        micButton.addTarget(self, action:#selector(self.micPressed), for: UIControlEvents.touchUpInside)
        micButton.frame = CGRect.init(x: 0, y: 0, width: 20, height: 30)
        let rightBarButton = UIBarButtonItem.init(customView: micButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let exportButton = UIButton.init(type: .custom)
        exportButton.setImage(UIImage.init(named: "exportButtonIcon"), for: UIControlState.normal)
        exportButton.addTarget(self, action:#selector(self.exportPressed), for: UIControlEvents.touchUpInside)
        exportButton.frame = CGRect.init(x: 0, y: 0, width: 20, height: 30)
        let leftBarButton = UIBarButtonItem.init(customView: exportButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
    }
    
    func logout() {
        // Delete User credential from NSUserDefaults and other data related to user
        let restClient = RestClient()
        restClient.forgetTokens(nil)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        let appDelegateTemp: AppDelegate? = (UIApplication.shared.delegate as! AppDelegate)
        let rootController: UIViewController? = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as! ViewController
        let navigation = UINavigationController(rootViewController: rootController!)
        appDelegateTemp?.window?.rootViewController = navigation
        

    }
    
    
    
    func exportPressed() {
        // Add a text field
        let alert = SCLAlertView()
        let txt = alert.addTextField("your-email@email.com")
        alert.addButton("Send") {
            print("Text value: \(String(describing: txt.text))")
            print("Email from box")
            if let email = txt.text {
                self.collectDataAndSendEmail(email: txt.text!)

            } else {
                return
            }
        }
        let alertViewIcon = UIImage(named: "sendIcon") //Replace the IconImage text with the image name
        alert.showEdit("Export Health Data", subTitle: "Please provide an email", circleIconImage: alertViewIcon)
        

    }
    
    var myGroup = DispatchGroup()
    func collectDataAndSendEmail(email: String) {
        
        // generate the pdf
        let symptomsSubsections: [String] = []
        //            ["vomiting","cramping", "swelling","head_pain","vaginal_and_urinary"]
        let medicationsSubsections: [String] = []
        //            ["personal_medications", "vitamins"]
        let dietSubsections: [String] = ["water"]
        //            ["diet_composition", "water"]
        let bodySubsections: [String] = ["heart_rate", "physical_activity", "sleep"]
        let mindSubsections: [String] = ["mind_summary", "edinburgh_postpartum_depression"]
        let weeksAgo: Int = 0
        
        self.pdfGenerator = PDFGenerator()
        
        // Get data to pass in
        var weeklyLog: JSON = [:]
        let dateRange = Helpers.get7DayRangeInts(weeksAgo: weeksAgo)
        
        for i in  dateRange.0..<dateRange.1 + 1 {
            self.myGroup.enter()
            
            Helpers.loadDailyLogFromFirebase(key: "", daysAgo: i) { json, error in
                self.myGroup.leave()
                if json != JSON.null {
                    weeklyLog[String(i)] = json
                } else {
                    let j:JSON = [:]
                    weeklyLog[String(i)] = j
                }
                
            }
        }
        self.myGroup.notify(queue: DispatchQueue.main, execute: {
            print("Finished all requests.")
            print(weeklyLog)
            self.pdfGenerator.weeklyLog = weeklyLog;
            self.HTMLContent = self.pdfGenerator.renderExportableSummary(symptoms: symptomsSubsections, meds: medicationsSubsections, diet: dietSubsections, body: bodySubsections, mind: mindSubsections)
            self.pdfGenerator.exportHTMLContentToPDF(HTMLContent: self.HTMLContent)
            self.sendEmail(email: email)
        })
    
    }
    
    func sendEmail(email: String) {
        let personalization = Personalization(recipients: email)
        let plainText = Content(contentType: ContentType.plainText, value: "Here is your Lily Health Data")
        let htmlText = Content(contentType: ContentType.htmlText, value: "<h1>Thanks for using Lily!</h1>")
        let email = Email(
            personalizations: [personalization],
            from: Address("Lily@lilyhealth.me"),
            content: [plainText, htmlText],
            subject: "Lily Health Data"
        )
        let temp = NSData(contentsOfFile: self.pdfGenerator.pdfFilename)!
        let attachment = Attachment(
            filename: "LilyHealthSummary.pdf",
            content: temp as Data,
            disposition: .attachment,
            type: .pdf,
            contentID: nil
        )
        
        email.attachments = [attachment]
        
        do {
            try Session.shared.send(request: email)
        } catch {
            print(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TileCell", for: indexPath) as! TileCollectionViewCell
        let tile = images[indexPath.row]
        
        let tileView = self.getTile(tile: tile)
        cell.setView(v: tileView)
        tileView.bindFrameToSuperviewBounds()
        
        return cell
    }
    
    func loadSleepNDaysAgo(daysAgo: Int, completionHandler: @escaping (Sleep?, Error?) -> ()) {
        let past = Helpers.getDateNDaysAgo(daysAgo: daysAgo)
        let dateString = past.dateString
        self.fbreqs.getSleepLogs(date: dateString) { sleep, error in
//            Helpers.postDailyLogToFirebase(key: "sleep", value: sleep?.sleepLabel)
            completionHandler(sleep ?? Sleep(), nil)
            
            
        }
    }
    
    
    func loadHeartRateNDaysAgo(daysAgo: Int,  completionHandler: @escaping (HeartRate?, Error?) -> ()) {
        let date = Helpers.getDateNDaysAgo(daysAgo: 0).dateString
        self.fbreqs.getHeartRateTimeSeriesFrom1DayPeriod(date: date, period: "1d") { heartRate, err in
            completionHandler(heartRate ?? HeartRate(), nil)


        }
    }
    
    // Load and save to Firebase
    func loadWaterNDaysAgo(daysAgo: Int, completionHandler: @escaping (Water?, Error?) -> ()) {
        let past = Helpers.getDateNDaysAgo(daysAgo: daysAgo)
        let dateString = past.dateString
        self.fbreqs.getWaterLogs(date: dateString) { water, error in
            if let water = water {
                // post to firebase
                Helpers.postDailyLogToFirebase(key: "water", value: water.cupsConsumed)
                completionHandler(water , nil)
            }
        }
    }
    

    func getTile(tile: String) -> UIView {
        // TODO fill in
        if tile == "water" {
            let waterTile = WaterTileView()
            if self.waterConsumed == nil {
                self.loadWaterNDaysAgo(daysAgo: 0) { water, err in
                    let waterConsumed = water?.cupsConsumed ?? 0
                    self.waterConsumed = waterConsumed
                    waterTile.setCupsLabel(cups: "\(Int(self.waterConsumed!))")
                    
                }
            } else {
                waterTile.setCupsLabel(cups: "\(Int(self.waterConsumed!))")

            }

            waterTile.setGoalsCupLabel(text: "of 10 cups")
            waterTile.setImage(name: "water")
            return waterTile
        } else if tile == "Calendar" {
            let whtdTile = WhatHappenedThatDay()
            whtdTile.setImage(name: "Calendar")
            whtdTile.setDowLabel(dow: Helpers.getDayOfWeek(date: Date())!)
            whtdTile.setNumberLabel(number: "\(Helpers.getDateComponent(date: Date()).day)")
            return whtdTile
        } else if tile == "Moon" {
            let sleepTile = SleepTileView()
            sleepTile.setImage(name: "Moon")
            if self.sleep == nil {
                self.loadSleepNDaysAgo(daysAgo: 0) { sleep, err in
                    self.sleep = sleep?.sleepLabel
                    sleepTile.setTimeLabel(time: self.sleep!)
                }
            } else {
                sleepTile.setTimeLabel(time: (self.sleep)!)

            }
            return sleepTile
        } else if tile == "Activity" {
            let activityTile = ActivityTileView()
            activityTile.setTotalLabel(total: "30")
            let d = Helpers.getDateNDaysAgo(daysAgo: 0).dateString
            if self.activityMinutes == nil {
                self.fbreqs.getDailyActivity(date: d) { activity, err in
                    self.activityMinutes = activity.veryActiveMinutes + activity.fairlyActiveMinutes
                    // TODO log to firebase
                    activityTile.setProgressRing(value: Double(self.activityMinutes!), maxValue: 30.0)
                }
            } else {
                print("is using cached value instead")
                activityTile.setProgressRing(value: Double(self.activityMinutes!), maxValue: 30.0)
            }

            activityTile.setMainLabel(title: "Activity")
            return activityTile
        } else {
            let tileView = TileView()
            tileView.image.image = UIImage(named: tile)
            tileView.mainLabel.text = titles[tile]
            tileView.bottomLabel.text = ""
            // TODO
            if title == "Baby" {
                tileView.bottomLabel.text = "10 times today!"

            }
            tileView.middleLabel.isHidden = true
            if tile == "Heart" {
                // TODO
                if self.heartRate == nil {
                    self.loadHeartRateNDaysAgo(daysAgo: 0) { heartRate, err in
                        self.heartRate = heartRate?.averageBPM
                        tileView.middleLabel.isHidden = false
                        if let hr = self.heartRate {
                            tileView.middleLabel.text = "\(String(describing: hr))"
                        }
                    }
                } else {
                    tileView.middleLabel.isHidden = false
                    if let hr = self.heartRate {
                        tileView.middleLabel.text = "\(String(describing: hr))"
                    }
                }

            }
            return tileView
        }
    }
    
    func micPressed() {

        self.navigationController?.navigationBar.layer.zPosition = -1
        self.view.addSubview(self.voiceView)
        self.voiceView.isHidden = false
        self.voiceView.micButtonPressed(self.voiceView.micButton)
    }
    
    func xPressed() {
        self.navigationController?.navigationBar.layer.zPosition = 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item: \(indexPath.row)")
        print(self.images[indexPath.row])
        switch self.images[indexPath.row] {
        case "Activity":
            self.performSegue(withIdentifier: "activitySegue", sender: nil)
        case "Moon":
            self.performSegue(withIdentifier: "sleepSegue", sender: nil)
        case "Checklist":
            self.performSegue(withIdentifier: "emotionsSegue", sender: nil)
        case "Heart":
            self.performSegue(withIdentifier: "heartRateSegue", sender: nil)
        case "Baby":
            self.performSegue(withIdentifier: "babyMovementSegue", sender: nil)
        case "journal":
            self.performSegue(withIdentifier: "journalSegue", sender: nil)
        case "CallDoctor":
            if let url = URL(string: "tel:7247669463") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case "Star":
            self.performSegue(withIdentifier: "goalsSegue", sender: nil)
        case "Store":
            self.performSegue(withIdentifier: "storeSegue", sender: nil)
        case "Calendar":
            self.performSegue(withIdentifier: "thisDaySegue", sender: nil)
        case "water":
            self.performSegue(withIdentifier: "waterSegue", sender: nil)
        case "balance":
            self.performSegue(withIdentifier: "weightSegue", sender: nil)
        default:
            return
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let backItem = UIBarButtonItem()
        backItem.title = "Home"
        navigationItem.backBarButtonItem = backItem
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        swap(&self.images[sourceIndexPath.row], &self.images[destinationIndexPath.row])
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (2 + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / 2
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.TileCollectionView.indexPathForItem(at: gesture.location(in: self.TileCollectionView)) else {
                break
            }
            TileCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            TileCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            TileCollectionView.endInteractiveMovement()
        default:
            TileCollectionView.cancelInteractiveMovement()
        }
    }
}
extension UIView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
}
