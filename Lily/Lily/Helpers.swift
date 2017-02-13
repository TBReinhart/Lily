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
    
    static func postDailyLogToFirebase(key: String, value: Any) {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        
        if let uid = user?.uid {
            ref.child("users/\(uid)/logs/\(dateInFormat)/\(key)").setValue(value)
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
        df.dateFormat = "yyyy-MM-dd"
        let pastDateString = df.string(from: pastDate!)
        return (pastDate ?? Date(), pastDateString)
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
        df.string(from: endDate) // "3/10/76"
        let strDate = df.string(from: endDate) // by using short date we will give user a local readible time 02/01 if in america, 01/02 elsewhere
        let splt = strDate.components(separatedBy: "/")
        let short = "\(splt[0])/\(splt[1])"
        return short

    }
}
