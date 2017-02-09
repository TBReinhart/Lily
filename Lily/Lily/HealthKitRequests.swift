//
//  HealthKitRequests.swift
//  Lily
//
//  Created by Tom Reinhart on 1/25/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitRequests {
    
    let healthKitStore = HKHealthStore()

    
    func checkAuthorization() -> Bool {
        var isEnabled = true
        
        if HKHealthStore.isHealthDataAvailable() {
            let healthKitTypesToRead : Set = [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!, //birthday
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.heartRate)!, //heart rate
                HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!, // sleep
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.dietaryWater)!, //water
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.appleExerciseTime)!, //exercise time
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.dietarySugar)!, //sugar intake
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.stepCount)!, //step count
                HKObjectType.workoutType(), // exercise
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.respiratoryRate)!, // respiratory rate
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.bodyMassIndex)!, //BMI
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.bodyMass)!, //Body Mass

                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.basalBodyTemperature)! //basal body temp
            ]
            
            self.healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead, completion: { (success, error) in
                isEnabled = success
            })
        }
        else {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func isHealthDataAvailable() -> Bool {
        if(HKHealthStore.isHealthDataAvailable()) {
            return true
        } else {
            return false
        }
    }

    func getSleepLogs(completionHandler: @escaping (String?, Error?) -> ()) {
        
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    completionHandler(nil, error)
                    return
                }
                if let result = tmpResult {
                    // do something with my data
                    // TODO can only get In Bed, Asleep, Awake so we need to make an efficiency based on this
                    for item in result {
                        print("SLEEP IN HK: ")
                        if let sample = item as? HKCategorySample {
                            print(sample)
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                            if value == "Asleep" {
                                let elapsed = sample.endDate.timeIntervalSince(sample.startDate)
                                print(elapsed)
                                print(Int(round(elapsed)))
                                let hoursMinutes = Helpers.secondsToHoursMinutes(seconds: Int(round(elapsed)))
                                let hours = hoursMinutes.0
                                let minutes = String(format: "%02d", hoursMinutes.1)
                                let formatted = "\(hours)h \(minutes)m"
                                completionHandler(formatted, nil)

                            }
                        }
                    }
                }
            }
            // finally, we execute our query
            self.healthKitStore.execute(query)
        }
    }
    func getHeartRate(completionHandler: @escaping (String?, Error?) -> ()) {
        let heartrate = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let sort = [
            NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        ]
        let heartRateUnit = HKUnit(from: "count/min")
        DispatchQueue.main.async(){
            let sampleQuery = HKSampleQuery(sampleType: heartrate!, predicate: nil, limit: 1, sortDescriptors: sort, resultsHandler: { (query, results, error) in
                if let results = results as? [HKQuantitySample]
                {
                    let sample = results[0] as HKQuantitySample
                    print("HR SAMPLE: \(sample)")
                    let value = sample.quantity.doubleValue(for: heartRateUnit)
                    if error != nil {
                        completionHandler(nil, error)
                    } else {
                        completionHandler("\(Int(round(value)))", nil)
                    }
                }
            })
            self.healthKitStore.execute(sampleQuery)
        }
    }
    
    func updateHeartRate(samples: [HKSample]?)
    {
        let heartRateUnit = HKUnit(from: "count/min")
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        DispatchQueue.main.async {
            guard let sample = heartRateSamples.first else{return}
            let value = sample.quantity.doubleValue(for: heartRateUnit)
            print("VALUE \(String(UInt16(value)))")
            let date = sample.startDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            print("TIME STAMP LABEL \(dateFormatter.string(from: date))")
        }
    }
    
    func getStepCount(completionHandler: @escaping (String?, Error?) -> ()) {
        
        //   Define the Step Quantity Type
//        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)

        //   Get the start of the day
        let date = NSDate()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date as Date)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: newDate as Date, end: NSDate() as Date, options: .strictStartDate)
        let interval: NSDateComponents = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents:interval as DateComponents)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                completionHandler(nil, error)
                return
            }
            
            if let myResults = results{
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                myResults.enumerateStatistics(from: yesterday! as Date, to: Calendar.current.date(byAdding: .day, value: 0, to:Date())!  as Date) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        completionHandler("\(steps)", nil)
                        
                    }
                }
            }
            
            
        }
        self.healthKitStore.execute(query)
    }
    func getActiveMinutes(completionHandler: @escaping (String?, Error?) -> ()) {
        
        let activeMins = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)        
        //   Get the start of the day
        let date = NSDate()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date as Date)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: newDate as Date, end: NSDate() as Date, options: .strictStartDate)
        let interval: NSDateComponents = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: activeMins!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents:interval as DateComponents)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                completionHandler(nil, error)
                return
            }
            
            if let myResults = results{
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                myResults.enumerateStatistics(from: yesterday! as Date, to: Calendar.current.date(byAdding: .day, value: 0, to:Date())!  as Date) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let minutes = Int(round(quantity.doubleValue(for: HKUnit.minute())))
                        print("Minutes = \(minutes)")
                        completionHandler("\(minutes)", nil)
                        
                    }
                }
            }
            
        }
        self.healthKitStore.execute(query)
    }
    
    func getWaterConsumption(completionHandler: @escaping (String?, Error?) -> ()) {
        
        let waterConsumption = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)
        
        let bodyMass = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)

        
        //   Get the start of the day
        let date = NSDate()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date as Date)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: newDate as Date, end: NSDate() as Date, options: .strictStartDate)
        let interval: NSDateComponents = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: waterConsumption!, quantitySamplePredicate: predicate, options: [], anchorDate: newDate as Date, intervalComponents:interval as DateComponents)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                print("error \(error)")
                completionHandler(nil, error)
                return
            }
            
            if let myResults = results{
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                myResults.enumerateStatistics(from: yesterday! as Date, to: Calendar.current.date(byAdding: .day, value: 0, to:Date())!  as Date) {
                    statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        let water = Int(round(quantity.doubleValue(for: HKUnit.cupUS())))
                        completionHandler("\(water)", nil)
                    } else {
                        completionHandler("0", nil)

                    }
                }
            }
            
        }
        self.healthKitStore.execute(query)
    }
    func getWeight(completionHandler: @escaping (String?, Error?) -> ()) {
        // Predicate for the height query
        let distantPastHeight = NSDate.distantPast as NSDate
        let currentDate = NSDate()
        let lastHeightPredicate = HKQuery.predicateForSamples(withStart: distantPastHeight as Date, end: currentDate as Date)
        let weightType = HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.bodyMass)!
        
        // Get the single most recent height
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Query HealthKit for the last Height entry.
        let heightQuery = HKSampleQuery(sampleType: weightType, predicate: lastHeightPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
            
            if let queryError = error {
                completionHandler(nil, queryError)
                return
            }
            
            // Set the first HKQuantitySample in results as the most recent height.
            let lastWeight = results!.first as? HKQuantitySample
            
            if let weightInPounds = lastWeight?.quantity.doubleValue(for: HKUnit.pound()) {
                let rounded = round(10.0 * weightInPounds) / 10.0
                completionHandler("\(rounded)", nil)
            }


        }
        
        // Time to execute the query.
        self.healthKitStore.execute(heightQuery)
    }

}


