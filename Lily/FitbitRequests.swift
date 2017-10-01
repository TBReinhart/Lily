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

    
    
    // sample login response can be found: in FitbitResponses Folder
    /// List of profile attributes that we would like to pull directly from the login response.
    static var profileAttributes = ["age",
                             "avatar",
                             "averageDailySteps",
                             "country",
                             "dateOfBirth",
                             "displayName",
                             "encodedId",
                             "fullName",
                             "gender",
                             "height",
                             "heightUnit",
                             "locale", // note about locale: units are set to en_US on the profile, but the API returns metric by default unless you set the Accept-Language to "en_US" in the header.
                             "startDayOfWeek",
                             "timezone",
                             "weight",
                             "weightUnit"]
    


    
    
    /**
     ## Get Weight Logs ##
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
     // default date if no parameter is today
     // GET https://api.fitbit.com/1/user/-/body/log/weight/date/[date].json
    */

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
    /**
     ## Get Weight Logs ##
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
     //GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[period].json
     //     base-date	The end date when period is provided, in the format yyyy-MM-dd; range start date when a date range is provided.
     //     period       The date range period. One of 1d, 7d, 30d, 1w, 1m.
    */
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
    

    /**
    ## Get Weight Logs ##
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
     
     //     GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[end-date].json
     //     start-date	The end date when period is provided, in the format yyyy-MM-dd; range start date when a date range is provided.
     //      end-date	Range end date when date range is provided. Note: The period must not be longer than 31 days.
     */
    func getWeightFromStartEndDates(startDate: String, endDate: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/body/log/weight/date/\(startDate)/\(endDate).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }
    }
    
    
    /**
     ## Log Weight ##
     The Log Weight API creates log entry for a body weight using units in the unit systems that corresponds to the Accept-Language header provided and get a response in the format requested.
     
     Note: The returned Weight Log IDs are unique to the user, but not globally unique.
     
     Resource URL
     
     POST https://api.fitbit.com/1/user/[user-id]/body/log/weight.json
     
     user-id	The encoded ID of the user. Use "-" for current logged-in user.
     POST Parameters
     
     weight	required	Weight - in the format X.XX.
     date	required	Log entry date - in the format yyyy-MM-dd.
     time	optional	Time of the measurement - hours and minutes in the format HH:mm:ss, which is set to the last second of the day if time is not provided.
     Request Headers
     
     Accept-Language	optional	The measurement unit system to use for response values.

    */
    func logWeight(weight: String, date: String, time: String? = nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        var parameters: Parameters = [
            "weight": weight,
            "date": date
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
     ## Delete Weight Log ##
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
    /**
    ## Get Devices ##
     The Get Device endpoint returns a list of the Fitbit devices connected to a user's account.
     
     Knowing when a Fitbit device last synced with the Fitbit server is useful when diagnosing reports that the Fitbit app is showing different values from what the Fitbit Web API returns. Fitbit's own apps use the same Web API available to third-party developers. However, when an active Bluetooth connection is available, Fitbit's apps will show the summary values displayed on the device. Often, this data has not yet synced with Fitbit's servers. Third-party applications can check when a Fitbit device last synced with Fitbit's servers using this endpoint. Fitbit users can check when their device last synced with Fitbit's servers by following these instructions.
     
     Resource URL
     
     GET https://api.fitbit.com/1/user/-/devices.json
     

    */
    func getDevices(completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/devices.json"
        restClient.getRequest(url: url) { json, error in
            var ids = [Int]()
            if let devices = json?.array {
                for device in devices {
                    if let id = device["id"].string {
                        let idInt:Int? = Int(id)     // firstText is UITextField
                        ids.append(idInt!)
                    }
                }
            }
            completionHandler(json, error)
        }
    }
    
    
    
    /**
     ## Activity Logging ##
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
     ## Get Activity Time Series  ##
     https://dev.fitbit.com/docs/activity/#activity-time-series
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

    //
    /**
     ## Get Activity Time Series  ##
     GET https://api.fitbit.com/1/user/[user-id]/activities/date/[date].json
     
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     resource-path	The resource path; see options in the "Resource Path Options" section below.
     base-date	The range start date, in the format yyyy-MM-dd or today.
     end-date	The end date of the range.
     date	The end date of the period specified in the format yyyy-MM-dd or today.
     period	The range for which data will be returned. Options are 1d, 7d, 30d, 1w, 1m, 3m, 6m, 1y
     Example Request
     */
    func getDailyActivity(date: String = "today", completionHandler: @escaping (Activity, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/activities/date/\(date).json"
        restClient.getRequest(url: url) { json, error in
            let activity = Activity()
            activity.dateString = date
            if error != nil {
                completionHandler(activity, error)
            } else {
                if let summary = json?["summary"] {
                    let sedentaryMinutes = summary["sedentaryMinutes"].intValue
                    let lightlyActiveMinutes = summary["lightlyActiveMinutes"].intValue
                    let fairlyActiveMinutes = summary["fairlyActiveMinutes"].intValue
                    let veryActiveMinutes = summary["veryActiveMinutes"].intValue

                    activity.sedentaryMinutes = sedentaryMinutes
                    activity.lightlyActiveMinutes = lightlyActiveMinutes
                    activity.fairlyActiveMinutes = fairlyActiveMinutes
                    activity.veryActiveMinutes = veryActiveMinutes
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateObj = dateFormatter.date(from: date)
                    
                    let weekDay = Helpers.getWeekDayFromDate(date: dateObj ?? Date())
                    let longDate = Helpers.getLongDate(date: dateObj ?? Date())

                    activity.dayOfWeek = weekDay
                    activity.longDate = longDate

                }
                completionHandler(activity, nil)
            }
        }
    }

    
    /**
     ## Get Activity Time Series  ##
     https://dev.fitbit.com/docs/activity/#activity-time-series
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
    func getActivityTimeSeriesFromPeriod(resourcePath: String, date: String, period: String, completionHandler: @escaping ([Activity], Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/activities/\(resourcePath)/date/\(date)/\(period).json"
        var activities = [Activity]()
        
        
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(activities, error)
            } else {
                let resourcePath = "activities-\(resourcePath)"
                if let datas = json?[resourcePath] {
                    for data in datas {
                        let activity = Activity()
                        let dateTime = data.1["dateTime"].stringValue
                        let value = data.1["value"].stringValue
                        
                        let d = Helpers.getDateFromyyyyMMdd(dateString: dateTime)
                        let dayOfWeek = Helpers.getWeekDayFromDate(date: d)
                        activity.dayOfWeek = dayOfWeek
                        switch resourcePath {
                        case "activities-minutesSedentary":
                            activity.sedentaryMinutes = Int(value) ?? 0
                        case "activities-minutesLightlyActive":
                            activity.lightlyActiveMinutes = Int(value) ?? 0
                        case "activities-minutesFairlyActive":
                            activity.fairlyActiveMinutes = Int(value) ?? 0
                        case "activities-minutesVeryActive":
                            activity.veryActiveMinutes = Int(value) ?? 0
                        default:
                            activity.sedentaryMinutes = 0
                        }
                        
                        activities.append(activity)
                    }
                }
                completionHandler(activities, nil)
            }
        }
    }
    
    /**
    ## Get Alarms ##
     The Get Alarms endpoint returns a list of the set alarms connected to a user's account.
     
     Resource URL
     
     GET https://api.fitbit.com/1/user/[user-id]/devices/tracker/[tracker-id]/alarms.json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     tracker-id	The ID of the tracker for which data is returned. The tracker-id value is found via the Get Devices endpoint.


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
     ## Add Alarm ##
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
     ## Update Alarm ##
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
        
        let url = "https://api.fitbit.com/1/user/-/devices/tracker/\(trackerId)/alarms/\(alarmId).json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    
    /**
     ## Delete Alarm ##
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
     ## Get Water Logs ##
     The Get Water Logs endpoint retrieves a summary and list of a user's water log entries for a given day in the format requested using units in the unit system that corresponds to the Accept-Language header provided. Water log entries are available only to an authorized user. If you need to fetch only total amount of water consumed, you can use the Get Food endpoint. Water log entries in response are sorted exactly the same as they are presented on the Fitbit website.
     
     Resource URL
     
     GET https://api.fitbit.com/1/user/[user-id]/foods/log/water/date/[date].json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.
     date	The date of records to be returned. In the format yyyy-MM-dd.
     Example Request
     
     GET https://api.fitbit.com/1/user/-/foods/log/water/date/2015-09-01.json
 
    */
    func getWaterLogs(date: String = "today", completionHandler: @escaping (Water?, Error?) -> ()) {
        let water = Water()
        let url = "https://api.fitbit.com/1/user/-/foods/log/water/date/\(date).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                let waterInMilli = json?["summary"]["water"].doubleValue
                let cupsConsumed = Helpers.millilitersToOz(milli: waterInMilli ?? 0) * 0.125
                let cupsRounded = round(10.0 * cupsConsumed) / 10.0
                water.cupsConsumed = cupsRounded
                water.dateString = date
                completionHandler(water, nil)
            }
        }
    }
    
    
    func getWaterLastWeek(date: String = "today", completionHandler: @escaping ([Water]?, Error?) -> ()) {
        var weekWaterObjects = [Water]()
        self.getWaterLogSeriesPeriod(date:date, period: "7d") { json, error in
            
            if json != nil {
                if let waters = json?["foods-log-water"] {
                    for w in waters {
                        let dateTime = w.1["dateTime"].string
                        let waterInMilli = w.1["value"].doubleValue
                        let cupsConsumed = Helpers.millilitersToOz(milli: waterInMilli) * 0.125
                        let cupsRounded = round(10.0 * cupsConsumed) / 10.0

                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let date = dateFormatter.date(from: dateTime!)
                        let weekDay = Helpers.getWeekDayFromDate(date: (date ?? nil)!)
                        let thisWater = Water()
                        thisWater.cupsConsumed = cupsRounded
                        thisWater.dayOfWeek = weekDay
                        
                        let calendar = Calendar.autoupdatingCurrent
                        let components = calendar.dateComponents([.month, .day], from: date ?? Date())
                        let month = components.month
                        let day = components.day
                        thisWater.dateString = "\(month ?? 1)/\(day ?? 1)"
                        weekWaterObjects.append(thisWater)

                    }
                }
                completionHandler(weekWaterObjects,nil)
            }

        }

    }
    
    /**
     ## Get Water Goal ##
     Resource URL
     
     GET https://api.fitbit.com/1/user/[user-id]/foods/log/water/goal.json
     
     user-id	The ID of the user. Use "-" (dash) for current logged-in user.

    */
    func getWaterGoal(completionHandler: @escaping (String?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/foods/log/water/goal.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json?["goal"]["minDuration"].string,nil)
            }
        }
    }
    
    /**
     ## Get Food or Water Time Series ##
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
    /**
     ## Get Food or Water Time Series ##
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
    /**
     ## Get Food or Water Time Series ##
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
    /**
     ## Get Food or Water Time Series ##
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
     ## Log Water ##
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
     ## Update Water Log ##
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
     ## Delete Water Log ##
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
     ## Get Friends ##
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
    ## Get Friends Leaderboard ##
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
     ## Invitations ##
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
     ## Get Friend Invitations ##
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
     ## Respond to Friend Invitation ##
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
      ## Get Badges ##
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
      ## Heart Rate Time Series ##
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
    /*
    ## Heart Rate Time Series ##
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
    func getHeartRateTimeSeriesFromPeriod(date: String = "today", period: String = "1d", completionHandler: @escaping ([HeartRate]?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(date)/\(period).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                var heartRateList = [HeartRate]()
                
                if json != nil {
                    if let heartRates = json?["activities-heart"] {
                        for hr in heartRates {
                            let heartRate = HeartRate()
                            let restingHeartRate = hr.1["value"]["restingHeartRate"].intValue
                            let hrZones = hr.1["value"]["heartRateZones"]
                            let dateString = hr.1["dateTime"].stringValue
                            let date = Helpers.getDateFromyyyyMMdd(dateString: dateString)
                            let dayOfWeek = Helpers.getWeekDayFromDate(date: date)


                            heartRate.dayOfWeek = dayOfWeek

                            var highestMax = 0
                            for hrZone in hrZones {
                                let minutes = hrZone.1["minutes"].intValue
                                let max = hrZone.1["max"].intValue
                                if minutes > 0 && max > highestMax {
                                    highestMax = max
                                }
                            }
                            heartRate.maximumBPM = highestMax
                            heartRate.averageBPM = restingHeartRate
                            heartRate.restingHeartRate = restingHeartRate
                            heartRateList.append(heartRate)
                        }
                    }
                }
                completionHandler(heartRateList, nil)
            }
        }
    }
    
    /**
     ## Heart Rate Time Series ##
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
    func getHeartRateTimeSeriesFrom1DayPeriod(date: String = "today", period: String = "1d", completionHandler: @escaping (HeartRate?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(date)/\(period).json"
        print(url)
        let hr = HeartRate()
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                if json != nil {
                    let restingHeartRate = json?["activities-heart"][0]["value"]["restingHeartRate"].intValue
                    let dateString = json?["activities-heart"][0]["value"]["dateTime"].stringValue
                    let date = Helpers.getDateFromyyyyMMdd(dateString: dateString!)
                    let dayOfWeek = Helpers.getWeekDayFromDate(date: date)
                    hr.restingHeartRate = restingHeartRate ?? 0
                    var highestMax = 0
                    if let hrZones = json?["activities-heart"][0]["value"]["heartRateZones"] {
                        for hrZone in hrZones {
                            let minutes = hrZone.1["minutes"].intValue
                            let max = hrZone.1["max"].intValue
                            if minutes > 0 && max > highestMax {
                                highestMax = max
                            }
                        }
                    }
                    hr.dayOfWeek = dayOfWeek
                    hr.maximumBPM = highestMax
                    hr.averageBPM = restingHeartRate ?? 0
                    print(hr.restingHeartRate)
                }
                
                completionHandler(hr, nil)
                
            }
        }
    }
    
    /**
     ## Get Heart Rate Intraday Time Series ##
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
    /**
     ## Get Heart Rate Intraday Time Series ##
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
    func getHeartRateIntraTimeSeriesFromPeriod(date: String = "today", detailLevel: String = "1sec",
        startTime: String? = nil, endTime: String? = nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
        
        var url = ""
        if startTime == nil {
            url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(date)/1d/\(detailLevel).json"
        } else {
            url = "https://api.fitbit.com/1/user/-/activities/heart/date/\(date)/1d/\(detailLevel)/time/\(startTime!)/\(endTime!).json"

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
     ## Get Sleep Logs ##
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
    func getSleepLogs(date: String = "today", completionHandler: @escaping (Sleep?, Error?) -> ()) {
        let sleepObject = Sleep()
        let url = "https://api.fitbit.com/1/user/-/sleep/date/\(date).json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(sleepObject, error)
            } else {
                // minuteData can be 1 ("asleep"), 2 ("awake"), or 3 ("really awake").
                // Can use "restlessCount", "awakeDuration", "efficiency", "awakeCount", "timeInBed"
                let totalMinutesAsleep = json?["summary"]["totalMinutesAsleep"].int
                sleepObject.totalMinutesAsleep = totalMinutesAsleep ?? 0
                
                if totalMinutesAsleep != nil {
                    let hoursMinutes = Helpers.minutesToHoursMinutes(minutes: totalMinutesAsleep!)
                    let hours = hoursMinutes.0
                    let minutes = hoursMinutes.1
                    let sleepTime = "\(hours)h \(minutes)m"
                    sleepObject.sleepLabel = sleepTime
                    let sleepTimeRounded = round(10.0 * Double(totalMinutesAsleep ?? 0)/60) / 10.0
                    sleepObject.sleepTimeRounded = sleepTimeRounded
                    Helpers.postDailyLogToFirebase(key: "sleepTime", value: sleepObject.sleepLabel)
                } else {
                    sleepObject.sleepLabel = "0h 0m"
                    Helpers.postDailyLogToFirebase(key: "sleepTime", value: "0h 0m")
                }
                let dateString = (json?["sleep"][0]["dateOfSleep"].string) ?? "1970-01-01"
                let comps = dateString.components(separatedBy: "-")

                var dateComps = DateComponents()
                dateComps.year = Int(comps[0])
                dateComps.month = Int(comps[1])
                dateComps.day = Int(comps[2])
                let sleepDate = Calendar.current.date(from: dateComps)!
                

                sleepObject.dateLong = Helpers.getLongDate(date: sleepDate)
                
                
                sleepObject.efficiency = (json?["sleep"][0]["efficiency"].int) ?? 0
                sleepObject.awakeCount = (json?["sleep"][0]["awakeCount"].int) ?? 0
                sleepObject.awakeDuration = (json?["sleep"][0]["awakeDuration"].int) ?? 0
                sleepObject.restlessCount = (json?["sleep"][0]["restlessCount"].int) ?? 0
                sleepObject.restlessDuration = (json?["sleep"][0]["restlessDuration"].int) ?? 0
                completionHandler(sleepObject,nil)

            }
        }
    }


    
    func getSleepLastWeek(date: String = "today", completionHandler: @escaping ([Sleep]?, Error?) -> ()) {
        var weekSleepObjects = [Sleep]()

        self.getSleepTimeSeriesFromPeriod(resourcePath: "sleep/minutesAsleep", date: date, period: "7d") { json, error in
            
            if json != nil {
                if let sleeps = json?["sleep-minutesAsleep"] {
                    for s in sleeps {
                        let dateTime = s.1["dateTime"].string
                        let minutes = s.1["value"].doubleValue
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let date = dateFormatter.date(from: dateTime!)
                        
                        let weekDay = Helpers.getWeekDayFromDate(date: (date ?? nil)!)
                        let sleepTime = round(10.0 * minutes/60) / 10.0
                        let thisSleep = Sleep()
                        thisSleep.sleepTimeRounded = sleepTime
                        thisSleep.dayOfWeek = weekDay
                        
                        let calendar = Calendar.autoupdatingCurrent
                        let components = calendar.dateComponents([.month, .day], from: date ?? Date())
                        let month = components.month
                        let day = components.day
                        thisSleep.shortDateString = "\(month ?? 1)/\(day ?? 1)"
                        weekSleepObjects.append(thisSleep)
                        

                    }
                }
                completionHandler(weekSleepObjects,nil)

            }
        }
        
    }

    /**
     ## Get Sleep Goal ##
     The Get Sleep Goal endpoint returns a user's current sleep goal using unit in the unit system that corresponds to the Accept-Language header provided in the format requested.
     
     Access Type: Read
     
     Rate Limited: Yes
     
     Resource URL
     
     GET https://api.fitbit.com/<api-version>/user/-/sleep/goal.json
     
     api-version	The API version, which is currently 1.
     Example
     
     GET https://api.fitbit.com/1/user/-/sleep/goal.json
     

    */
    func getSleepGoal(completionHandler: @escaping (String?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/sleep/goal.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                
                completionHandler(json?["goal"]["minDuration"].string,nil)
            }
        }
    }
    
    /**
     ## Update Sleep Goal ##
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

    /// sleep resource paths
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
    /**
     ## Sleep Time Series ##
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
    /**
     ## Sleep Time Series ##
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
     ## Log Sleep ##
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
     ## Delete Sleep Log ##
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
    
    /**
    ## Get Profile ##
     The Get Profile endpoint returns a user's profile. The authenticated owner receives all values. However, the authenticated user's access to other users' data is subject to those users' privacy settings. Numerical values are returned in the unit system specified in the Accept-Language header.
     
     Resource URL
     
     GET https://api.fitbit.com/1/user/[user-id]/profile.json
     
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     Request Headers
    */
    func getUserProfile(completionHandler: @escaping (JSON?, Error?) -> ()) {
        let url = "https://api.fitbit.com/1/user/-/profile.json"
        restClient.getRequest(url: url) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json,nil)
            }
        }
    }
    /**
     ## Update Profile ##
     The Update Profile endpoint updates a user's profile. Numerical values are accepted in the unit system specified in the Accept-Language header.
     
     Notice: Beginning September 6, 2016, the nickname field in the Update Profile endpoint will no longer be editable. The field will continue to be returned in the Get Profile endpoint, but no longer modifiable.
     
     Resource URL
     
     POST https://api.fitbit.com/1/user/[user-id]/profile.json
     
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     POST Parameters
     
     gender                 optional	More accurately, sex; (MALE/FEMALE/NA)
     birthday               optional	Date of birth; in the format yyyy-MM-dd
     height                 optional	Height; in the format X.XX,
     aboutMe                optional	About Me string
     fullname               optional	Full name
     country                optional	Country; two-character code
     state                  optional	US State; two-character code; valid only if country was or being set to US
     city                   optional	City
     strideLengthWalking	optional	Walking stride length; in the format X.XX, in the unit system that 
     strideLengthRunning	optional	Running stride length; in the format X.XX, in the unit system that
     weightUnit             optional	Default weight unit on website (doesn't affect API); one of (en_US, en_GB, "any" for METRIC)
     heightUnit             optional	Default height/distance unit on website (doesn't affect API); one of (en_US, "any" for METRIC)
     waterUnit              optional	Default water unit on website (doesn't affect API); one of (en_US, "any" for METRIC)
     glucoseUnit            optional	Default glucose unit on website (doesn't affect API); one of (en_US, "any" for METRIC)
     timezone               optional	Timezone; in the format "America/Los_Angeles"
     foodsLocale            optional	Food Database Locale; in the format "xx_XX"
     locale                 optional	Locale of website (country/language); one of the locales, currently – (en_US, en_GB, en_AU, etc)
     localeLang             optional	Language; in the format "xx". You should specify either locale or both - localeLang and                                                     
                                        localeCountry (locale is higher priority).
     localeCountry          optional	Country; in the format "XX". You should specify either locale or both - localeLang and 
                                        localeCountry (locale is higher priority).
     startDayOfWeek         optional	Start day of the week; what day the week should start on. Either Sunday or Monday.
     clockTimeDisplayFormat	optional	How trackers with a clock should display the time. Either 12hour or 24hour.

    */
    func updateUserProfile(gender: String = "FEMALE", birthday: String? = nil, height: String? = nil, aboutMe: String? = nil, fullname: String? = nil, country: String? = nil, state: String? = nil, city: String? = nil, strideLengthWalking: String? = nil, strideLengthRunning: String? = nil, weightUnit: String? = nil, heightUnit: String? = nil, waterUnit: String? = nil, glucoseUnit: String? = nil, timezone: String? = nil, foodsLocale: String? = nil, localeLang: String? = nil, localeCountry: String? = nil, startDayOfWeek: String? = nil, clockTimeDisplayFormat: String? = nil, completionHandler: @escaping (JSON?, Error?) -> ()) {
   
        var parameters: Parameters = [:]
        
        if birthday != nil {
            parameters.updateValue(birthday!, forKey: "birthday")
        }
        if height != nil {
            parameters.updateValue(height!, forKey: "height")
        }
        if aboutMe != nil {
            parameters.updateValue(aboutMe!, forKey: "aboutMe")
        }
        if fullname != nil {
            parameters.updateValue(fullname!, forKey: "fullname")
        }
        if country != nil {
            parameters.updateValue(country!, forKey: "country")
        }
        if state != nil {
            parameters.updateValue(state!, forKey: "state")
        }
        if city != nil {
            parameters.updateValue(city!, forKey: "city")
        }
        if strideLengthWalking != nil {
            parameters.updateValue(strideLengthWalking!, forKey: "strideLengthWalking")
        }
        if strideLengthRunning != nil {
            parameters.updateValue(strideLengthRunning!, forKey: "strideLengthRunning")

        }
        if weightUnit != nil {
            parameters.updateValue(weightUnit!, forKey: "weightUnit")
            
        }
        
        if heightUnit != nil {
            parameters.updateValue(heightUnit!, forKey: "heightUnit")
            
        }
        if waterUnit != nil {
            parameters.updateValue(waterUnit!, forKey: "waterUnit")
            
        }
        if glucoseUnit != nil {
            parameters.updateValue(glucoseUnit!, forKey: "glucoseUnit")

        }
        
        if foodsLocale != nil {
            parameters.updateValue(foodsLocale!, forKey: "foodsLocale")
            
        }
        if localeLang != nil {
            parameters.updateValue(localeLang!, forKey: "localeLang")
            
        }
        if localeCountry != nil {
            parameters.updateValue(localeCountry!, forKey: "localeCountry")
            
        }
        if startDayOfWeek != nil {
            parameters.updateValue(startDayOfWeek!, forKey: "startDayOfWeek")
            
        }
        if clockTimeDisplayFormat != nil {
            parameters.updateValue(clockTimeDisplayFormat!, forKey: "clockTimeDisplayFormat")
            
        }
        
        let url = "https://api.fitbit.com/1/user/-/profile.json"
        restClient.postRequest(url: url, parameters: parameters) { json, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(json, nil)
            }
        }

    }
    
    func openFitbitApp() {
        let url = URL(string: "fitbit://")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
