//
//  Helpers.swift
//  Lily
//
//  Created by Tom Reinhart on 12/29/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//

import Foundation

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
}
