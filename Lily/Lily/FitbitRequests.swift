//
//  FitbitRequests.swift
//  Lily
//
//  Created by Tom Reinhart on 12/23/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
class FitbitRequests {

    
    let restClient = RestClient()

    
    // List of profile attributes that we would like to pull directly from the login response. 
    // sample login response can be found: in FitbitResponses Folder
    static var profileAttributes = ["age",
                             "avatar",
                             "averageDailySteps",
                             "country",
                             "dateOfBirth",
                             "displayName",
                             "fullName",
                             "gender",
                             "height",
                             "heightUnit",
                             "locale",
                             "startDayOfWeek",
                             "timezone",
                             "weight",
                             "weightUnit"]
    


    
    
    /**
     Get Weight Logs
     The Get Weight Logs API retrieves a list of all user's body weight log entries for a given day using units in the unit systems which corresponds to the Accept-Language header provided. Body weight log entries are available only to authorized user. Body weight log entries in response are sorted exactly the same as they are presented on the Fitbit website.
     
     Resource URL
     
     There are three acceptable formats for retrieving weight log data:
     
     GET https://api.fitbit.com/1/user/-/body/log/weight/date/[date].json
     
     GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[period].json
     
     GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[end-date].json
     
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     date	The date in the format yyyy-MM-dd.
     base-date	The end date when period is provided, in the format yyyy-MM-dd; range start date when a date range is provided.
     period	The date range period. One of 1d, 7d, 30d, 1w, 1m.
     end-date	Range end date when date range is provided. Note: The period must not be longer than 31 days.
 
     Example Response:
     {
     "weight":[
     {
     "bmi":23.57,
     "date":"2015-03-05",
     "logId":1330991999000,
     "time":"23:59:59",
     "weight":73,
     "source": "API"
     },
     {
     "bmi":22.57,
     "date":"2015-03-05",
     "logId":1330991999000,
     "time":"21:10:59",
     "weight":72.5,
     "source": "Aria"
     }
     ]
     }

     
     
    */
    // default date if no parameter is today
    // GET https://api.fitbit.com/1/user/-/body/log/weight/date/[date].json
    func getWeightOnDate(date: String = "today", completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/body/log/weight/date/\(date).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    //GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[period].json
    //     base-date	The end date when period is provided, in the format yyyy-MM-dd; range start date when a date range is provided.
    //     period       The date range period. One of 1d, 7d, 30d, 1w, 1m.
    func getWeightForPeriod(baseDate: String, period: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/body/log/weight/date/\(baseDate)/\(period).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    
    //     GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[end-date].json
    //     start-date	The end date when period is provided, in the format yyyy-MM-dd; range start date when a date range is provided.
    //      end-date	Range end date when date range is provided. Note: The period must not be longer than 31 days.
    func getWeightFromStartEndDates(startDate: String, endDate: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/body/log/weight/date/\(startDate)/\(endDate).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }        }
    }
    
    
    // POST https://api.fitbit.com/1/user/-/body/log/weight.json
    // POST Parameters
    //
    //    weight	required	Weight - in the format X.XX.
    //    date	required	Log entry date - in the format yyyy-MM-dd.
    //    time	optional	Time of the measurement - hours and minutes in the format HH:mm:ss, which is set to the last second of the day if time is not provided.
    func logWeight(weight: String, date: String? = "today", time: String? = nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        var parameters: Parameters = [
            "weight": weight,
            "date": date ?? "today"
        ]
        
        if time != nil {
            parameters.updateValue(time ?? "23:59:59", forKey: "time")
        }
        let url = "https://api.fitbit.com/1/user/-/body/log/weight.json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    /**
     Delete Weight Log
     The Delete Weight Log API deletes a user's body weight log entry with the given ID.
     
     Note: A successful request returns a 204 status code with an empty response body.
     
     Resource URL
     
     DELETE https://api.fitbit.com/1/user/[user-id]/body/log/weight/[body-weight-log-id].json
     
     */
    func deleteWeight(logId: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/body/log/weight/\(logId).json"
        restClient.deleteRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    func getDevices(completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/devices.json"
        restClient.getRequest(url: url) { json, error in
            var ids = [Int]()
            if let devices = json?.array {
                for device in devices {
                    if let id = device["id"].string {
                        print("ID: \(id)")
                        let idInt:Int? = Int(id)     // firstText is UITextField
                        ids.append(idInt!)
                    }
                }
            }
            completionHandler(json, error)
        }
    }
    
    
    
    /**
    Activity Logging
     POST https://api.fitbit.com/1/user/-/activities.json

     POST Parameters
     
     activityId	- optional/required
            This is the Activity ID of the activity, directory activity, or intensity level activity.
            If you pass directory activity id, Fitbit calculates and substitutes it with the corresponding
                intensity level activity id based on the specified distance and/or duration.
     activityName - optional/required	
            Custom activity name. Either activityId or activityName must be provided.
     
     manualCalories - optional/required
        Calories burned, specified manually. Required with activityName parameter, otherwise optional.
     
     startTime - required
            Activity start time. Hours and minutes in the format HH:mm:ss.
     
     durationMillis	- required	
            Duration in milliseconds.
     
     date - required
            Log entry date; in the format yyyy-MM-dd.
     
     distance - optional/required
            Distance; required for logging directory activity. In the format X.XX and in the selected distanceUnit or in the unit system that corresponds to the Accept-Language header provided.
     
     distanceUnit - optional	
            Distance measurement unit. Steps units are available only for "Walking" (activityId=90013) and "Running" (activityId=90009) directory activities and their intensity levels.

     {
     "activityId":12030,
     "activityName":"Running",
     "manualCalories":197,
     "distance":3.34,
     "durationMillis":1800000,
     "date":2016-12-29,
     "startTime":"12:20",
     }
     */
    // TODO figure out what's wrong with logActivity
    func logActivity(activityId: Int, activityName: String, manualCalories: Int,  durationMillis: Int, date: String, distance: Double, distanceUnit: String? = nil, startTime: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        
        let parameters: Parameters = [
            "activityId":activityId,
            "activityName":activityName,
            "manualCalories":manualCalories,
            "distance":distance,
            "durationMillis":durationMillis,
            "date":date,
            "startTime":startTime,
        ]
        let url = "https://api.fitbit.com/1/user/-/activities.json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    
    
    /**
     Get Activity Time Series https://dev.fitbit.com/docs/activity/#activity-time-series
     GET /1/user/[user-id]/[resource-path]/date/[date]/[period].json
     
     GET /1/user/[user-id]/[resource-path]/date/[base-date]/[end-date].json
     
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     resource-path	The resource path; see options in the "Resource Path Options" section below.
     base-date	The range start date, in the format yyyy-MM-dd or today.
     end-date	The end date of the range.
     date	The end date of the period specified in the format yyyy-MM-dd or today.
     period	The range for which data will be returned. Options are 1d, 7d, 30d, 1w, 1m, 3m, 6m, 1y
     Example Request
     GET https://api.fitbit.com/1/user/-/activities/steps/date/today/1m.json
    */
    

    func getActivityTimeSeriesFromStartEndDates(resourcePath: String, baseDate: String, endDate: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/[resource-path]/date/[date]/[period].json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    func getActivityTimeSeriesFromPeriod(resourcePath: String, date: String, period: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/\(resourcePath)/date/\(date)/\(period).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Get Alarms
     The Get Alarms endpoint returns a list of the set alarms connected to a user's account.
     
     Resource URL
     
     GET https://api.fitbit.com/1/user/-/devices/tracker/[tracker-id]/alarms.json

    */
    func getAlarms(trackerId: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/devices/tracker/\(trackerId)/alarms.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    /**
     Add Alarm
     The Add Alarm endpoint adds the alarm settings to a given ID for a given device.
     
     Resource URL
     
     POST https://api.fitbit.com/1/user/[user-id]/devices/tracker/[tracker-id]/alarms.json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     tracker-id	The ID of the tracker for which data is returned. The tracker-id value is found via the Get Devices endpoint.
     POST Parameters
     
     time       required	Time of day that the alarm vibrates with a UTC timezone offset, e.g. 07:15-08:00
     enabled	required	true or false. If false, alarm does not vibrate until enabled is set to true.
     recurring	required	true or false. If false, the alarm is a single event.
     weekDays	required	Comma separated list of days of the week on which the alarm vibrates, e.g. MONDAY,TUESDAY
 
     usage:         
     fbreqs.addAlarm(trackerId: trackerId, time: "13:30", recurring: true, weekDays: ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY"]) {json,error in {{stuff}} }

    */
    func addAlarm(trackerId: String, time: String, recurring: Bool, weekDays: [String], completionHandler: @escaping (JSON?, Error?) -> ()) {
        let days = weekDays.joined(separator: ",")  // "MONDAY, TUESDAY, FRIDAY"
        let utcOffset = Helpers.getOffset()

        
        let parameters: Parameters = [
            "time": "\(time)\(utcOffset)",
            "enabled": true,
            "recurring": true,
            "weekDays":days
        ]
        print("PARAMATERS FOR ADDING ALARM: \(parameters)")
        let url = "https://api.fitbit.com/1/user/-/devices/tracker/\(trackerId)/alarms.json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    
    /**
     Update Alarm
     The Update Alarm endpoint updates the alarm entry with a given ID for a given device. It also gets a response in the format requested.
     
     Resource URL
     
     POST https://api.fitbit.com/1/user/[user-id]/devices/tracker/[tracker-id]/alarms/[alarm-id].json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     tracker-id	The ID of the tracker whose alarms is managed. The tracker-id value is found via the Get Devices endpoint.
     alarm-id	The ID of the alarm to be updated. The alarm-id value is found in the response of the Get Alarms endpoint.
     
     POST Parameters
     
     time	required	Time of day that the alarm vibrates with a UTC timezone offset, e.g. 07:15-08:00
     enabled	required	true or false. If false, alarm does not vibrate until enabled is set to true.
     recurring	required	true or false. If false, the alarm is a single event.
     weekDays	required	Comma separated list of days of the week on which the alarm vibrates, e.g. MONDAY,TUESDAY
     snoozeLength	required	Minutes between alarms; integer value.
     snoozeCount	required	Maximum snooze count; integer value.
     label	optional	Label for the alarm; string value.
     vibe	optional	Vibe pattern; only one value for now - DEFAULT.

    */
    func updateAlarm(trackerId: String, alarmId: String, time: String, enabled: Bool, recurring: Bool, weekDays: [String], snoozeLength: Int,
                     snoozeCount: Int, label: String?=nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        let days = weekDays.joined(separator: ",")  // "MONDAY, TUESDAY, FRIDAY"
        let utcOffset = Helpers.getOffset()
        
        
        var parameters: Parameters = [
            "time": "\(time)\(utcOffset)",
            "enabled": enabled,
            "recurring": recurring,
            "weekDays":days,
            "snoozeLength":snoozeLength,
            "snoozeCount":snoozeCount
        ]
        
        if label != nil {
            parameters.updateValue(label ?? "", forKey: "label")
        }
        
        print("PARAMATERS FOR ADDING ALARM: \(parameters)")
        let url = "https://api.fitbit.com/1/user/-/devices/tracker/\(trackerId)/alarms/\(alarmId).json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            print("RESPONSE UPDATING ALARM: \(json)")
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    
    /**
     Delete Alarm
     The Delete Alarm API deletes the user's device alarm entry with the given ID for a given device.
     
     Resource URL
     
     DELETE https://api.fitbit.com/1/user/[user-id]/devices/tracker/[tracker-id]/alarms/[alarm-id].json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     tracker-id	The ID of the tracker whose alarms is managed. The tracker-id value is found via the Get Devices endpoint.
     alarm-id	The ID of the alarm that is updated. The alarm-id value is found via the Get Alarms endpoint.

    */
    func deleteAlarm(trackerId: String, alarmId: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/devices/tracker/\(trackerId)/alarms/\(alarmId).json"
        restClient.deleteRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    
    /**
     Get Water Logs
     The Get Water Logs endpoint retrieves a summary and list of a user's water log entries for a given day in the format requested using units in the unit system that corresponds to the Accept-Language header provided. Water log entries are available only to an authorized user. If you need to fetch only total amount of water consumed, you can use the Get Food endpoint. Water log entries in response are sorted exactly the same as they are presented on the Fitbit website.
     
     Resource URL
     
     GET https://api.fitbit.com/1/user/[user-id]/foods/log/water/date/[date].json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     date	The date of records to be returned. In the format yyyy-MM-dd.
     Example Request
     
     GET https://api.fitbit.com/1/user/-/foods/log/water/date/2015-09-01.json
 
    */
    func getWaterLogs(date: String = "today", completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        let url = "https://api.fitbit.com/1/user/-/foods/log/water/date/\(date).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Get Water Goal
     Resource URL
     
     GET https://api.fitbit.com/1/user/[user-id]/foods/log/water/goal.json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.

    */
    func getWaterGoal(completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/foods/log/water/goal.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Get Food or Water Time Series
     The Get Food or Water Time Series endpoint returns time series data in the specified range for a given resource in the format requested using units in the unit systems that corresponds to the Accept-Language header provided.
     
     Note: If you provide earlier dates in the request, the response will retrieve only data since the user's join date or the first log entry date for the requested collection.
     
     Resource URL
     
     There are two accepted formats for retrieving intraday data:
     
     1) GET https://api.fitbit.com/1/user/[user-id]/[resource-path]/date/[date]/[period].json
     
     api-version	The API version. Currently version 1.
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     resource-path	The resource path; see options in the "Resource Path Options" section below.
     date	The end date of the period specified in the format yyyy-MM-dd or today.
     period	The range for which data will be returned. Options are 1d, 7d, 30d, 1w, 1m, 3m, 6m, 1y
     
     
     2) GET https://api.fitbit.com/1/user/[user-id]/[resource-path]/date/[base-date]/[end-date].json
     
     api-version	The API version. Currently version 1.
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     resource-path	The resource path; see options in the "Resource Path Options" section below.
     base-date	The range start date, in the formatyyyy-MM-dd or today.
     end-date	The end date of the range.
     Resource Path Options
     
     foods/log/caloriesIn
     foods/log/water
     Example Request
     
     GET https://api.fitbit.com/1/user/-/foods/log/caloriesIn/date/2015-09-01/2015-09-05.json
     
    */
    
    func getWaterLogSeriesStartEndDates(baseDate: String = "today", endDate: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        // Options are 1d, 7d, 30d, 1w, 1m, 3m, 6m, 1y for period. default 1d
        let url = "https://api.fitbit.com/1/user/-/food/log/water/date/\(baseDate)/\(endDate).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    func getWaterLogSeriesPeriod(date: String = "today", period: String = "1d", completionHandler: @escaping (JSON?, Error?) -> ()) {
        // Options are 1d, 7d, 30d, 1w, 1m, 3m, 6m, 1y for period. default 1d
        let url = "https://api.fitbit.com/1/user/-/foods/log/water/date/\(date)/\(period).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }

    func getFoodLogSeriesStartEndDates(baseDate: String = "today", endDate: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        // Options are 1d, 7d, 30d, 1w, 1m, 3m, 6m, 1y for period. default 1d
        let url = "https://api.fitbit.com/1/user/-/food/log/caloriesIn/date/\(baseDate)/\(endDate).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    func getFoodLogSeriesPeriod(date: String = "today", period: String = "1d", completionHandler: @escaping (JSON?, Error?) -> ()) {
        // Options are 1d, 7d, 30d, 1w, 1m, 3m, 6m, 1y for period. default 1d
        let url = "https://api.fitbit.com/1/user/-/foods/log/caloriesIn/date/\(date)/\(period).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    
    /**
     Log Water
     This endpoint creates a log entry for water using units in the unit systems that corresponds to the Accept-Language header provided.
     
     Resource URL
     
     POST https://api.fitbit.com/1/user/[user-id]/foods/log/water.json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     Request Headers
     
     Accept-Language	optional	The measurement unit system to use for POST parameters and response values.
     POST Parameters
     
     amount	required	Amount consumed; in the format X.X and in the specified waterUnit or in the unit system that corresponds to the Accept-Language header provided.
     date	required	Log entry date; in the format yyyy-MM-dd.
     unit	optional	Water measurement unit. "ml", "fl oz", or "cup".

    */
    func logWater(date: String = "today", amount: String, unit: String? = nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
        // default fl oz
        var parameters: Parameters = [
            "amount": amount,
            "date": date,
        ]
        
        if unit != nil {
            parameters.updateValue(unit!, forKey: "unit")
            print("for some reason not nil")
        }
        
        let url = "https://api.fitbit.com/1/user/-/foods/log/water.json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Update Water Log
     Resource URL
     
     POST https://api.fitbit.com/1/user/[user-id]/foods/log/water/[water-log-id].json
     
     Request Headers
     
     Accept-Language	optional	The measurement unit system to use for POST parameters and response values.
     POST Parameters
     
     amount	required	Amount consumed; in the format X.X and in the specified waterUnit or in the unit system that corresponds to the Accept-Language header provided.
     unit	optional	Water measurement unit. "ml", "fl oz", or "cup".

    */
    func logWaterUpdate(logId: String, amount: String, unit: String? = nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
        // default fl oz
        var parameters: Parameters = [
            "amount": amount
        ]
        
        if unit != nil {
            parameters.updateValue(unit!, forKey: "unit")
            print("for some reason not nil")
        }
        
        let url = "https://api.fitbit.com/1/user/-/foods/log/water/\(logId).json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Delete Water Log
     The Delete Water Log endpoint deletes a user's water log entry with the given ID.
     
     Resource URL
     
     DELETE https://api.fitbit.com/1/user/[user-id]/foods/log/water/[water-log-id].json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     water-log-id	The id of the water log entry to be deleted.
     A successful request returns a 204 status code with an empty response body.

    */
    func deleteWaterLog(logId: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/foods/log/water/\(logId).json"
        restClient.deleteRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    
    
    /**
     Get Friends
     The Get Friends endpoint returns data of a user's friends in the format requested using units in the unit system which corresponds to the Accept-Language header provided.
     
     Privacy Settings
     
     The Fitbit privacy setting is a two-tiered mechanism, where the first level setting, Friends (Friends or Anyone), determines the access to a user's list of friends.
     
     The second level setting determines from the list of friends, access to the following profile (Personal Information) fields:
     
     About Me (Friends or Anyone)
     Age and Height (Friends or Anyone)
     Location (Friends or Anyone)
     My Body (Friends or Anyone)
     Resource URL
     
     GET https://api.fitbit.com/1/user/[user-id]/friends.json
     
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     Examples of Requests
     
     Here are two accepted formats for retrieving user's friends data:
     
     GET https://api.fitbit.com/1/user/28H22H/friends.json
     
     GET https://api.fitbit.com/1/user/-/friends.json
     

    */
    func getFriends(completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/friends.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    
    /**
     Get Friends Leaderboard
     The Get Friends Leaderboard endpoint gets the user's friends leaderboard in the format requested using units in the unit system which corresponds to the Accept-Language header provided.
     
     Authorized user (self) is also included in the response. Leaderboard has last seven (7) days worth of data (including data from the previous six days plus today's data in real time).
     
     Privacy Settings
     
     There are two privacy settings to consider for the response data:
     
     The Hide me from rankings privacy setting allows a user to be included to Friends leaderboard whether he hides himself on his profile settings or not.
     
     The following privacy permissions grant granular access to any listed user's respective profile fields:
     
     About Me (Friends or Anyone)
     Age and height (Friends or Anyone)
     Location (Friends or Anyone)
     My Body (Friends or Anyone)
     The response includes the correct values for accessible fields and empty values: empty string, "NA" (empty gender), 0 (empty height), default avatar etc., while some values are revealed to authorized user only, such as:
     
     About Me - controls aboutMe, gender, avatar
     Age and height - controls dateOfBirth, height
     Location - controls country, city, state, timezone, offsetFromUTCMillis
     My Body - controls weight
     Resource URL
     
     GET https://api.fitbit.com/1/user/[user-id]/friends/leaderboard.json
    */
    func getFriendsLeaderboard(completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/friends/leaderboard.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    
    /**
     Invitations
     Invite Friend
     The Invite Friend endpoint creates an invitation to become friends with the authorized user. A successful request returns a 201 status code and an empty response body.
     
     If the invitedUserEmail value is provided, the standard friendship invitation email is sent to the specified recipient to be accepted or rejected later. If the invitedUserId is provided, the invitation is created silently and can only be fetched through the Get Invitations endpoint. Both invitation types can be accepted or rejected via the Accept Invitation endpoint.
     
     WARNING
     
     Warning: Be careful when using the Invite Friend endpoint and, as always, adhere to the Terms of Service. Though Fitbit has organic limits on allowed number of invitations, your application's workflow must not allow users to send bulk invitations to users. Doing so could be considered SPAM.
     
     Resource URL
     
     POST https://api.fitbit.com/1/user/-/friends/invitations.json
     
     POST Parameters
     
     invitedUserEmail	required/optional	Email of the user to invite. Does not need to be a Fitbit member. Either invitedUserEmail or invitedUserId is required.
     invitedUserId	required/optional	Encoded ID of the invited user. Either invitedUserEmail or invitedUserId is required.
    */
    
    func inviteFriends(invitedUserEmail: String? = nil, invitedUserId: String? = nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        if (invitedUserEmail == nil && invitedUserId == nil) || (invitedUserEmail != nil && invitedUserId != nil ) {
            let err = NSError(domain: "InvitedUserParameterError", code: 401)
            completionHandler(nil, err)
        }
        
        var parameters: Parameters = [:]
        
        if invitedUserEmail != nil {
            parameters.updateValue(invitedUserEmail!, forKey: "invitedUserEmail")
        } else {
            parameters.updateValue(invitedUserId!, forKey: "invitedUserId")
        }
        let url = "https://api.fitbit.com/1/user/-/friends/invitations.json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Get Friend Invitations
     The Get Friend Invitations endpoint returns a list of invitations to become friends with a user in the format requested.
     
     Resource URL
     
     GET https://api.fitbit.com/1/user/<user-id>/friends/invitations.json
     
    */
    func getFriendInvitations(completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/friends/invitations.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    
    /**
     Respond to Friend Invitation
     The Respond to Friend Invitation endpoint accepts or rejects an invitation to become friends with inviting user.
     
     Resource URL
     
     POST https://api.fitbit.com/1/user/-/friends/invitations/[from-user-id].json
     
     from-user-id	Encoded ID of user from which to accept or reject invitation.
     POST Parameters
     
     accept	required	Accept or reject invitation. 'true' or 'false'.

    */
    func respondToFriendInvite(accept: Bool, fromUserId: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let parameters: Parameters = [
            "accept":accept
        ]
        let url = "https://api.fitbit.com/1/user/-/friends/invitations/\(fromUserId).json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Badges
     Get Badges
     The Get Badges endpoint retrieves user's badges in the format requested. Response includes all badges for the user as seen on the Fitbit website badge locker (both activity and weight related). Fitbit returns weight and distance badges based on the user's unit profile preference as on the website.
     
     Privacy Setting
     
     There are two privacy settings to consider for the response data:
     
     The My Achievements (Friends or Anyone) privacy permission grants access to other user's resource.
     The My Body (Friends or Anyone) privacy permission reveals weight badge data in response.
     Resource URL
     
     GET /1/user/[user-id]/badges.json
     
     from-user-id	Encoded ID of user from which to accept or reject invitation.
     Request Headers
     
     Accept-Language	optional	The measurement unit system to use for response values.

    */
    func getBadges(completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/badges.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    
    /**
     Heart Rate Time Series
     Get Heart Rate Time Series
     The Get Heart Rate Time Series endpoint returns time series data in the specified range for a given resource in the format requested using units in the unit systems that corresponds to the Accept-Language header provided.
     
     If you specify earlier dates in the request, the response will retrieve only data since the user's join date or the first log entry date for the requested collection.
     
     Resource URL
     
     There are two acceptable formats for retrieving time series data:
     
     GET https://api.fitbit.com/1/user/-/activities/heart/date/[date]/[period].json
     
     GET https://api.fitbit.com/1/user/-/activities/heart/date/[base-date]/[end-date].json
     
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     base-date	The range start date, in the format yyyy-MM-dd or today.
     end-date	The end date of the range.
     date	The end date of the period specified in the format yyyy-MM-dd or today.
     period	The range for which data will be returned. Options are 1d, 7d, 30d, 1w, 1m.
     Example Request
     
     https://api.fitbit.com/1/user/-/activities/heart/date/today/1d.json
     
    */
    
    func getHeartRateTimeSeriesFromStartEndDates(baseDate: String, endDate: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(baseDate)/\(endDate).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    func getHeartRateTimeSeriesFromPeriod(date: String = "today", period: String = "1d", completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(date)/\(period).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Get Heart Rate Intraday Time Series
     Access to the Intraday Time Series for personal use (accessing your own data) is available through the "Personal" App Type.
     
     Access to the Intraday Time Series for all other uses is currently granted on a case-by-case basis. Applications must demonstrate necessity to create a great user experience. Fitbit is very supportive of non-profit research and personal projects. Commercial applications require thorough review and are subject to additional requirements. Only select applications are granted access and Fitbit reserves the right to limit this access. To request access, contact private support.
     
     The Get Heart Rate Intraday Time Series endpoint returns the intraday time series for a given resource in the format requested. If your application has the appropriate access, your calls to a time series endpoint for a specific day (by using start and end dates on the same day or a period of 1d), the response will include extended intraday values with a one-minute detail level for that day. Unlike other time series calls that allow fetching data of other users, intraday data is available only for and to the authorized user.
     
     Resource URLs
     
     There are four acceptable formats for retrieving time series data:
     
     GET https://api.fitbit.com/1/user/-/activities/heart/date/[date]/[end-date]/[detail-level].json
     
     GET https://api.fitbit.com/1/user/-/activities/heart/date/[date]/[end-date]/[detail-level]/time/[start-time]/[end-time].json
     
     GET https://api.fitbit.com/1/user/-/activities/heart/date/[date]/1d/[detail-level].json
     
     GET https://api.fitbit.com/1/user/-/activities/heart/date/[date]/1d/[detail-level]/time/[start-time]/[end-time].json
     
     date	The date, in the format yyyy-MM-dd or today.
     detail-level	Number of data points to include. Either 1sec or 1min. Optional.
     start-time	The start of the period, in the format HH:mm. Optional.
     end-time	The end of the period, in the format HH:mm. Optional.
     Example Request
     
     GET https://api.fitbit.com/1/user/-/activities/heart/date/today/1d/1sec/time/00:00/00:01.json
     

     */
    func getHeartRateIntraTimeSeriesFromStartEndDates(baseDate: String, endDate: String, detailLevel: String = "1min",
        startTime: String? = nil, endTime: String? = nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        var url = ""
        if startTime == nil {
            url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(baseDate)/\(endDate)/\(detailLevel).json"
        } else {
            url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(baseDate)/\(endDate)/\(detailLevel)/time/\(startTime!)/\(endTime!).json"
        }
        
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    func getHeartRateIntraTimeSeriesFromPeriod(date: String = "today", detailLevel: String = "1sec",
        startTime: String? = nil, endTime: String? = nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        var url = ""
        if startTime == nil {
            url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(date)/1d/\(detailLevel).json"
        } else {
            url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(date)/1d/\(detailLevel)/time/\(startTime!)/\(endTime!).json"
            
            print(url)

        }
        
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Get Sleep Logs
     The Get Sleep Logs endpoint returns a summary and list of a user's sleep log entries as well as minute by minute sleep entry data for a given day in the format requested. The endpoint response includes summary for all sleep log entries for the given day (including naps.) If you need to fetch data only for the user's main sleep event, you can send the request with isMainSleep=true or use a Time Series call.
     
     The relationship between sleep log entry properties is expressed with the following equation:
     
     timeInBed = minutesToFallAsleep + minutesAsleep + minutesAwake + minutesAfterWakeup
     
     Resource URL
     
     GET https://api.fitbit.com/1/user/[user-id]/sleep/date/[date].json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     date	The date of records to be returned. In the format yyyy-MM-dd.
     Example Request
     
     GET https://api.fitbit.com/1/user/28H22H/sleep/date/2014-09-01.json
    */
    func getSleepLogs(date: String = "today", completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/sleep/date/\(date).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
   
    /**
     Get Sleep Goal
     The Get Sleep Goal endpoint returns a user's current sleep goal using unit in the unit system that corresponds to the Accept-Language header provided in the format requested.
     
     Access Type: Read
     
     Rate Limited: Yes
     
     Resource URL
     
     GET https://api.fitbit.com/<api-version>/user/-/sleep/goal.json
     
     api-version	The API version, which is currently 1.
     Example
     
     GET https://api.fitbit.com/1/user/-/sleep/goal.json
     

    */
    func getSleepGoal(completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/sleep/goal.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    
    /**
     Update Sleep Goal
     The Update Sleep Goal endpoint creates or updates a user's sleep goal and get a response in the in the format requested.
     
     Access Type: Read & Write
     
     Resource URL
     
     POST https://api.fitbit.com/<api-version>/user/-/sleep/goal.json
     
     api-version	The API version, which is currently 1.
     Example
     
     POST https://api.fitbit.com/1/user/-/sleep/goal.json
     
     POST Parameters
     
     minDuration	required	The target sleep duration is in minutes.

    */
    func updateSleepGoal(minDuration: String = "480", completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        let parameters: Parameters = [
            "minDuration":minDuration
        ]

        let url = "https://api.fitbit.com/1/user/-/sleep/goal.json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    /**
     Sleep Time Series
     Get Sleep Time Series
     The Get Sleep Time Series endpoint returns time series data in the specified range for a given resource in the format requested using units in the unit system that corresponds to the Accept-Language header provided.
     
     Note: Even if you provide earlier dates in the request, the response retrieves only data since the user's join date or the first log entry date for the requested collection.
     
     Resource URL
     
     There are two acceptable formats for retrieving intraday data:
     
     1) GET https://api.fitbit.com/1/user/[user-id]/[resource-path]/date/[date]/[period].json
     
     api-version	The API version. Currently version 1.
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     resource-path	The resource path; see the Resource Path Options below for a list of options.
     date	The end date of the period specified in the format yyyy-MM-dd or today.
     period	The range for which data will be returned. Options are 1d, 7d, 30d, 1w, 1m, 3m, 6m, 1y, or max.
     
     
     2) GET https://api.fitbit.com/1/user/[user-id]/[resource-path]/date/[base-date]/[end-date].json
     
     api-version	The API version. Currently version 1.
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     resource-path	The resource path; see the Resource Path Options below for a list of options.
     base-date	The range start date, in the format yyyy-MM-dd or today.
     end-date	The end date of the range.
     Resource Path Options
     
     sleep/startTime
     sleep/timeInBed
     sleep/minutesAsleep
     sleep/awakeningsCount
     sleep/minutesAwake
     sleep/minutesToFallAsleep
     sleep/minutesAfterWakeup
     sleep/efficiency
     Example Requests
     
     1) GET https://api.fitbit.com/1/user/-/sleep/minutesAsleep/date/today/2014-09-01.json
     
     2) GET https://api.fitbit.com/1/user/28H22H/sleep/minutesAsleep/date/2014-09-01/today.json
     

    */
    
    static var sleepResourcePaths = [
        "sleep/startTime",
        "sleep/timeInBed",
        "sleep/minutesAsleep",
        "sleep/awakeningsCount",
        "sleep/minutesAwake",
        "sleep/minutesToFallAsleep",
        "sleep/minutesAfterWakeup",
        "sleep/efficiency"
    ]
    // example: https://api.fitbit.com/1/user/-/sleep/minutesAsleep/date/today/2014-09-01.json
    func getSleepTimeSeriesFromPeriod(resourcePath: String, date: String, period: String,
                                      completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        if !FitbitRequests.sleepResourcePaths.contains(resourcePath) {
            let error = NSError(domain: "InvalidResourcePathError", code: 401)
            completionHandler(nil, error)
            return

        }
        
        let url = "https://api.fitbit.com/1/user/-/\(resourcePath)/date/\(date)/\(period).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    // example: https://api.fitbit.com/1/user/28H22H/sleep/minutesAsleep/date/2014-09-01/today.json
    func getSleepTimeSeriesFromStartEndDates(resourcePath: String, startDate: String, endDate: String,
                                             completionHandler: @escaping (JSON?, Error?) -> ()) {
        if !FitbitRequests.sleepResourcePaths.contains(resourcePath) {
            let error = NSError(domain: "InvalidResourcePathError", code: 401)
            completionHandler(nil, error)
            return
            
        }
        
        let url = "https://api.fitbit.com/1/user/-/\(resourcePath)/date/\(startDate)/\(endDate).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
        
    }
    
    /**
     Log Sleep
     The Log Sleep endpoint creates a log entry for a sleep event and returns a response in the format requested. Keep in mind that it is NOT possible to create overlapping log entries or entries for time periods that DO NOT originate from a tracker. Sleep log entries appear on website's sleep tracker interface according to the date on which the sleep event ends.
     
     Resource URL
     
     POST https://api.fitbit.com/1/user/[user-id]/sleep.json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     POST Parameters
     
     startTime	required	Start time; hours and minutes in the format HH:mm.
     duration	required	Duration in milliseconds.
     date	required	Log entry date in the format yyyy-MM-dd.

    */
    func logSleep(startTime: String, duration: String, date: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let parameters: Parameters = [
            "startTime": startTime,
            "duration": duration,
            "date": date
            ]
        
        
        let url = "https://api.fitbit.com/1/user/-/sleep.json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    /**
     Delete Sleep Log
     The Delete Sleep Log endpoint deletes a user's sleep log entry with the given ID.
     
     Resource URL
     
     DELETE https://api.fitbit.com/1/user/[user-id]/sleep/[log-id].json
     
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     log-id	ID of the sleep log to be deleted.

    */
    func deleteSleepLog(logId: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/sleep/\(logId).json"
        restClient.deleteRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
}
