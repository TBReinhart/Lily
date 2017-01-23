//
//  TestViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 1/22/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import UICircularProgressRing


class TestViewController: UIViewController {

    @IBOutlet weak var ring1: UICircularProgressRingView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        ring1.animationStyle = kCAMediaTimingFunctionLinear
        ring1.fontSize = 100
        // Set the delegate
        // Do any additional setup after loading the view.
    }

    @IBAction func animateButtonPressed(_ sender: Any) {
        // You can set the animationStyle like this
        ring1.animationStyle = kCAMediaTimingFunctionLinear
        ring1.setProgress(value: 100, animationDuration: 5, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The delegate method!
    func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {
        if ring === ring1 {
            print("From delegate: Ring 1 finished")
        }
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
