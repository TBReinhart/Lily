//
//  FitbitRequests.swift
//  Lily
//
//  Created by Tom Reinhart on 12/23/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//

import Foundation
import p2_OAuth2
import Alamofire
class FitbitRequests {
    
    var loader: OAuth2DataLoader?
    fileprivate var alamofireManager: SessionManager?

    var oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "2285YX",
        "client_secret": "60640a94d1b4dcd91602d3efbee6ba87",
        "authorize_uri": "https://www.fitbit.com/oauth2/authorize",
        "token_uri": "https://api.fitbit.com/oauth2/token",
        "response_type": "code",
        "expires_in": "31536000", // 1 year expiration
        "scope": "activity heartrate location nutrition profile settings sleep social weight",
        "redirect_uris": ["lily://oauth/callback"],            // app has registered this scheme
        "verbose": true,
        ] as OAuth2JSON)
    
    
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
    
    func forgetTokens(_ sender: UIButton?) { // or nil params depending on if clicked signed out.
        oauth2.forgetTokens()
    }
    
    func postRequest(request: URLRequest) {

        let loader = OAuth2DataLoader(oauth2: oauth2)
        self.loader = loader
        debugPrint(request.httpBody)
        debugPrint(request.httpMethod)
        loader.perform(request: request) { response in
            do {
                let json = try response.responseJSON()
                debugPrint("RESPONSE in json")
                debugPrint(json)
                
            }
            catch let error {
                debugPrint(error)
            }
        }
        
    }
    

    func test() {
        var req = oauth2.request(forURL: URL(string: "https://api.fitbit.com/1/user/-/body/log/weight.json")!)
        var json = [
            "weight":"73.0",
            "date":"today"
            ] as OAuth2JSON

        print(json)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            req.httpBody = jsonData
            req.httpMethod = "POST"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            let task = oauth2.session.dataTask(with: req) { data, response, error in
                if error != nil {
                    // something went wrong, check the error
                }
                else {
                    debugPrint(data)
                    debugPrint(response)
                    debugPrint(response?.description)
                    
                    // check the response and the data
                    // you have just received data with an OAuth2-signed request!
                }
            }
            task.resume()
            
            
        }  catch {
            print("JSON Bug in Logging Activity")
        }


    }
    
    /**
     This method relies fully on Alamofire and OAuth2RequestRetrier.
     */
    func tester() {
        let sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier
        alamofireManager = sessionManager
        
        let parameters: Parameters = [
            "weight": "73.0",
            "date": "today"
        ]
        

        
        sessionManager.request("https://api.fitbit.com/1/user/-/body/log/weight.json", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print(response.result.value ?? "NONE")
                }
                break
                
            case .failure(_):
                print(response.result.error ?? "FAILURE")
                break
                
            }
        }
    }
    
    
    
    /**
     Get request from a game request name
    */
    func getRequest(reqName: String)  {

        let loader = OAuth2DataLoader(oauth2: oauth2)
        self.loader = loader
        
        let req = getRequestByName(reqName: reqName)
        
        loader.perform(request: req) { response in
            do {
                let json = try response.responseJSON()
                debugPrint("RESPONSE in json")
                debugPrint(json)
                
            }
            catch let error {
                debugPrint(error)
            }
        }

    }
    /**
     Get request from a given URLRequest
    */
    func getRequest(request: URLRequest) {
        let loader = OAuth2DataLoader(oauth2: oauth2)
        self.loader = loader
        
        loader.perform(request: request) { response in
            do {
                let json = try response.responseJSON()
                debugPrint("RESPONSE in json")
                debugPrint(json)
                
            }
            catch let error {
                debugPrint(error)
            }
        }
    }
    
    func getRequestByName(reqName: String) -> URLRequest {
        switch reqName {
        case "userProfile":
            debugPrint("Case userProfile")
            return userProfile
        case "dailyActivitySummary":
            debugPrint("Case dailyActivitySummary")
            return dailyActivitySummary
        case "activities":
            debugPrint("Case activites")
            return activities
        case "logWeight":
            debugPrint("Case logWeight")
            return logWeight
        default:
            return userProfile
        }
    }
    
    
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
    func getWeightOnDate(date: String = "today") -> URLRequest {
        return URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/body/log/weight/date/\(date).json")!)
    }
    
    //GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[period].json
    //     base-date	The end date when period is provided, in the format yyyy-MM-dd; range start date when a date range is provided.
    //     period       The date range period. One of 1d, 7d, 30d, 1w, 1m.
    func getWeightForPeriod(baseDate: String, period: String) -> URLRequest {
        return URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/body/log/weight/date/\(baseDate)/\(period).json")!)
    }
    
    
    //     GET https://api.fitbit.com/1/user/-/body/log/weight/date/[base-date]/[end-date].json
    //     start-date	The end date when period is provided, in the format yyyy-MM-dd; range start date when a date range is provided.
    //      end-date	Range end date when date range is provided. Note: The period must not be longer than 31 days.
    func getWeightFromStartEndDates(startDate: String, endDate: String) -> URLRequest {
        return URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/body/log/weight/date/\(startDate)/\(endDate).json")!)
    }
    
    // POST https://api.fitbit.com/1/user/-/body/log/weight.json
    // POST Parameters
    //
    //    weight	required	Weight - in the format X.XX.
    //    date	required	Log entry date - in the format yyyy-MM-dd.
    //    time	optional	Time of the measurement - hours and minutes in the format HH:mm:ss, which is set to the last second of the day if time is not provided.
    func logWeight(weight: Double, date: String? = "today", time: String? = nil) {
        
        var json = [
            "weight":weight,
            "date":date ?? "today"
            ] as OAuth2JSON
        
        if time != nil {
            json["time"] = time
        }
        
        print(json)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            // insert json data to the request
            //var request = getRequestByName(reqName: "logWeight")
            let string1 = String(data: jsonData, encoding: String.Encoding.utf8) ?? "Data could not be printed"
            print(string1)
            
            var req = URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/body/log/weight.json")!)
            req.httpMethod = "POST"
            req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
            postRequest(request: req)
            
            
        }  catch {
            print("JSON Bug in Logging Activity")
        }
    }
    
     func alamo() {
        if oauth2.isAuthorizing {
            oauth2.abortAuthorization()
            return
        }
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        
        let sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier

        debugPrint("Getting my weight")
        sessionManager.request("https://api.fitbit.com/1/user/-/body/log/weight/date/today.json").validate().responseJSON { response in
            debugPrint(response)
        }
        

        
        
    }
    /**
    Delete Weight Log
    The Delete Weight Log API deletes a user's body weight log entry with the given ID.
    
    Note: A successful request returns a 204 status code with an empty response body.
    
    Resource URL
    
    DELETE https://api.fitbit.com/1/user/[user-id]/body/log/weight/[body-weight-log-id].json
    
    */
    
    
    
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
        
        let json = [
            "activityId":activityId,
            "activityName":activityName,
            "manualCalories":manualCalories,
            "distance":distance,
            "durationMillis":durationMillis,
            "date":date,
            "startTime":startTime,
        ] as [String : Any]
        
        
        print(json)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            // insert json data to the request
            var request = getRequestByName(reqName: "activities")
            let string1 = String(data: jsonData, encoding: String.Encoding.utf8) ?? "Data could not be printed"
            print("STRING 1")
            print(string1)
            
            request.httpMethod = "POST"
            //HTTP Headers
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = jsonData
            debugPrint(request)
            
            postRequest(request: request)


        }  catch {
            print("JSON Bug in Logging Activity")
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
    

    func getActivityTimeSeriesFromStartEndDates(resourcePath: String, baseDate: String, endDate: String) -> URLRequest {
        return URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/[resource-path]/date/[date]/[period].json")!)
    }
    
    func getActivityTimeSeriesFromPeriod(resourcePath: String, date: String, period: String) -> URLRequest {
        return URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/\(resourcePath)/date/\(date)/\(period).json")!)
    }
    
    /**
     GET https://api.fitbit.com/1/user/[user-id]/activities/date/[date].json
     user-id	The encoded ID of the user. Use "-" (dash) for current logged-in user.
     date	The date in the format yyyy-MM-dd
    */
    var dailyActivitySummary: URLRequest {
        return URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/activities/date/today.json")!)
    }
    
    var userProfile: URLRequest {
        return URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/profile.json")!)
    }
    
    var activities: URLRequest {
        return URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/activities.json")!)
    }
    var logWeight: URLRequest {
        return URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/body/log/weight.json")!)
    }
    
}
