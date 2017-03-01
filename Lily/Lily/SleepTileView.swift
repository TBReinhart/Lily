//
//  SleepTileView.swift
//  Lily
//
//  Created by Tom Reinhart on 2/25/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
@IBDesignable
class SleepTileView: UIView {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
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
        UINib(nibName: "SleepTile", bundle: bundle).instantiate(withOwner: self, options: nil)
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
    
    func setTimeLabel(time: String) {
        self.timeLabel.text = time
    }
    
}
