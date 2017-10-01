//
//  TileView.swift
//  Lily
//
//  Created by Tom Reinhart on 2/23/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//
import UIKit
import SMIconLabel

@IBDesignable
class TileView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var middleLabel: UILabel!
    
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
        UINib(nibName: "TileView", bundle: bundle).instantiate(withOwner: self, options: nil)
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
    
    func setBottomLabel(title: String) {
        self.bottomLabel.text = title
    }
    
    func setButtonLabel() {
        let labelLeft = SMIconLabel(frame: CGRectMake(10, 10, view.frame.size.width - 20, 20))
        labelLeft.text = "Icon on the left, text on the left"
        // Here is the magic
        labelLeft.icon = UIImage(named: "Bell")    // Set icon image
        labelLeft.iconPadding = 5                  // Set padding between icon and label
        labelLeft.numberOfLines = 0                // Required
        labelLeft.iconPosition = ( .left, .top )   // Icon position
        view.addSubview(labelLeft)
    }
    

}

