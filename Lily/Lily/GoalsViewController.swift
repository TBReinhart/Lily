//
//  GoalsViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 2/13/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class GoalsViewController: UIViewController {

    
    /// the images for goals
    @IBOutlet weak var waterConumptionGoalImage: UIImageView!
    @IBOutlet weak var activityGoalImage: UIImageView!
    @IBOutlet weak var sleepGoalImage: UIImageView!
    @IBOutlet weak var heartRateGoalImage: UIImageView!
    @IBOutlet weak var weightGoalImage: UIImageView!
    @IBOutlet weak var babyMovementGoalImage: UIImageView!
    @IBOutlet weak var emotionsGoalImage: UIImageView!
    @IBOutlet weak var callTheDoctorImage: UIImageView!
    
    /// the alarm clock images
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.waterConumptionGoalImage.contentMode = .scaleAspectFit

    }
    
    // TODO
    // fetch goals and then save them to firebase 

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
