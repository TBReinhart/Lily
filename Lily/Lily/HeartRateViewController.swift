//
//  HeartRateViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 2/8/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SafariServices

class HeartRateViewController: UIViewController {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var restingBPMLabel: UILabel!
    @IBOutlet weak var maximumBPMLabel: UILabel!
    @IBOutlet weak var averageBPMLabel: UILabel!
    @IBOutlet weak var weekRange: UILabel!
    
    @IBOutlet weak var day01View: UIView!
    
    @IBOutlet weak var day02View: UIView!
    @IBOutlet weak var day03View: UIView!
    @IBOutlet weak var day04View: UIView!
    @IBOutlet weak var day05View: UIView!
    @IBOutlet weak var day06View: UIView!
    @IBOutlet weak var day07View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func adviceButtonLinkPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string:"http://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/pregnancy-nutrition/art-20043844?pg=2" )!)
        present(svc, animated: true, completion: nil)
        
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
