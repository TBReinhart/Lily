//
//  DailyKickView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/1/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

@IBDesignable
class DailyKickView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var kickButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
//    let appDelegate = AppDelegate.getDelegate()
    var firstKick = true
    var timer = Timer()
    var isTimerRunning = false
    var resumeTapped = false
    var finalSeconds = 0
    var globalSeconds = 0
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        
    }


    
    func setupView() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: "DailyKickView", bundle: bundle).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = bounds
        self.pauseButton.isEnabled = false
        self.cancelButton.isEnabled = false
        self.timeLabel.text = timeString(time: TimeInterval(globalSeconds))
        if globalSeconds != 0 {
            runTimer()
        }
    }
    
    func setDayLabel(title: String) {
        self.dayLabel.text = title
    }
    
    
    
    @IBAction func kickButtonPressed(_ sender: Any) {
        finalSeconds = 0
        
        if isTimerRunning == false {
            runTimer()
            self.cancelButton.isEnabled = true
            self.pauseButton.isEnabled = true
            self.resumeTapped = false
            self.pauseButton.setImage(UIImage(named:"pause_button"), for: .normal)

        } else if self.resumeTapped == true {
            runTimer()
            self.resumeTapped = false
            self.pauseButton.setImage(UIImage(named:"pause_button"), for: .normal)

        }
        // add kick's date and time to array in VC
    }

    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        finalSeconds = globalSeconds
        timer.invalidate()
        globalSeconds = 0
        timeLabel.text = timeString(time: TimeInterval(globalSeconds))
        isTimerRunning = false
        pauseButton.isEnabled = false
        self.resumeTapped = false

    }
    
    
    func updateTimer(){
        print("updating timer")
        globalSeconds = globalSeconds + 1
        timeLabel.text = timeString(time: TimeInterval(globalSeconds))
        
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
        
        if self.resumeTapped == false {
            timer.invalidate()
            self.resumeTapped = true
            self.pauseButton.setImage(UIImage(named:"resume_button"), for: .normal)

        } else {
            // resume tapped == true means the clock is currently stopped, so start it
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
