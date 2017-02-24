//
//  GoalsViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 2/13/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import UserNotifications

class GoalsViewController: UIViewController, UITextFieldDelegate {

    
    /// the images for goals
    @IBOutlet weak var waterConumptionGoalImage: UIImageView!
    @IBOutlet weak var activityGoalImage: UIImageView!
    @IBOutlet weak var sleepGoalImage: UIImageView!
    @IBOutlet weak var heartRateGoalImage: UIImageView!
    @IBOutlet weak var weightGoalImage: UIImageView!
    @IBOutlet weak var babyMovementGoalImage: UIImageView!
    @IBOutlet weak var emotionsGoalImage: UIImageView!
    @IBOutlet weak var callTheDoctorImage: UIImageView!
    
    /// the alarm clock images
    @IBOutlet weak var waterConsumptionReminderButton: UIButton!
    @IBOutlet weak var activityGoalReminderButton: UIButton!
    @IBOutlet weak var sleepGoalReminderButton: UIButton!
    @IBOutlet weak var heartRateReminderButton: UIButton!
    @IBOutlet weak var weightReminderButton: UIButton!
    @IBOutlet weak var emotionsReminderButton: UIButton!
    @IBOutlet weak var babyMovementReminderButton: UIButton!
    
    @IBOutlet weak var dailyGlassesOfWaterGoalTextField: UITextField!
    @IBOutlet weak var vigorousExerciseTextField: UITextField!
    @IBOutlet weak var moderateExerciseTextField: UITextField!
    @IBOutlet weak var lightExerciseTextField: UITextField!
    @IBOutlet weak var sedentaryTextField: UITextField!
    @IBOutlet weak var amountOfSleepTextField: UITextField!
    @IBOutlet weak var sleepEfficiencyTextField: UITextField!
    @IBOutlet weak var restingHeartRateTextField: UITextField!
    @IBOutlet weak var maxHeartRateTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var weightDateTextField: UITextField!
    @IBOutlet weak var emotionsTextField: UITextField!
    @IBOutlet weak var movementTextField: UITextField!
    
    
    
    @IBOutlet weak var obgynPhoneButton: UIButton!

    
    @IBOutlet weak var dailyGlassesOfWaterView: UIView!
    @IBOutlet weak var minutesOfVigorousExerciseView: UIView!
    @IBOutlet weak var minutesOfModerateExerciseView: UIView!
    @IBOutlet weak var minutesOfLightExerciseView: UIView!
    @IBOutlet weak var timeSpentSedentaryView: UIView!
    @IBOutlet weak var amountOfSleepView: UIView!
    @IBOutlet weak var sleepEfficiencyView: UIView!
    @IBOutlet weak var restingHeartRateView: UIView!
    @IBOutlet weak var maxHeartRateView: UIView!
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var weightGoalDateView: UIView!
    @IBOutlet weak var emotionsView: UIView!
    @IBOutlet weak var babyMovementView: UIView!
    
    let waterUnits = " cups"
    let minutesUnit = " mins"
    let percentageUnit = " %"
    let bpmUnits = " bpm"
    let weightUnit = " lbs"
    let hrLabel = " hr"
    var firebaseRef: FIRDatabaseReference!

    var dailyGlassesOfWaterText = "10 cups"
    var vigorousText = "30 mins"
    var lightText = "15 mins"
    var moderateText = "15 mins"
    var sedentaryText = "8 hr 15 mins"
    var amtSleepText = "8 hr 15 mins"
    var efficiencyText = "85 %"
    var restingHeartRateText = "75 bpm"
    var maxHeartRateText = "140 bpm"
    var weightText = "145 lbs"
    var weightDateText = "2/7/2017"
    var emotionsText = "24 hours"
    var movementText = "8 hours"

    let reminderButtonIdentifiers = ["waterButton","activityButton","movementButton","heartRateButton","weightButton","emotionsButton"]
    
    var goalsDict = [String: String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerLocal()
        self.loadReminderButtons()

        NotificationCenter.default.addObserver(self, selector: #selector(self.enteredBackground(notification:)), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillTerminate(notification:)), name:NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillResign(notification:)), name:NSNotification.Name.UIApplicationWillResignActive, object: nil)

        //scheduleLocal(frequency: 5, message: "TIME: hours = \(hour):\(minutes):\(seconds)")
        self.loadGoalsFromFirebase()
        
        
        self.setGoalsDict()
        self.setDelegates()


        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GoalsViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    
    }
    
    func loadReminderButtons() {
        let defaults = UserDefaults.standard


        if defaults.bool(forKey: "waterButton") {
            let _ = self.toggleImage(button: self.waterConsumptionReminderButton)
        }
        if defaults.bool(forKey: "activityButton") {
            let _ = self.toggleImage(button: self.activityGoalReminderButton)
        }
        if defaults.bool(forKey: "sleepButton") {
            let _ = self.toggleImage(button: self.sleepGoalReminderButton)
        }
        if defaults.bool(forKey: "heartRateButton") {
            let _ = self.toggleImage(button: self.heartRateReminderButton)
        }
        if defaults.bool(forKey: "emotionsButton") {
            let _ = self.toggleImage(button: self.emotionsReminderButton)
        }
        if defaults.bool(forKey: "movementButton") {
            let _ = self.toggleImage(button: self.babyMovementReminderButton)
        }
        if defaults.bool(forKey: "weightButton") {
            let _ = self.toggleImage(button: self.weightReminderButton)
        }
    }
    
    func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    func scheduleLocal(frequencyInHours: Int, message: String, title: String, uid: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.categoryIdentifier = identifier
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default()
        

        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let timeAsHours = (60*60) * frequencyInHours
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(timeAsHours), repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(timeAsHours), repeats: true)

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger)
        UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
    }
    
    
    func listNotifs() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            print("\(requests.count) requests -------")
            for request in requests{
                print(request.identifier)
            }
        })
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: {deliveredNotifications -> () in
            print("\(deliveredNotifications.count) Delivered notifications-------")
            for notification in deliveredNotifications{
                print(notification.request.identifier)
            }
        })
    }
    
    func removeAlarm(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    

    
    func enteredBackground(notification : NSNotification) {
    }
    
    func appWillTerminate(notification: NSNotification) {
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setGoalsDict()
        self.addAttributeToFirebaseUser(attributeName: "Goals", value: goalsDict)        // Show the navigation bar on other view controllers
    }
    
    func appWillResign(notification: NSNotification) {
        self.setGoalsDict()
        self.addAttributeToFirebaseUser(attributeName: "Goals", value: goalsDict)
    }
    
    func loadGoalsFromFirebase() {
        self.firebaseRef = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        if let uid = user?.uid {
            print("LOADING GOALS FROM FIREBASE")
            firebaseRef.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let json = JSON(snapshot.value!)
                let goals = json["Goals"]
                print("GOALS: \(goals)")
                
                
                if goals["waterGoal"] == JSON.null || goals["waterGoal"].stringValue.characters.count == 0 {
                    return
                }
                self.dailyGlassesOfWaterGoalTextField.placeholder = goals["waterGoal"].stringValue
                self.dailyGlassesOfWaterText = goals["waterGoal"].stringValue + self.waterUnits
                self.dailyGlassesOfWaterGoalTextField.text = self.dailyGlassesOfWaterText
                
                self.vigorousExerciseTextField.placeholder = goals["vigorousGoal"].stringValue
                self.vigorousText = goals["vigorousGoal"].stringValue + self.minutesUnit
                self.vigorousExerciseTextField.text = self.vigorousText
                
                self.moderateExerciseTextField.placeholder = goals["moderateGoal"].stringValue
                self.moderateText = goals["moderateGoal"].stringValue + self.minutesUnit
                self.moderateExerciseTextField.text = self.moderateText
                
                self.lightExerciseTextField.placeholder = goals["lightGoal"].stringValue
                self.lightText = goals["lightGoal"].stringValue + self.minutesUnit
                self.lightExerciseTextField.text = self.lightText
                
                self.sedentaryTextField.placeholder = goals["sedentaryGoal"].stringValue
                self.sedentaryText = goals["sedentaryGoal"].stringValue + self.minutesUnit
                self.sedentaryTextField.text = self.sedentaryText
                
                self.restingHeartRateTextField.placeholder = goals["restingHeartRateGoal"].stringValue
                self.restingHeartRateText = goals["restingHeartRateGoal"].stringValue + self.bpmUnits
                self.restingHeartRateTextField.text = self.restingHeartRateText
                
                self.maxHeartRateTextField.placeholder = goals["maxHeartRateGoal"].stringValue
                self.maxHeartRateText = goals["maxHeartRateGoal"].stringValue + self.bpmUnits
                self.maxHeartRateTextField.text = self.maxHeartRateText
                
                self.emotionsTextField.placeholder = goals["emotionsGoal"].stringValue
                self.emotionsText = goals["emotionsGoal"].stringValue + self.hrLabel
                self.emotionsTextField.text = self.emotionsText
                
                self.movementTextField.placeholder = goals["movementGoal"].stringValue
                self.movementText = goals["movementGoal"].stringValue + self.hrLabel
                self.movementTextField.text = self.movementText
                
                self.sleepEfficiencyTextField.placeholder = goals["sleepEfficiencyGoal"].stringValue
                self.efficiencyText = goals["sleepEfficiencyGoal"].stringValue + self.percentageUnit
                self.sleepEfficiencyTextField.text = self.efficiencyText
                
                self.amountOfSleepTextField.placeholder = goals["sleepTimeGoal"].stringValue
                self.amtSleepText = goals["sleepTimeGoal"].stringValue
                self.amountOfSleepTextField.text = self.amtSleepText
                
                self.weightDateTextField.placeholder = goals["weightDateGoal"].stringValue
                self.weightDateText = goals["weightDateGoal"].stringValue
                self.weightDateTextField.text = self.weightDateText
                
                self.weightTextField.placeholder = goals["weightGoal"].stringValue
                self.weightText = goals["weightGoal"].stringValue + self.weightUnit
                self.weightTextField.text = self.weightText
            }) { (error) in
                print(error.localizedDescription)
            }

        }
    }
    
    func setGoalsDict() {
        // TODO save locally
        /**
         var data = NSKeyedArchiver.archivedDataWithRootObject(jo)
         var userDefaults = NSUserDefaults.standardUserDefaults()
         userDefaults.setObject(data, forKey:akey)
        */
        
        goalsDict["waterGoal"] = self.dailyGlassesOfWaterGoalTextField.placeholder
        goalsDict["vigorousGoal"] = self.vigorousExerciseTextField.placeholder
        goalsDict["moderateGoal"] = self.moderateExerciseTextField.placeholder
        goalsDict["lightGoal"] = self.lightExerciseTextField.placeholder
        goalsDict["sedentaryGoal"] = self.sedentaryTextField.placeholder
        goalsDict["sleepTimeGoal"] = self.amountOfSleepTextField.placeholder
        goalsDict["sleepEfficiencyGoal"] = self.sleepEfficiencyTextField.placeholder
        goalsDict["weightGoal"] = self.weightTextField.placeholder
        goalsDict["weightDateGoal"] = self.weightDateTextField.placeholder
        goalsDict["emotionsGoal"] = self.emotionsTextField.placeholder
        goalsDict["movementGoal"] = self.movementTextField.placeholder
        goalsDict["restingHeartRateGoal"] = self.restingHeartRateTextField.placeholder
        goalsDict["maxHeartRateGoal"] = self.maxHeartRateTextField.placeholder
    }

    func addAttributeToFirebaseUser(attributeName: String, value: Any) {
        self.firebaseRef = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        if let uid = user?.uid {
            self.firebaseRef.child("users/\(uid)/\(attributeName)").setValue(value)
        }
    }
    
    func setDelegates() {
        self.waterConumptionGoalImage.contentMode = .scaleAspectFit
        
        self.dailyGlassesOfWaterGoalTextField.delegate = self
        self.vigorousExerciseTextField.delegate = self
        self.moderateExerciseTextField.delegate = self
        self.lightExerciseTextField.delegate = self
        self.sedentaryTextField.delegate = self
        self.amountOfSleepTextField.delegate = self
        self.sleepEfficiencyTextField.delegate = self
        self.restingHeartRateTextField.delegate = self
        self.maxHeartRateTextField.delegate = self
        self.weightTextField.delegate = self
        self.weightDateTextField.delegate = self
        self.emotionsTextField.delegate = self
        self.movementTextField.delegate = self
        self.dailyGlassesOfWaterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.waterViewPressed(_:))))
        
        self.minutesOfVigorousExerciseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.vigorousExercisePressed(_:))))
        self.minutesOfLightExerciseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.lightExercisePressed(_:))))
        self.minutesOfModerateExerciseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.moderateExercisePressed(_:))))
        self.timeSpentSedentaryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.sedentaryPressed(_:))))
        self.amountOfSleepView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.amountOfSleepPressed(_:))))
        self.sleepEfficiencyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.sleepEfficiencyPressed(_:))))
        self.weightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.setWeightPressed(_:))))
        self.weightGoalDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.weightDatePressed(_:))))
        self.restingHeartRateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.restingHeartRatePressed(_:))))
        self.maxHeartRateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.maxHeartRatePressed(_:))))
        self.emotionsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.emotionsPressed(_:))))
        self.babyMovementView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.babyMovementPressed(_:))))
    }
    
    func saveButtonStatus(identifier: String, enabled: Bool) {
        UserDefaults.standard.setValue(enabled, forKey: identifier)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func waterConsumptionReminderButtonPressed(_ sender: Any) {
        let enabled = self.toggleImage(button: self.waterConsumptionReminderButton)
        if enabled {
            self.scheduleLocal(frequencyInHours: 2, message: "Drink up!", title: "Water time", uid: "water", identifier: "water")
        } else {
            self.removeAlarm(identifier: "water")
        }
    
        self.saveButtonStatus(identifier: "waterButton", enabled: enabled)

        
        
    }
    
    
    func waterViewPressed(_ sender:UITapGestureRecognizer){
        // do other task
        self.dismissKeyboard()
        self.dailyGlassesOfWaterGoalTextField.becomeFirstResponder()
    }
    func vigorousExercisePressed(_ sender:UITapGestureRecognizer){
        self.dismissKeyboard()
        self.vigorousExerciseTextField.becomeFirstResponder()
    }
    func moderateExercisePressed(_ sender:UITapGestureRecognizer){
        // do other task
        self.dismissKeyboard()
        self.moderateExerciseTextField.becomeFirstResponder()
    }
    func lightExercisePressed(_ sender:UITapGestureRecognizer){
        // do other task
        self.dismissKeyboard()
        self.lightExerciseTextField.becomeFirstResponder()
    }
    func sedentaryPressed(_ sender:UITapGestureRecognizer){
        // do other task
        self.dismissKeyboard()
        self.sedentaryTextField.becomeFirstResponder()

    }
    func amountOfSleepPressed(_ sender:UITapGestureRecognizer){
        self.dismissKeyboard()
        self.amountOfSleepTextField.becomeFirstResponder()

    }
    func sleepEfficiencyPressed(_ sender:UITapGestureRecognizer){
        self.dismissKeyboard()
        self.sleepEfficiencyTextField.becomeFirstResponder()


    }
    func restingHeartRatePressed(_ sender:UITapGestureRecognizer){
        self.dismissKeyboard()
        self.restingHeartRateTextField.becomeFirstResponder()


    }
    func maxHeartRatePressed(_ sender:UITapGestureRecognizer){
        self.dismissKeyboard()
        self.maxHeartRateTextField.becomeFirstResponder()


    }
    func setWeightPressed(_ sender:UITapGestureRecognizer){
        self.dismissKeyboard()
        self.weightTextField.becomeFirstResponder()

    }
    func weightDatePressed(_ sender:UITapGestureRecognizer){
        self.dismissKeyboard()
        self.weightDateTextField.becomeFirstResponder()

    }
    func emotionsPressed(_ sender:UITapGestureRecognizer){
        self.dismissKeyboard()
        self.emotionsTextField.becomeFirstResponder()


    }
    func babyMovementPressed(_ sender:UITapGestureRecognizer){
        self.dismissKeyboard()
        self.movementTextField.becomeFirstResponder()
    }
    
    
    func setReminder(reminder: String) {
        
    }
    // returns true for On, returns false for off
    func toggleImage(button: UIButton) -> Bool {
        if self.isImageEqual(image1: button.currentImage!, isEqualTo: UIImage(named: "alarm_clock_enabled")!) {
            button.setImage(UIImage(named: "alarm_clock_disabled"), for: UIControlState.normal)
            return false
        } else {
            button.setImage(UIImage(named: "alarm_clock_enabled"), for: .normal)
            return true
        }
    }
    
    
    @IBAction func activityGoalReminderButtonPressed(_ sender: Any) {
        let enabled = self.toggleImage(button: self.activityGoalReminderButton)
        if enabled {
            self.scheduleLocal(frequencyInHours: 2, message: "Let's work out", title: "Activity time", uid: "activity", identifier: "activity")
        } else {
            self.removeAlarm(identifier: "activity")
        }
        self.saveButtonStatus(identifier: "activityButton", enabled: enabled)

    }
    
    @IBAction func sleepGoalReminderButtonPressed(_ sender: Any) {
        let enabled = self.toggleImage(button: self.sleepGoalReminderButton)
        if enabled {
            self.scheduleLocal(frequencyInHours: 12, message: "How'd you sleep last night?", title: "Sleep!", uid: "sleep", identifier: "sleep")
        } else {
            self.removeAlarm(identifier: "sleep")
        }
        self.saveButtonStatus(identifier: "sleepButton", enabled: enabled)

    }
    
    @IBAction func heartRateReminderButtonPressed(_ sender: Any) {
        let enabled = self.toggleImage(button: self.heartRateReminderButton)
        if enabled {
            self.scheduleLocal(frequencyInHours: 8, message: "Watch your heart rate!", title: "Heart Rate", uid: "heartRate", identifier: "heartRate")
        } else {
            self.removeAlarm(identifier: "heartRate")
        }
        self.saveButtonStatus(identifier: "heartRateButton", enabled: enabled)

    }

    @IBAction func weightReminderButtonPressed(_ sender: Any) {
        let enabled = self.toggleImage(button: self.weightReminderButton)
        if enabled {
            self.scheduleLocal(frequencyInHours: 24, message: "Take a second to log your weight", title: "Time to check your weight progress!", uid: "weight", identifier: "weight")
        } else {
            self.removeAlarm(identifier: "wight")
        }
        self.saveButtonStatus(identifier: "weightButton", enabled: enabled)

    }
    
    @IBAction func emotionsReminderButtonPressed(_ sender: Any) {
        let enabled = self.toggleImage(button: self.emotionsReminderButton)
        if enabled {
            self.scheduleLocal(frequencyInHours: 6, message: "Take a second to log your emotions", title: "How're you feeling today?", uid: "emotions", identifier: "water")
        } else {
            self.removeAlarm(identifier: "emotions")
        }
        self.saveButtonStatus(identifier: "emotionsButton", enabled: enabled)

    }

    @IBAction func babyMovementReminderButtonPressed(_ sender: Any) {
        let enabled = self.toggleImage(button: self.babyMovementReminderButton)
        if enabled {
            self.scheduleLocal(frequencyInHours: 2, message: "Has your baby kicked?", title: "Baby Movement", uid: "movement", identifier: "movement")
        } else {
            self.removeAlarm(identifier: "movement")
        }
        self.saveButtonStatus(identifier: "movementButton", enabled: enabled)

    }
    
    @IBAction func callOBGYNButtonPressed(_ sender: Any) {
        if let url = URL(string: "tel://\(self.obgynPhoneButton.currentTitle!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

    }


    // TODO
    // fetch goals and then save them to firebase 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text?.characters.count == 0 {
            if textField == dailyGlassesOfWaterGoalTextField {
                textField.text = self.dailyGlassesOfWaterText
            } else if textField == sedentaryTextField {
                textField.text = self.sedentaryText
            } else if textField == vigorousExerciseTextField {
                textField.text = self.vigorousText
            } else if textField == moderateExerciseTextField {
                textField.text = self.moderateText
            } else if textField == lightExerciseTextField {
                textField.text = self.lightText
            } else if textField == amountOfSleepTextField  {
                textField.text = self.amtSleepText
            } else if textField == sleepEfficiencyTextField {
                textField.text = self.efficiencyText
            } else if textField == restingHeartRateTextField {
                textField.text = self.restingHeartRateText
            } else if textField == maxHeartRateTextField {
                textField.text = self.maxHeartRateText
            } else if textField == weightTextField {
                textField.text = self.weightText
            } else if textField == weightDateTextField {
                textField.text = self.weightDateText
            } else if textField == emotionsTextField {
                textField.text = self.emotionsText
            } else if textField == movementTextField {
                textField.text = self.movementText
            }

        } else {
            textField.placeholder = textField.text!
            if textField == dailyGlassesOfWaterGoalTextField {
                self.dailyGlassesOfWaterText = textField.text! + self.waterUnits
                textField.text = self.dailyGlassesOfWaterText
            } else if textField == sedentaryTextField {
                self.sedentaryText = textField.text! + self.minutesUnit
                textField.text = self.sedentaryText
            } else if textField == vigorousExerciseTextField {
                self.vigorousText = textField.text! + self.minutesUnit
                textField.text = self.vigorousText
            } else if textField == moderateExerciseTextField {
                self.moderateText = textField.text! + self.minutesUnit
                textField.text = self.moderateText
            } else if textField == lightExerciseTextField {
                self.lightText = textField.text! + self.minutesUnit
                textField.text = self.lightText
            } else if textField == amountOfSleepTextField  {
                self.amtSleepText = textField.text! + self.minutesUnit
                textField.text = self.amtSleepText
            } else if textField == sleepEfficiencyTextField {
                self.efficiencyText = textField.text! + self.percentageUnit
                textField.text = self.efficiencyText
            } else if textField == restingHeartRateTextField {
                self.restingHeartRateText = textField.text! + self.bpmUnits
                textField.text = self.restingHeartRateText
            } else if textField == maxHeartRateTextField {
                self.maxHeartRateText = textField.text! + self.bpmUnits
                textField.text = self.maxHeartRateText
            } else if textField == weightTextField {
                self.weightText = textField.text! + self.weightUnit
                textField.text = self.weightText
            } else if textField == weightDateTextField {
                self.weightDateText = textField.text! + self.weightUnit
                textField.text = self.weightDateText
            } else if textField == emotionsTextField {
                self.emotionsText = textField.text! + self.hrLabel
                textField.text = self.emotionsText
            } else if textField == movementTextField {
                self.movementText = textField.text! + self.hrLabel
                textField.text = self.movementText
            }
        }
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func isImageEqual(image1: UIImage, isEqualTo image2: UIImage) -> Bool {
        let data1: NSData = UIImagePNGRepresentation(image1)! as NSData
        let data2: NSData = UIImagePNGRepresentation(image2)! as NSData
        return data1.isEqual(data2)
    }

}
extension UIImage {
    
    func isEqualToImage(image: UIImage) -> Bool {
        let data1: NSData = UIImagePNGRepresentation(self)! as NSData
        let data2: NSData = UIImagePNGRepresentation(image)! as NSData
        return data1.isEqual(data2)
    }
    
}
