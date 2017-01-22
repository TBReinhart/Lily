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

class HomeScreenViewController: UIViewController, SFSpeechRecognizerDelegate {


    
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
    // Speech Vars
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    let fbreqs = FitbitRequests()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lily"

        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "microphone.png"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(HomeScreenViewController.micPressed), for: UIControlEvents.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 20, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.navigationItem.rightBarButtonItem?.isEnabled = isButtonEnabled
            }
        }
        debugPrint("\n\n\n\n")
        loadWater()
        loadSleep()
        loadActivity()
        loadHeartRate()
        transparentPopupView()

    }

    func micPressed() {
        debugPrint("mic pressed")
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            debugPrint("Start Recording")
//            microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            print("Starting recording")
            startRecording()
            debugPrint("Stop Recording")
            //microphoneButton.setTitle("Stop Recording", for: .normal)
        }

    }
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        guard let inputNode = audioEngine.inputNode else {
            print("error")
            fatalError("Audio engine has no input node")
        }  //4
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                //self.textView.text = result?.bestTranscription.formattedString  //9
                debugPrint(result?.bestTranscription.formattedString ?? "nil")
                isFinal = (result?.isFinal)!
                
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.navigationItem.rightBarButtonItem?.isEnabled = true

               // self.microphoneButton.isEnabled = true
            }
        })
        print("7")
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        debugPrint("Say Something, I'm listening!")
        //self.textView.text = "Say something, I'm listening!"
        
        
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            //microphoneButton.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true

        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
//            microphoneButton.isEnabled = false
        }
    }

    
    
    @IBAction func waterButtonPressed(_ sender: Any) {
        debugPrint("Water Button Pressed")
    }
    @IBAction func activityButtonPressed(_ sender: Any) {
        debugPrint("Activity Button Pressed")

    }
    @IBAction func heartRateButtonPressed(_ sender: Any) {
        debugPrint("Heart Rate Button Pressed")

    }
    @IBAction func weightLogButtonPressed(_ sender: Any) {
        debugPrint("Weight Button Pressed")

    }
    @IBAction func emotionLogButtonPressed(_ sender: Any) {
        debugPrint("Emotion Log Button Pressed")

    }
    @IBAction func sleepButtonPressed(_ sender: Any) {
        debugPrint("Sleep Button Pressed")

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWater() {
        
        self.fbreqs.getWaterLogs() { json, error in
            let waterInMilli = json?["summary"]["water"].int
            let ounces = Int(round(Helpers.millilitersToOz(milli: waterInMilli!)))
            self.waterConsumedLabel.text = "\(String(ounces))"
        }
        
        self.fbreqs.getWaterGoal() { json, error in
            let goalInMilli = json?["goal"]["goal"].int
            let ounces = Int(round(Helpers.millilitersToOz(milli: goalInMilli!)))
            self.waterGoalLabel.text = "of \(String(ounces)) oz"

        }
        
    }
    
    func transparentPopupView() {
        // get your window screen size
        let screenRect: CGRect = UIScreen.main.bounds
        //create a new view with the same size
        let coverView = UIView(frame: screenRect)
        // change the background color to black and the opacity to 0.6
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        // add this new view to your main view
        self.navigationController?.view.addSubview(coverView)

        //self.view.addSubview(coverView)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "I'm a test label"
        label.textColor = UIColor.white
        self.navigationController?.view.addSubview(label)
        //
        //self.view.addSubview(label)
        //coverView.removeFromSuperview()

    }
    
    
    func loadActivity() {
        self.fbreqs.getDailyActivity() { json, error in
            let goalActiveMinutes = json?["goals"]["activeMinutes"].int
            let fairlyActiveMinutes = json?["summary"]["fairlyActiveMinutes"].int
            let veryActiveMinutes = json?["summary"]["veryActiveMinutes"].int
            print("Goal: \(goalActiveMinutes)")
            print("Fairly: \(fairlyActiveMinutes)")
            print("Very: \(veryActiveMinutes)" )
            self.activityGoalLabel.text = "of \(goalActiveMinutes!) min"
            let totalActiveMinutes = fairlyActiveMinutes! + veryActiveMinutes!
            self.activityMinutesLabel.text = "\(totalActiveMinutes)"
            debugPrint(error)
        }
    }
    func loadHeartRate() {
        self.fbreqs.getHeartRateTimeSeriesFromPeriod() {json, error in
            print("HR: \(json)" )
            let restingHeartRateToday = json?["activities-heart"][0]["value"]["restingHeartRate"].int
            self.heartRateLabel.text = "\(restingHeartRateToday!)"
        }
    }
    func loadWeightLog() {}
    func loadEmotion() {}
    func loadSleep() {
        self.fbreqs.getSleepLogs() { json, error in
            let totalMinutesAsleep = json?["summary"]["totalMinutesAsleep"].int
            let hoursMinutes = Helpers.secondsToHoursMinutes(seconds: totalMinutesAsleep!)
            let hours = hoursMinutes.0
            let minutes = hoursMinutes.1
            let label = "\(hours)h \(minutes)m"
            self.timeSleptLabel.text  = label
        }
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
