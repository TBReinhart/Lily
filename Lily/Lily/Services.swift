//
//  Services.swift
//  Lily
//
//  Created by Tom Reinhart on 12/16/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//
import Foundation

// Class which contains services parameters like consumer key and secret

class Services {
    var parameters : [String: [String: String]]
    
    init() {
        self.parameters = [:]
    }
    
    subscript(service: String) -> [String:String]? {
        get {
            return parameters[service]
        }
        set {
            if let value = newValue, !Services.parametersEmpty(value) {
                parameters[service] = value
            }
        }
    }
    
    func loadFromFile(path: String) {
        if let newParameters = NSDictionary(contentsOfFile: path) as? [String: [String: String]] {
            
            for (service, dico) in newParameters {
                if parameters[service] != nil && Services.parametersEmpty(dico) { // no value to set
                    continue
                }
                updateService(service, dico: dico)
            }
        }
    }
    
    func updateService(service: String, dico: [String: String]) {
        var resultdico = dico
        if let oldDico = self.parameters[service] {
            resultdico = oldDico
            resultdico += dico
        }
        self.parameters[service] = resultdico
    }
    
    static func parametersEmpty(dico: [String: String]) -> Bool {
        return  Array(dico.values).filter({ (p) -> Bool in !p.isEmpty }).isEmpty
    }
    
    var keys: [String] {
        return Array(self.parameters.keys)
    }
}

func += <KeyType, ValueType> ( left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
