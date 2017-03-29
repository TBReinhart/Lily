//
//  DayWithTimeView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/1/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

//
//  WhatHappenedThatDay.swift
//  Lily
//
//  Created by Tom Reinhart on 2/25/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

@IBDesignable
class DayWithTimeView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
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
        UINib(nibName: "DayWithTimeView", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.black.cgColor
        addSubview(view)


    }
    

    
    func setDayLabel(title: String) {
        self.dayLabel.text = title
        self.dayLabel.adjustsFontSizeToFitWidth = true

    }
    

    
    func setTimeLabel(time: String) {
        self.timeLabel.text = time
        self.timeLabel.adjustsFontSizeToFitWidth = true

    }
}

