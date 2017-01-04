//
//  ViewController2.swift
//  
//
//  Created by Tom Reinhart on 12/26/16.
//
//

import UIKit
import CoreData
class ViewController2: UIViewController {

    override func viewDidLoad() {
        print("VIEWDIDLOAD2")
        let fbreqs = FitbitRequests()
        //fbreqs.logActivity(activityId: 12030, activityName: "Running", manualCalories: 197, durationMillis: 1800000, date: "2016-12-29", distance: 7.01, distanceUnit: nil, startTime: "12:20")
//        fbreqs.logWeight(weight: "73.0")
        //fbreqs.getRequest(request: fbreqs.getWeightOnDate(date: "today"))
        
        fbreqs.getDevices()
        //print("PRINTING JSON\n\(json)")
        //fbreqs.addAlarm(trackerId: trackerId, time: "13:30", recurring: true, weekDays: ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY"])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
