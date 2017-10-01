//
//  WeeklyMiddleView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/2/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

@IBDesignable
class WeeklyMiddleView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var secondTextLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var mainStatLabel: UILabel!
    @IBOutlet weak var statDetailLabel: UILabel!

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
        UINib(nibName: "weeklyMiddleView", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        
    }
    
    
    func setTopLabel(text: String) {
        self.topTextLabel.text = text
    }
    func setSecondLabel(text: String) {
        self.secondTextLabel.text = text
    }
    
    func setImage(name: String) {
        self.image.image = UIImage(named: name)!
        self.image.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    func setMainStatLabel(text: String) {
        self.mainStatLabel.text = text
    }
    func setStatDetailLabel(text: String) {
        self.statDetailLabel.text = text
    }
    
    
    
}
