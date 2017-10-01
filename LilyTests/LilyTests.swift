//
//  LilyTests.swift
//  LilyTests
//
//  Created by Tom Reinhart on 1/7/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import XCTest
@testable import Lily
@testable import SwiftyJSON
@testable import Alamofire
@testable import p2_OAuth2

class LilyTests: XCTestCase {
    

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHeartRateIntraTimeSeriesFromPeriodDefault() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let fbreqs = FitbitRequests()
        fbreqs.getHeartRateIntraTimeSeriesFromPeriod() { json, error in
            assert(error == nil)
            debugPrint("JSON in testHeartRateIntraTimeSeriesFromPeriodDefault: \(json)")

        }
    }
    
    func testGetDevices() {
        let fbreqs = FitbitRequests()
        fbreqs.getDevices() { json, error in
            assert(error == nil)
            debugPrint("JSON IN testGetDevices: \(json)")

            if let devices = json?.array {
                for device in devices {
                    if let trackerId = device["id"].string {
                        debugPrint("ALARM FOR TRACKER ID: \(trackerId)")
                        //fbreqs.addAlarm(trackerId: trackerId, time: "15:00", recurring: true, weekDays: ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY"])
                        fbreqs.getAlarms(trackerId: trackerId) { j, e in
                            assert(e == nil)
                            
                        }
                    }
                }
            }
            
        }

    }
    func testLogWater() {
        let fbreqs = FitbitRequests()
        fbreqs.logWater(amount: "8.0", unit: "fl oz") { json, error in // amount in units
            assert(error == nil)
            debugPrint("water logging in tests: \(json)")

        }

    }
    
    func testLogWeight() {
        let fbreqs = FitbitRequests()
        fbreqs.logWeight(weight: "73.0") { json, error  in
            assert(error == nil)
            debugPrint("logging weight in tests \(json)")

            
        }
    }
    
    func testHeartFromTimeSeriesFromPeriod() {
        let fbreqs = FitbitRequests()
        fbreqs.getHeartRateTimeSeriesFromPeriod(date: "today", period: "1d") { json, error in
            assert(error == nil)
            debugPrint("get heart rate time series from period today 1d test: \(json)")

        }

    }
    
    func testGetWeightToday() {
        let fbreqs = FitbitRequests()
        fbreqs.getWeightOnDate(date: "today") { json, error in
            assert(error == nil)
            debugPrint("get weight today test \(json)")

            
        }

    }
    func testIntraHeartRate() {
        // TODO: this will be forbidden until permissions are given
        let fbreqs = FitbitRequests()
        fbreqs.getHeartRateIntraTimeSeriesFromPeriod(date: "today", detailLevel: "1sec", startTime: "00:00", endTime: "00:01") { json, error in
            assert(error == nil)
            debugPrint("JSON in intra test: \(json)")

        }
    }
    
    func testGetSleepLogs() {
        let fbreqs = FitbitRequests()
        fbreqs.getSleepLogs() { json, error in
            assert(error == nil)
            debugPrint("test get sleep logs response \(json)")
            
        }
    }
    func testGetSleepGoal() {
        let fbreqs = FitbitRequests()
        fbreqs.getSleepGoal() { json, error in
            assert(error == nil)
            debugPrint("test get sleep logs response \(json)")
            
        }
    }
    
    func testUpdateSleepGoal() {
        let fbreqs = FitbitRequests()
        fbreqs.updateSleepGoal() { json, error in
            assert(error == nil)
            debugPrint("Json response in test update sleep goal \(json)")
            
        }
    }
    
    func testSleepTimeSeriesFromStartEndDates() {
        let fbreqs = FitbitRequests()
        fbreqs.getSleepTimeSeriesFromStartEndDates(resourcePath: "sleep/minutesAsleep", startDate: "2017-07-01", endDate: "today") { json, error in
            assert(error == nil)
            debugPrint("Json response in test sleep time series from start end dates \(json)")
            
        }
        
    }
    
    func testSleepTimeSeriesFromPeriod() {
        let fbreqs = FitbitRequests()
        fbreqs.getSleepTimeSeriesFromPeriod(resourcePath: "sleep/minutesAsleep", date: "today", period: "1w") { json, error in
            debugPrint(error)
            assert(error == nil)
            debugPrint("Json response in test sleep time series from period \(json)")
        }


    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
