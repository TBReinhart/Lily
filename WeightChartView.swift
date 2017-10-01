//
//  WeightChartView.swift
//  Lily
//
//  Created by Brian Fisher on 9/24/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class WeightChartView: UIView {

    @IBOutlet var weightImage: UIImageView!
    @IBOutlet var view: UIView!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
     override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: "WeightChart", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        
    }


    @IBAction func linkTo(_ sender: Any) {
    
    }
}
