//
//  WhatHappenedThatDay.swift
//  Lily
//
//  Created by Tom Reinhart on 2/25/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

@IBDesignable

class WhatHappenedThatDay: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var dowLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!

    
    
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
        UINib(nibName: "WhatHappenedThatDay", bundle: bundle).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = bounds
    }
    
    func setMainLabel(title: String) {
        self.mainLabel.text = title
    }

    
    func setImage(name: String) {
        self.image.image = UIImage(named: name)!
        self.image.contentMode = UIViewContentMode.scaleAspectFit
        
    }
    
    func setDowLabel(dow: String) {
        self.dowLabel.text = dow
    }
    
    func setNumberLabel(number: String) {
        self.numberLabel.text = number
    }
    
    
}
func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}
