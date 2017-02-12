//
//  HomeScreenViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 1/19/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import Speech
import SwiftyJSON
import Foundation
import UICircularProgressRing
import PKHUD
import SwiftSiriWaveformView
import SCLAlertView
import SendGrid

class HomeScreenViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var subviewHelp: UIView!

    
    @IBOutlet weak var waterButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    @IBOutlet weak var heartRateButton: UIButton!
    @IBOutlet weak var weightLogButton: UIButton!
    @IBOutlet weak var emotionLogButton: UIButton!
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var waterConsumedLabel: UILabel!
    @IBOutlet weak var waterGoalLabel: UILabel!
    @IBOutlet weak var activityMinutesLabel: UILabel!
    @IBOutlet weak var activityGoalLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var streakLabel: UIButton!
    @IBOutlet weak var timeSleptLabel: UILabel!
    @IBOutlet weak var helpSubviewImage: UIImageView!
    @IBOutlet weak var micHelpSmallImage: UIImageView!
    // Speech Vars
    @IBOutlet weak var tapToSpeakButton: UIButton!
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    @IBOutlet weak var tapToSpeakLabel: UILabel!
    
    // Siri Wave Vars
    var timer:Timer?
    var change:CGFloat = 0.01
    @IBOutlet weak var audioView: SwiftSiriWaveformView!
    // Fitbit Vars
    
    var fbreqs = FitbitRequests()
    var healthKitReqs = HealthKitRequests()
    
    @IBOutlet weak var activityRing: UICircularProgressRingView!

    var sleepObject = Sleep()
    
    
    
    
    let loginMethod = UserDefaults.standard.string(forKey: "loginMethod")
    
    internal func refreshAudioView(_:Timer) {
        if self.audioView.amplitude <= self.audioView.idleAmplitude || self.audioView.amplitude > 1.0 {
            self.change *= -1.0
        }
        
        // Simply set the amplitude to whatever you need and the view will update itself.
        self.audioView.amplitude += self.change
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
    
    @IBAction func questionMarkButtonPressed(_ sender: Any) {
        self.showDetailedHelp()
    }
    @IBAction func tapToSpeakMicButtonPressed(_ sender: Any) {
        micPressed()
    }
    
    func showSubview() {
        self.navigationController?.navigationBar.layer.zPosition = -1;
        self.subviewHelp.isHidden = false
        self.showDetailedHelp()
        
    }
    func hideSubview() {
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.subviewHelp.isHidden = true

    }
    

    func showDetailedHelp() {
        self.micHelpSmallImage.isHidden = true
        self.helpSubviewImage.isHidden = false

    }
    func showErrorMicHelp() {
        self.helpSubviewImage.isHidden = true
        self.micHelpSmallImage.isHidden = false
    }
    
    func disableMics() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tapToSpeakButton.isEnabled = false
    }
    func enableMics() {
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.tapToSpeakButton.isEnabled = true
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Lily"

        // Send a basic example
        Session.shared.authentication = Authentication.apiKey("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")
        self.hideSubview()
        self.loadMicrophoneAtLaunch()
    }
    
    func loadData() {
        loadWater()
        loadSleep()
        loadActivity()
        loadHeartRate()
        loadWeightLog()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear home")
        loadData()

    }

    func loadMicrophoneAtLaunch() {
        let micButton = UIButton.init(type: .custom)
        micButton.setImage(UIImage.init(named: "microphone.png"), for: UIControlState.normal)
        micButton.addTarget(self, action:#selector(HomeScreenViewController.micPressed), for: UIControlEvents.touchUpInside)
        micButton.frame = CGRect.init(x: 0, y: 0, width: 20, height: 30) //CGRectMake(0, 0, 30, 30)
        let rightBarButton = UIBarButtonItem.init(customView: micButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let exportButton = UIButton.init(type: .custom)
        exportButton.setImage(UIImage.init(named: "exportButtonIcon"), for: UIControlState.normal)
        exportButton.addTarget(self, action:#selector(HomeScreenViewController.exportPressed), for: UIControlEvents.touchUpInside)
        exportButton.frame = CGRect.init(x: 0, y: 0, width: 20, height: 30) //CGRectMake(0, 0, 30, 30)
        let leftBarButton = UIBarButtonItem.init(customView: exportButton)
        self.navigationItem.leftBarButtonItem = leftBarButton

        
        self.audioView.density = 1.0
        self.audioView.isHidden = true
        timer = Timer.scheduledTimer(timeInterval: 0.009, target: self, selector: #selector(HomeScreenViewController.refreshAudioView(_:)), userInfo: nil, repeats: true)
        
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
    
    
    
    func showExportAlert() {
        
    }
    
    
    func micPressed() {
        self.showSubview()
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.audioView.isHidden = true
            self.tapToSpeakLabel.text = "Tap to speak"
            self.tapToSpeakButton.setImage(UIImage(named: "MicWhite"), for: .normal)

            self.tapToSpeakButton.isEnabled = true

        } else {
            startRecording()
            self.tapToSpeakLabel.isHidden = false
            self.audioView.isHidden = false
            self.tapToSpeakButton.setImage(UIImage(named: "micWithOrangeBorder"), for: .normal)
            self.tapToSpeakLabel.text = "Tap to stop recording"
            self.tapToSpeakButton.isEnabled = true

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
                print(result?.bestTranscription.formattedString ?? "NIL")
                isFinal = (result?.isFinal)!
                print("FINAL: \(isFinal)    ")
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
        self.tapToSpeakLabel.isHidden = false
        self.tapToSpeakLabel.text = "Say something, I'm listening!"
        
    }

    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.enableMics()
        } else {
            self.disableMics()
        }
    }


    @IBOutlet weak var micCloseButton: UIButton!
    @IBAction func micCloseButtonPressed(_ sender: Any) {
        self.hideSubview()
    }
    
    @IBAction func waterButtonPressed(_ sender: Any) {
        debugPrint("Water Button Pressed")
        self.performSegue(withIdentifier: "waterSegue", sender: sender)

    }
    @IBAction func activityButtonPressed(_ sender: Any) {
        debugPrint("Activity Button Pressed")
        self.performSegue(withIdentifier: "activitySegue", sender: sender)
    }
    @IBAction func heartRateButtonPressed(_ sender: Any) {
        debugPrint("Heart Rate Button Pressed")
        self.performSegue(withIdentifier: "heartRateSegue", sender: sender)


    }
    @IBAction func weightLogButtonPressed(_ sender: Any) {
        debugPrint("Weight Button Pressed")

    }
    @IBAction func emotionLogButtonPressed(_ sender: Any) {
        debugPrint("Emotion Log Button Pressed")

    }
    @IBAction func sleepButtonPressed(_ sender: Any) {
        debugPrint("Sleep Button Pressed")
        self.performSegue(withIdentifier: "sleepSegue", sender: sender)

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWater() {
        if self.loginMethod == "HealthKit" {
            loadWaterHealthKit()
        } else if self.loginMethod == "Fitbit" {
            loadWaterFitbit()
        }
    }

    func loadWaterHealthKit() {
        self.healthKitReqs.getWaterConsumption() { result, error in
            let waterConsumedCups = result ?? "0"
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    self.waterConsumedLabel.text = waterConsumedCups ?? "0"
                    Helpers.postDailyLogToFirebase(key: "waterCupsConsumed", value : waterConsumedCups)
                    Helpers.postDailyLogToFirebase(key: "waterCupsGoal", value: 10.0)
                    self.waterGoalLabel.text = "of 10 cups"
                }
            }
        }
    }
    
    func loadWaterFitbit() {
        self.fbreqs.getWaterLogs() { water, error in
            let waterInCups = water?.cupsConsumed
            if waterInCups != nil {
                let cups = String(format: "%.0f", waterInCups ?? 0)
                self.waterConsumedLabel.text = "\(cups)"
                Helpers.postDailyLogToFirebase(key: "waterCupsConsumed", value: cups ?? 0)
            } else {
                self.waterConsumedLabel.text = "0"
                Helpers.postDailyLogToFirebase(key: "waterCupsConsumed", value: 0)
            }
            
        }
        
        self.fbreqs.getWaterGoal() { goal, error in
            if goal != nil {
                let cups = Double(goal!)
                self.waterGoalLabel.text = "of \(cups) cups"
                Helpers.postDailyLogToFirebase(key: "waterCupsGoal", value: cups ?? 0)

            } else {
                self.waterGoalLabel.text = "of 10 cups"
                Helpers.postDailyLogToFirebase(key: "waterCupsGoal", value: 10.0)
            }
        }
    }

    func loadActivity() {
        if self.loginMethod == "HealthKit" {
            loadActivityHealthKit()
        } else if self.loginMethod == "Fitbit" {
            loadActivityFitbit()
        }
        
    }
    func loadActivityHealthKit() {
        self.healthKitReqs.getActiveMinutes() { result, error in
            if error != nil {
                return
            }
            let goalActiveMinutes = "30"
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    Helpers.postDailyLogToFirebase(key: "activityMinutes", value: result ?? 0)
                    Helpers.postDailyLogToFirebase(key: "activityMinutesGoal", value: 30)
                    self.setActivityProgress(exerciseMinutes: result ?? "0", goalActiveMinutes: goalActiveMinutes)
                }
            }
        }
    
    }
    
    func setActivityProgress(exerciseMinutes: String, goalActiveMinutes: String) {
        self.activityGoalLabel.text = "of \(goalActiveMinutes) min"
        self.activityMinutesLabel.text = "\(exerciseMinutes)"
        self.activityRing.animationStyle = kCAMediaTimingFunctionLinear
        self.activityRing.fontSize = 25
        self.activityRing.maxValue = CGFloat(Int(goalActiveMinutes)!)
        self.activityRing.viewStyle = 2
        self.animateRing(value: Int(exerciseMinutes)!)
    }
    
    func loadActivityFitbit() {
        self.fbreqs.getDailyActivity() { activity, error in
            if error != nil {
                return
            }
            let goalActiveMinutes =  30
            let fairlyActiveMinutes = activity.fairlyActiveMinutes
            let veryActiveMinutes = activity.veryActiveMinutes
            let totalActiveMinutes = fairlyActiveMinutes + veryActiveMinutes
            Helpers.postDailyLogToFirebase(key: "activityMinutes", value: totalActiveMinutes)
            Helpers.postDailyLogToFirebase(key: "activityMinutesGoal", value: goalActiveMinutes)
            self.setActivityProgress(exerciseMinutes: "\(totalActiveMinutes)", goalActiveMinutes: "\(goalActiveMinutes)")
        }
    }
    
    
    func animateRing(value: Int) {
        self.activityRing.animationStyle = kCAMediaTimingFunctionLinear
        self.activityRing.setProgress(value: CGFloat(value), animationDuration: 2, completion: nil)
    }
    
    func loadHeartRate() {
        if self.loginMethod == "HealthKit" {
            loadHeartRateHealthKit()
        } else if self.loginMethod == "Fitbit" {
            loadHeartRateFitbit()
        }
    }
    
    func loadHeartRateFitbit() {
        self.fbreqs.getHeartRateTimeSeriesFrom1DayPeriod() {heartRate, error in
            let restingHeartRateToday = heartRate?.restingHeartRate
            if restingHeartRateToday != nil {
                self.heartRateLabel.text = "\(restingHeartRateToday!)"
                Helpers.postDailyLogToFirebase(key: "restingHeartRate", value: restingHeartRateToday!)
            } else {
                self.heartRateLabel.text = "00" // TODO get from yesterday from firebase
                Helpers.postDailyLogToFirebase(key: "restingHeartRate", value: 0)

            }
        }
    }
    
    func loadHeartRateHealthKit() {
        self.healthKitReqs.getHeartRate() { heartRate, error in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    if let hr = heartRate {
                        self.heartRateLabel.text = "\(hr)"
                        Helpers.postDailyLogToFirebase(key: "restingHeartRate", value: Int(hr)!)

                    } else {
                        self.heartRateLabel.text = "00" // TODO get from yesterday from firebase
                        Helpers.postDailyLogToFirebase(key: "restingHeartRate", value: 0)
                        
                    }
                }
            }
        }

    }

    
    func loadWeightLog() {
        loadWeightHealthKit()
    }
    
    func loadWeightHealthKit() {
        self.healthKitReqs.getWeight() { result, error in
            print(result ?? "0")
        }
    }
    func loadWeightFitbit() {

    }
    func loadEmotion() {}
    
    func loadSleep() {
        if self.loginMethod == "HealthKit" {
            loadSleepHealthKit()

        } else if self.loginMethod == "Fitbit" {
            loadSleepFitbit()
        }
    }
    func loadSleepHealthKit() {
        healthKitReqs.getSleepLogs() { result, error in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    if let sleep = result {
                        self.timeSleptLabel.text = sleep
                        Helpers.postDailyLogToFirebase(key: "sleepTime", value: sleep)
                    } else {
                        self.timeSleptLabel.text = "0h 0m"
                        Helpers.postDailyLogToFirebase(key: "sleepTime", value: "0h 0m")
                    }
                }
            }
            
        }
    }
    
    func loadSleepFitbit() {
        self.fbreqs.getSleepLogs() { sleep, error in
            self.sleepObject = sleep ?? Sleep()
            self.timeSleptLabel.text  = self.sleepObject.sleepLabel
        }
    }

    
    func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {
        if ring === self.activityRing {
        }
    }

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let backItem = UIBarButtonItem()
        backItem.title = "Home"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        if segue.identifier == "sleepSegue" {
            
            print("This is the Sleep Segue")
            
        } else if segue.identifier == "waterSegue" {
            
            print("This is the Water Segue")
            
        }
     }

}
