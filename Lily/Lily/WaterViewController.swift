//
//  WaterViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 1/31/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class WaterViewController: UIViewController {

    var fbreqs = FitbitRequests()
    var waterObject = Water()
    var weekWaterObjects = [Water?](repeating: nil, count:7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fbreqs.getWaterLastWeek() { waters, error in
            self.weekWaterObjects = waters ?? [Water?](repeating: nil, count:7)
            for water in self.weekWaterObjects {
                print(water?.dayOfWeek ?? "NONE")
                print(water?.cupsConsumed ?? "0.0")
                print(water?.dateString ?? "1/1")
            }

        
        }
        // Do any additional setup after loading the view.
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
