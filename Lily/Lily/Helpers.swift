//
//  Helpers.swift
//  Lily
//
//  Created by Tom Reinhart on 12/29/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwiftyJSON


extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or capitalized(with: locale)
    }
}

class Helpers {
    
    /// TODO need to get the specific user's current date
    static func todaysDate() -> String {
        let date = NSDate()
        let styler = DateFormatter()
        styler.dateFormat = "yyyy-MM-dd"
        let dateString = styler.string(from: date as Date)
        return dateString
    }
    /**
     ## Get Offset ##
     Returns the offset from UTC in a string formatted for fitbit POST standards
    */
    static func getOffset() -> String {
        var offsetSeconds = Int(NSTimeZone.local.secondsFromGMT())
        var offsetString = "+00:00"
        var offsetSymbol = "+"
        var offsetHoursLeadString = "0"
        var offsetMinutesLeadString = "0"
        if offsetSeconds < 0 {
            offsetSymbol = "-"
            offsetSeconds = (offsetSeconds * -1)
        }
        let offsetHours = Int(offsetSeconds / 3600)
        let offsetMinutes = offsetSeconds - (offsetHours * 3600)
        if offsetHours > 10 {
            offsetHoursLeadString = ""
        }
        if offsetMinutes > 10 {
            offsetMinutesLeadString = ""
        }
        offsetString = String(format: "%@%@%i:%@%i", offsetSymbol, offsetHoursLeadString, offsetHours, offsetMinutesLeadString, offsetMinutes)
        return offsetString
    }
    
    static func minutesToHoursMinutes (minutes : Int) -> (Int, Int) {
        return (Int(minutes/60), (minutes % 60))
    }
    static func secondsToHoursMinutes (seconds : Int) -> (Int, Int) {
        let hours = Int(floor(Double(seconds / 3600)))
        let minutes = Int(Int(seconds - hours * 3600)/60)
        return (hours, minutes)
    }
    
    static func millilitersToOz(milli : Double) -> (Double) {
        return (Double(milli) * 0.033814)
    }
    static func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func postDailyLogToFirebase(key: String, value: Any, daysAgo: Int? = nil, specifiedDate: Date? = nil) {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        var date = Date()
        if daysAgo != nil {
            date = Helpers.getDateNDaysAgo(daysAgo: daysAgo!).date
        } else if specifiedDate != nil {
            date = specifiedDate!
        }
        let dateInFormat = dateFormatter.string(from: date)
        
        if let uid = user?.uid {
            ref.child("users/\(uid)/logs/\(dateInFormat)/\(key)").setValue(value)
        }
    }
    

    
    
    
    static func postJournalDate(key: String, value: Any, daysAgo: Int? = nil, specifiedDate: Date? = nil) {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        var date = Date()
        if daysAgo != nil {
            date = Helpers.getDateNDaysAgo(daysAgo: daysAgo!).date
        } else if specifiedDate != nil {
            date = specifiedDate!
        }
        let dateInFormat = dateFormatter.string(from: date)
        
        if let uid = user?.uid {
            ref.child("users/\(uid)/logs/\(dateInFormat)/\(key)").setValue(value)
        }
    }
    
    
    static func checkIfDailyLogExists() {
        let user = FIRAuth.auth()?.currentUser
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        if let uid = user?.uid {
            let ref = FIRDatabase.database().reference()

            ref.child("users/\(uid)/logs").observeSingleEvent(of: .value, with: { (snapshot) in

                print(snapshot.value ?? "none")
                print("Snap: \(snapshot)")
                print("date \(dateInFormat)")
                if snapshot.hasChild(dateInFormat){
                    
                    print("key exists")
                    
                } else{
                    self.createEmptyDailyLog()
                    print("key doesn't exist")
                }
                
                
            })
        }
    }
    
    static func checkIfUserExists(key: String) {
        let user = FIRAuth.auth()?.currentUser
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        if let uid = user?.uid {
            print("MY UID: \(uid)")
            let refToCehck = FIRDatabaseReference().child("users/\(uid)/logs/")
            
            refToCehck.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.hasChild(dateInFormat){
                    
                    print("key exists")
                    
                } else{
                    
                    print("key doesn't exist")
                }
                
                
            })
        }
    }
    
    
    static func loadDailyLogFromFirebase(key: String, daysAgo: Int? = nil, providedDate: Date? = nil,  completionHandler: @escaping (JSON, Error?) -> ()) {
        let calendar = Calendar.current
        var date = Date()
        var specificDate: String
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        if providedDate != nil {
            date = providedDate!
            specificDate = df.string(from: date)

        } else if daysAgo != nil {
            let pastDate = calendar.date(byAdding: .day, value: -1*daysAgo!, to: date)
            specificDate = df.string(from: pastDate!)
        } else {
            return // cannot load from nothing
        }


        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        var childString = "logs/\(specificDate)/\(key)"
        
        if key == "" {
            childString = "logs/\(specificDate)"
        }
        
        ref.child("users").child(userID!).child(childString).observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value!)
            completionHandler(json, nil)
            
            // ...
        }) { (error) in
            completionHandler(nil, error)
            print(error.localizedDescription)
        }
        
    }
    
    // TODO daily log update
    static func createEmptyDailyLog() {
        Helpers.postDailyLogToFirebase(key: "activityMinutes", value : 0)
        Helpers.postDailyLogToFirebase(key: "activityMinutesGoal", value : 30)
        Helpers.postDailyLogToFirebase(key: "restingHeartRate", value : 0)
        Helpers.postDailyLogToFirebase(key: "sleepTime", value : "0h 00m")
        Helpers.postDailyLogToFirebase(key: "waterCupsConsumed", value : 0)
        Helpers.postDailyLogToFirebase(key: "waterCupsGoal", value : 10)
        Helpers.postDailyLogToFirebase(key: "kicksTotal", value : 0)
        Helpers.postDailyLogToFirebase(key: "kicksTotalTime", value : 0)
        
    }
    static func setFirebaseTimer(time: Int?, elapsedTime: Int?) {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        if let uid = user?.uid {
            if let startTime = time {
                ref.child("users/\(uid)/timer/startTime").setValue(startTime)
                
            } else {
                ref.child("users/\(uid)/timer/startTime").setValue(nil)
                
            }
            if let elapsed = elapsedTime {
                ref.child("users/\(uid)/timer/elapsedTime").setValue(elapsed)
                
            } else {
                ref.child("users/\(uid)/timer/elapsedTime").setValue(nil)
                
            }
        }
    }
    
    static func loadTimerFromFirebase(completionHandler: @escaping (Int?, Int?, Error?) -> ()) {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).child("timer").observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value!)
            var start : Int?
            var elapsed  : Int?
            if let startTime = json["startTime"].int {
                start = startTime
                completionHandler(start, nil, nil)

            }
            if let elapsedTime = json["elapsedTime"].int {
                elapsed = elapsedTime
                completionHandler(nil, elapsed, nil)

            }
            print("both loaded... loaded: startTime: \(start) and elapsedTime: \(elapsed)")
            completionHandler(start, elapsed, nil)
            
        }) { (error) in
            completionHandler(nil, nil, error)
            print(error.localizedDescription)
        }
    }
    
    
    static func postDailyLogToFirebaseUpdateValue(key: String, value: Int) {
        var _: FIRDatabaseReference!

        let user = FIRAuth.auth()?.currentUser
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)

        
        if let uid = user?.uid {
            print("MY UID: \(uid)")
                print("users/\(uid)/logs/\(dateInFormat)/\(key)")
                let prntRef = FIRDatabase.database().reference().child("users/\(uid)/logs/\(dateInFormat)/\(key)")
                prntRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                if let post = currentData.value as? Int {
                    currentData.value = post + value

                    return FIRTransactionResult.success(withValue: currentData)
                }
                return FIRTransactionResult.success(withValue: currentData)
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }

    }
    
    

    

    static func getWeekDayFromDate(date: Date) -> String {
        return (date.dayOfWeek() ?? nil)!
    }
    
    
    static func getShortDateRangeString(date: Date) -> String {

        let end = self.formatShortDate(date: date )
        let calendar = Calendar.current
        let sixDaysBefore = calendar.date(byAdding: .day, value: -6, to: date)
        let start = self.formatShortDate(date: sixDaysBefore!)
        let rangeString = "\(start)-\(end)"
        return rangeString
    }
    static func getDateNDaysAgo(daysAgo: Int) -> (date: Date, dateString: String) {
        let calendar = Calendar.current
        let date = Date()
        let pastDate = calendar.date(byAdding: .day, value: -1*daysAgo, to: date)
        let df = DateFormatter()
//        df.dateFormat = "MM-dd-yyyy"
        df.dateFormat = "yyyy-MM-dd"
        let pastDateString = df.string(from: pastDate!)
        return (pastDate ?? Date(), pastDateString)
    }
    
    
    static func get7DayRange(weeksAgo: Int) -> [(String, String)] {
        let daysAgo = weeksAgo*7
        var days = [(String, String)]()
        for i in (daysAgo...daysAgo+6).reversed() {
            let dayStr = self.getDateNDaysAgo(daysAgo: i)
            let weekDay = self.getWeekDayFromDate(date: dayStr.0)
            let tuple = (weekDay, dayStr.1)
            days.append(tuple)
        }
        print(days)
        return days
    }

    static func get7DayRangeInts(weeksAgo: Int) -> (Int, Int) {
        let daysAgo = weeksAgo*7
        return (daysAgo, daysAgo+6)

    }
    
    static func getDateNWeeksAgo(weeksAgo: Int) -> (date: Date, dateString: String) {
        let calendar = Calendar.current
        let date = Date()
        let pastDate = calendar.date(byAdding: .day, value: -7*weeksAgo, to: date)
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let pastDateString = df.string(from: pastDate!)
        return (pastDate ?? Date(), pastDateString)
    }
    
    static func getLongDate(date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .long
        df.string(from: date) // "3/10/76"
        let longDate = df.string(from: date)
        return longDate
    }
    
    static func getDateFromyyyyMMdd(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        return date ?? Date()
    }
    
    static func getDateFromMMddyyyy(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MM-dd-yyyy"
        let date = dateFormatter.date(from: dateString)
        return date ?? Date()
    }
    
    static func timeString(time:Int) -> String {
        let hours = time / 3600
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    static func formatShortDate(date: Date) -> String {
        let calendar = Calendar.current

        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        var dateComps = DateComponents()
        
        dateComps.month = month
        dateComps.day = day
        
        let endDate = Calendar.current.date(from: dateComps)!
        
        let df = DateFormatter()
        df.dateStyle = .short
        df.string(from: endDate) // "3/10/16"
        let strDate = df.string(from: endDate) // by using short date we will give user a local readible time 02/01 if in america, 01/02 elsewhere
        let splt = strDate.components(separatedBy: "/")
        let short = "\(splt[0])/\(splt[1])"
        return short

    }
    
    
    static func formatMediumDate(dateString: String? = nil, date: Date? = nil) -> String {
        let df = DateFormatter()
        var d = Date()
        df.dateFormat = "MM-dd-yyyy" // firebase date store
        if dateString != nil {
            d = df.date(from: dateString!)!
        } else if date != nil {
            d = date!
        } else {
            // just using today's date
        }
        let new_format = DateFormatter()
        new_format.dateStyle = .medium
        return new_format.string(from: d)
    }
    
    static func formatDateForUser(dateString: String? = nil, date: Date? = nil) -> String {
        let df = DateFormatter()
        var d = Date()
        df.dateFormat = "MM-dd-yyyy" // firebase date store
        if dateString != nil && (dateString?.characters.count)! > 0 {
            d = df.date(from: dateString!)!
        } else if date != nil {
            d = date!
        } else {
            // just using today's date
        }
        let new_format = DateFormatter()
        new_format.dateStyle = .short
        return new_format.string(from: d)
    }
    
    static func getDayOfWeek(date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).capitalized
        // or use capitalized(with: locale) if you want
    }
    
    static func getDateComponent(date: Date) -> (day: Int, month: Int, year: Int) {
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return (day, month, year)
    }
}

