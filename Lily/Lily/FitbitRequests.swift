//
//  FitbitRequests.swift
//  Lily
//
//  Created by Tom Reinhart on 12/23/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//

import Foundation
import Alamofire
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
    func getWeightOnDate(date: String = "today") {
        let url = "https://api.fitbit.com/1/user/-/body/log/weight/date/\(date).json"
        restClient.getRequest(url: url)
    }
    
    //GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[period].json
    //     base-date	The end date when period is provided, in the format yyyy-MM-dd; range start date when a date range is provided.
    //     period       The date range period. One of 1d, 7d, 30d, 1w, 1m.
    func getWeightForPeriod(baseDate: String, period: String) {
        let url = "https://api.fitbit.com/1/user/-/body/log/weight/date/\(baseDate)/\(period).json"
        restClient.getRequest(url: url)

    }
    
    
    //     GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[end-date].json
    //     start-date	The end date when period is provided, in the format yyyy-MM-dd; range start date when a date range is provided.
    //      end-date	Range end date when date range is provided. Note: The period must not be longer than 31 days.
    func getWeightFromStartEndDates(startDate: String, endDate: String) {
        let url = "https://api.fitbit.com/1/user/-/body/log/weight/date/\(startDate)/\(endDate).json"
        restClient.getRequest(url: url)

    }
    
    
    // POST https://api.fitbit.com/1/user/-/body/log/weight.json
    // POST Parameters
    //
    //    weight	required	Weight - in the format X.XX.
    //    date	required	Log entry date - in the format yyyy-MM-dd.
    //    time	optional	Time of the measurement - hours and minutes in the format HH:mm:ss, which is set to the last second of the day if time is not provided.
    func logWeight(weight: String, date: String? = "today", time: String? = nil) {
        
        var parameters: Parameters = [
            "weight": weight,
            "date": date ?? "today"
        ]
        
        if time != nil {
            parameters.updateValue(time ?? "23:59:59", forKey: "time")
        }
        let url = "https://api.fitbit.com/1/user/-/body/log/weight.json"
        restClient.postRequest(url: url, parameters: parameters)

    }
    /**
     Delete Weight Log
     The Delete Weight Log API deletes a user's body weight log entry with the given ID.
     
     Note: A successful request returns a 204 status code with an empty response body.
     
     Resource URL
     
     DELETE https://api.fitbit.com/1/user/[user-id]/body/log/weight/[body-weight-log-id].json
     
     */
    func deleteWeight(lodId: String) {
        let url = "https://api.fitbit.com/1/user/[user-id]/body/log/weight/\(lodId).json"
        restClient.deleteRequest(url: url)
    }
    
    func getDevices() {
        let url = "https://api.fitbit.com/1/user/-/devices.json"
        restClient.getRequest(url: url)
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
    func logActivity(activityId: Int, activityName: String, manualCalories: Int,  durationMillis: Int, date: String, distance: Double, distanceUnit: String? = nil, startTime: String) {
        
        
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
        restClient.postRequest(url: url, parameters: parameters)
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
    

    func getActivityTimeSeriesFromStartEndDates(resourcePath: String, baseDate: String, endDate: String) {
        let url = "https://api.fitbit.com/1/user/-/[resource-path]/date/[date]/[period].json"
        restClient.getRequest(url: url)

    }
    
    func getActivityTimeSeriesFromPeriod(resourcePath: String, date: String, period: String) {
        let url = "https://api.fitbit.com/1/user/-/\(resourcePath)/date/\(date)/\(period).json"
        restClient.getRequest(url: url)

    }
    
    /**
     Get Alarms
     The Get Alarms endpoint returns a list of the set alarms connected to a user's account.
     
     Resource URL
     
     GET https://api.fitbit.com/1/user/-/devices/tracker/[tracker-id]/alarms.json

    */
    func getAlarms(trackerId: String) {
        let url = "https://api.fitbit.com/1/user/-/devices/tracker/\(trackerId)/alarms.json"
        restClient.getRequest(url: url)
        
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
 
    */
    func addAlarm(trackerId: String, time: String, recurring: Bool, weekDays: [String]) {
        let days = weekDays.joined(separator: ",")  // "MONDAY, TUESDAY, FRIDAY"
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let stringFromDate = df.date(from: time) // expects 24 hours time 18:15 for example
        let utcOffset = Helpers.getOffset()

        
        let parameters: Parameters = [
            "time": "\(stringFromDate)\(utcOffset)",
            "enabled": true,
            "recurring": true,
            "weekDays":days
        ]
        let url = "https://api.fitbit.com/1/user/-/devices/tracker/\(trackerId)/alarms.json"
        restClient.postRequest(url: url, parameters: parameters)
    }
    

    
}
