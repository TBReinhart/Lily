//
//  WeeklyView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/2/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

@IBDesignable
class WeeklyView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var weeklyBarView: WeeklyBarView!

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
        UINib(nibName: "WeeklyView", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        
    }


    
}
