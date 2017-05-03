//
//  Kick.swift
//  Lily
//
//  Created by Tom Reinhart on 5/2/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import Foundation

class Kick: NSObject, NSCoding {
    
    var index : Int
    var stringDate : String
    
    init(index: Int, stringDate: String) {
        self.index = index
        self.stringDate = stringDate
    }
    required init(coder decoder: NSCoder) {
        self.stringDate = decoder.decodeObject(forKey: "stringDate") as? String ?? ""
        self.index = decoder.decodeInteger(forKey: "index")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(index, forKey: "index")
        coder.encode(stringDate, forKey: "stringDate")
    }
}
