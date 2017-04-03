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

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var voiceView: VoiceView!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 50.0, right: 20.0)
    var fbreqs = FitbitRequests()
    var refreshControl:UIRefreshControl!

    
    
    @IBOutlet weak var TileCollectionView: UICollectionView!

    var images = ["water", "Activity", "Heart" ,  "balance", "Moon", "Checklist", "Calendar", "Baby", "journal", "CallDoctor", "Star", "Store"]
    
    
    let titles: [String: String] = ["Activity":"Activity", "balance":"Weight Log", "Checklist": "Emotion Log", "Baby":"Baby Movement Log", "Heart":"Heart Rate", "journal": "My Journal", "CallDoctor": "Call the Doctor", "Star": "My Goals", "Store": "Tile Store", "water": "Water Consumption", "Calendar":"What happened that day?", "Moon":"Sleep"]
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
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.TileCollectionView.addSubview(refreshControl)
    }
    
    func refresh() {
        
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
    
    
    func exportPressed() {
        // Add a text field
        let alert = SCLAlertView()
        let txt = alert.addTextField("your-email@gmail.com")
        alert.addButton("Send") {
            print("Text value: \(String(describing: txt.text))")
            print("Email from box")
            self.sendEmail(email: "treinhart4115@gmail.com")
        }
        let alertViewIcon = UIImage(named: "sendIcon") //Replace the IconImage text with the image name
        alert.showEdit("Export Health Data", subTitle: "Please provide an email", circleIconImage: alertViewIcon)
    }
    
    func sendEmail(email: String) {
        let personalization = Personalization(recipients: "treinhart4115@gmail.com")
        let plainText = Content(contentType: ContentType.plainText, value: "Here is your Lily Health Data")
        let htmlText = Content(contentType: ContentType.htmlText, value: "<h1>Thanks for using Lily!</h1>")
        let email = Email(
            personalizations: [personalization],
            from: Address("Lily@lilyhealth.me"),
            content: [plainText, htmlText],
            subject: "Lily Health Data"
        )
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
            completionHandler(sleep ?? Sleep(), nil)
            
            
        }
    }
    func loadWaterNDaysAgo(daysAgo: Int, completionHandler: @escaping (Water?, Error?) -> ()) {
        let past = Helpers.getDateNDaysAgo(daysAgo: daysAgo)
        let dateString = past.dateString
        self.fbreqs.getWaterLogs(date: dateString) { water, error in
            if let water = water {
                completionHandler(water , nil)
            }
        }
    }
    
    
    func getTile(tile: String) -> UIView {
        // TODO fill in
        if tile == "water" {
            let waterTile = WaterTileView()
            self.loadWaterNDaysAgo(daysAgo: 0) { water, err in
                let waterConsumed = water?.cupsConsumed ?? 0
                waterTile.setCupsLabel(cups: "\(Int(waterConsumed))")

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
            self.loadSleepNDaysAgo(daysAgo: 0) { sleep, err in
                sleepTile.setTimeLabel(time: (sleep?.sleepLabel)!)

            }
            return sleepTile
        } else if tile == "Activity" {
            let activityTile = ActivityTileView()
            activityTile.setTotalLabel(total: "30")
            let d = Helpers.getDateNDaysAgo(daysAgo: 0).dateString
            self.fbreqs.getDailyActivity(date: d) { activity, err in
                activityTile.setProgressRing(value: Double(activity.veryActiveMinutes + activity.fairlyActiveMinutes), maxValue: 30.0)
            }
            activityTile.setMainLabel(title: "Activity")
            return activityTile
        } else {
            let tileView = TileView()
            tileView.image.image = UIImage(named: tile)
            tileView.mainLabel.text = titles[tile]
            tileView.bottomLabel.text = ""
            if title == "Baby" {
                tileView.bottomLabel.text = "10 times today!"

            }
            tileView.middleLabel.isHidden = true
            if tile == "Heart" {
                tileView.middleLabel.isHidden = false
                tileView.middleLabel.text = "54"
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
