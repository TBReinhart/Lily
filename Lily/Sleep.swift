//
//  Sleep.swift
//  Lily
//
//  Created by Tom Reinhart on 1/30/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import Foundation

class Sleep {
    
    var totalMinutesAsleep = 0
    var awakeCount = 0
    var efficiency = 0
    var awakeDuration = 0
    var restlessCount = 0
    var restlessDuration = 0
    var sleepLabel = "0h 0m"
    var sleepTimeRounded = 0.0
    var dayOfWeek = "Sunday"
    var dateString = "1970-01-01"
    var dateLong = "January 1, 1970"
    var shortDateString = "1/1"
    
    init() {
        totalMinutesAsleep = 0
        awakeCount = 0
        efficiency = 0
        awakeDuration = 0
        restlessCount = 0
        restlessDuration = 0
        sleepLabel = "0h 0m"
    }
}
