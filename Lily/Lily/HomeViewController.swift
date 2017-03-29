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
import Speech

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SFSpeechRecognizerDelegate {

    fileprivate let sectionInsets = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    // Siri Wave Vars
    var timer:Timer?
    var change:CGFloat = 0.01
//    @IBOutlet weak var audioView: SwiftSiriWaveformView!
    
    
    
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
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        Session.shared.authentication = Authentication.apiKey("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")
        self.loadMicrophoneAtLaunch()
    }
    func exportPressed() {
        // Add a text field
        let alert = SCLAlertView()
        let txt = alert.addTextField("your-email@gmail.com")
        alert.addButton("Send") {
            print("Text value: \(txt.text ?? nil)")
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
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = false
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if result != nil {
                isFinal = (result?.isFinal)!
                var query = result?.bestTranscription.formattedString
                query = query?.replacingOccurrences(of: "Cagle's", with: "kegels")
                query = query?.replacingOccurrences(of: "Cagle", with: "kegel")
                
                SweetAlert().showAlert("Is this OK?", subTitle: "\(query ?? "Oops. Something went wrong.")", style: AlertStyle.warning, buttonTitle:"Nope!", buttonColor:Helpers.UIColorFromRGB(rgbValue: 0xD0D0D0) , otherButtonTitle:  "YES!", otherButtonColor: Helpers.UIColorFromRGB(rgbValue: 0xDD6B55)) { (isOtherButton) -> Void in
                    if isOtherButton == true {
                        
                        // SweetAlert().showAlert("Cancelled!", subTitle: "Let's give this another try", style: AlertStyle.error) // left
                    }
                    else {
                        //SweetAlert().showAlert("Awesome!", subTitle: "Doing what you asked!", style: AlertStyle.success)
                    }
                }
                
                
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.enableMics()
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
//        self.tapToSpeakLabel.isHidden = false
//        self.tapToSpeakLabel.text = "Say something, I'm listening!"
        
    }
    
    func disableMics() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
//        self.tapToSpeakButton.isEnabled = false
    }
    func enableMics() {
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
//        self.tapToSpeakButton.isEnabled = true
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.enableMics()
        } else {
            self.disableMics()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - UICollectionViewDataSource
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
    
    func getTile(tile: String) -> UIView {
        // TODO fill in
        if tile == "water" {
            let waterTile = WaterTileView()
            waterTile.setCupsLabel(cups: "8")
            waterTile.setGoalsCupLabel(text: "of 10 cups")
            waterTile.setImage(name: "water")
            return waterTile
        } else if tile == "Calendar" {
            let whtdTile = WhatHappenedThatDay()
            whtdTile.setImage(name: "Calendar")
            whtdTile.setDowLabel(dow: "Tuesday")
            whtdTile.setNumberLabel(number: "28")
            return whtdTile
        } else if tile == "Moon" {
            let sleepTile = SleepTileView()
            sleepTile.setImage(name: "Moon")
            sleepTile.setTimeLabel(time: "6h 51m")
            return sleepTile
        } else if tile == "Activity" {
            let activityTile = ActivityTileView()
            activityTile.setTotalLabel(total: "30")
            activityTile.setProgressRing(value: 12.0, maxValue: 30.0)
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
//        
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            recognitionRequest?.endAudio()
//            self.navigationItem.rightBarButtonItem?.isEnabled = false
//            self.audioView.isHidden = true
//            self.tapToSpeakLabel.text = "Tap to speak"
//            self.tapToSpeakButton.setImage(UIImage(named: "MicWhite"), for: .normal)
//            
//            self.tapToSpeakButton.isEnabled = true
//            
//        } else {
//            startRecording()
//            self.tapToSpeakLabel.isHidden = false
//            self.audioView.isHidden = false
//            self.tapToSpeakButton.setImage(UIImage(named: "micWithOrangeBorder"), for: .normal)
//            self.tapToSpeakLabel.text = "Tap to stop recording"
//            self.tapToSpeakButton.isEnabled = true
//            
//        }
        
    }
    
    internal func refreshAudioView(_:Timer) {
//        if self.audioView.amplitude <= self.audioView.idleAmplitude || self.audioView.amplitude > 1.0 {
//            self.change *= -1.0
//        }
//        
//        // Simply set the amplitude to whatever you need and the view will update itself.
//        self.audioView.amplitude += self.change
    }
    
    func loadMicrophoneAtLaunch() {

        ///
        let micButton = UIButton.init(type: .custom)
        micButton.setImage(UIImage.init(named: "microphone.png"), for: UIControlState.normal)
        micButton.addTarget(self, action:#selector(self.micPressed), for: UIControlEvents.touchUpInside)
        micButton.frame = CGRect.init(x: 0, y: 0, width: 20, height: 30) //CGRectMake(0, 0, 30, 30)
        let rightBarButton = UIBarButtonItem.init(customView: micButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let exportButton = UIButton.init(type: .custom)
        exportButton.setImage(UIImage.init(named: "exportButtonIcon"), for: UIControlState.normal)
        exportButton.addTarget(self, action:#selector(self.exportPressed), for: UIControlEvents.touchUpInside)
        exportButton.frame = CGRect.init(x: 0, y: 0, width: 20, height: 30) //CGRectMake(0, 0, 30, 30)
        let leftBarButton = UIBarButtonItem.init(customView: exportButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        

        timer = Timer.scheduledTimer(timeInterval: 0.009, target: self, selector: #selector(refreshAudioView(_:)), userInfo: nil, repeats: true)
        
        self.disableMics()
        
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                //                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                //                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                //                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                if isButtonEnabled {
                    self.enableMics()
                } else {
                    self.disableMics()
                }
            }
        }
    }

    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item: \(indexPath.row)")
        print(self.images[indexPath.row])
        // ["Activity", "Moon", "balance", "Checklist", "Heart" ,"Baby", "journal", "CallDoctor", "Star", "Store", "water", "Calendar"]
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
        // move your data order
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
