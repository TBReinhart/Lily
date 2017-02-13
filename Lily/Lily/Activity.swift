//
//  Activity.swift
//  Lily
//
//  Created by Tom Reinhart on 2/12/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import Foundation

class Activity {
    
    var sedentaryMinutes     = 0
    var lightlyActiveMinutes = 0
    var fairlyActiveMinutes  = 0
    var veryActiveMinutes    = 0
    var dayOfWeek = Helpers.getWeekDayFromDate(date: Date())
    var dateString = "1970-01-01"
    var longDate = "January 1, 1970"
    init() {
        
    }
}
