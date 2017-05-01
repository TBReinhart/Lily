//
//  DailyKickView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/1/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class DailyKickView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var kickButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    // TODO run a timer from the firebase server where you start the timer and set a timestamp
    // when you load the page, check for this timer and store current kicks
    
    
    var firstKick = true
    var timer = Timer()
    var isTimerRunning = false
    var resumeTapped = false
    var finalSeconds = 0
    var globalSeconds : Int?
    var timerTimestamp : Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        
    }

    // elapsed
    // 1493322818.47319
    // 1493322774
    func setupView() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: "DailyKickView", bundle: bundle).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = bounds
        self.disableButtons()
        self.loadTimer()
        

    }
    
    func disableButtons() {
        self.pauseButton.isEnabled = false
        self.cancelButton.isEnabled = false
        self.kickButton.isEnabled = false
    }
    
    func setDayLabel(title: String) {
        self.dayLabel.text = title
    }
    
    func enableButtons() {
        self.pauseButton.isEnabled = true
        self.cancelButton.isEnabled = true
        self.kickButton.isEnabled = true
    }
    
    
    func loadTimer() {
        Helpers.loadTimerFromFirebase() { startTime, elapsedTime, error in
            if error == nil {
                // wtf return separately?
                if let start = startTime {
                    
                    print("Start time: \(start)")
                    let timerStartDate = NSDate(timeIntervalSince1970: TimeInterval(start))
                    print(timerStartDate)

                    let elapsed = Date().timeIntervalSince(timerStartDate as Date)
                    print("elapsed in loadTimer: \(elapsed)")
                    self.globalSeconds = Int(elapsed)
                    self.timeLabel.text = self.timeString(time: TimeInterval(self.globalSeconds!))
                    self.kickButton.isEnabled = true
                    self.enableButtons()
                    self.runTimer()
                    print("Elapsed time in seconds \(elapsed)")
                } else if let elapsed = elapsedTime {
                    print("Elapsed time, so was paused and is currently paused")
                    // it was paused before, so these are global seconds now
                    self.globalSeconds = elapsed
                    self.timeLabel.text = self.timeString(time: TimeInterval(self.globalSeconds!))
                    self.enableButtons()
                    self.pauseButton.setImage(UIImage(named:"resume_button"), for: .normal)
                    
                    
                } else {
                    // aka no timer running
                    print("server time is nil")
                    self.globalSeconds = 0
                    self.timeLabel.text = self.timeString(time: TimeInterval(self.globalSeconds!)) // no time yet
                    self.pauseButton.isEnabled = false
                    self.cancelButton.isEnabled = false
                    self.kickButton.isEnabled = true
                }
            }

        }
    }
    
    
    @IBAction func kickButtonPressed(_ sender: Any) {
        finalSeconds = 0
        
        if isTimerRunning == false {
            let time = Int(Date().timeIntervalSince1970)
            print("Time of first timer: \(time)")
            Helpers.setFirebaseTimer(time: time, elapsedTime: nil)
            runTimer()
            self.cancelButton.isEnabled = true
            self.pauseButton.isEnabled = true
            self.resumeTapped = false
            self.pauseButton.setImage(UIImage(named:"pause_button"), for: .normal)

        } else if self.resumeTapped == true {
            // if it was paused and we started it
            print("paused and started again")
            
            runTimer()
            self.resumeTapped = false
            self.pauseButton.setImage(UIImage(named:"pause_button"), for: .normal)

        }
        // add kick's date and time to array in VC
    }

    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        timerTimestamp = nil
//        finalSeconds = globalSeconds
        Helpers.setFirebaseTimer(time: nil, elapsedTime: nil)
        timer.invalidate()
        self.globalSeconds = 0
        timeLabel.text = timeString(time: TimeInterval(self.globalSeconds!))
        isTimerRunning = false
        pauseButton.isEnabled = false
        self.resumeTapped = false

    }
    
    
    func updateTimer(){
        self.globalSeconds = self.globalSeconds! + 1
        timeLabel.text = timeString(time: TimeInterval(self.globalSeconds!))
        
    }
    
    func getFinalSeconds() -> Int {
        return self.finalSeconds
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        print("pause \(self.resumeTapped)")
        
        if self.resumeTapped == false { // clicked pause
            timer.invalidate()
            self.resumeTapped = true
            self.pauseButton.setImage(UIImage(named:"resume_button"), for: .normal)

        } else {
            // resume tapped == true means the clock is currently stopped, so start it
            // will need to load timer from server
            runTimer()
            self.resumeTapped = false
            self.pauseButton.setImage(UIImage(named:"pause_button"), for: .normal)

        }
    }
    
    func runTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(DailyKickView.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        pauseButton.isEnabled = true
    }

    func setTimeLabel(time: String) {
        self.timeLabel.text = time
    }
}
