//
//  WaterTileView.swift
//  Lily
//
//  Created by Tom Reinhart on 2/23/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

@IBDesignable

class WaterTileView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var cupsLabel: UILabel!
    @IBOutlet weak var goalCupsLabel: UILabel!

    
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
        UINib(nibName: "WaterTile", bundle: bundle).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = bounds
    }
    
    func setMainLabel(title: String) {
        self.mainLabel.text = title
    }
    func setCupsLabel(cups: String) {
        self.cupsLabel.text = cups
    }
    
    func setImage(name: String) {
        self.image.image = UIImage(named: name)!
        self.image.contentMode = UIViewContentMode.scaleAspectFit
        
    }
    
    func setGoalsCupLabel(text: String) {
        self.goalCupsLabel.text = text
    }
    

    
    
}
func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}
