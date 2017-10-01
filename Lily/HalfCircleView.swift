//
//  HalfCircleView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/20/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

@IBDesignable
class HalfCircleView: UIView {

    @IBOutlet var view: UIView!

    
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
        UINib(nibName: "HalfCircleView", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        
    }
    

    


}
