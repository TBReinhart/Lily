//
//  Helpers.swift
//  Lily
//
//  Created by Tom Reinhart on 12/29/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//

import Foundation

class Helpers {
    
    // TODO need to get the specific user's current date
    static func todaysDate() -> String {
        let date = NSDate()
        let styler = DateFormatter()
        styler.dateFormat = "yyyy-MM-dd"
        let dateString = styler.string(from: date as Date)
        return dateString
    }
}
