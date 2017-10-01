//
//  WeightUpdateView.swift
//  Lily
//
//  Created by Brian Fisher on 9/21/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class WeightUpdateView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var subtractButton: UIButton!
    

    override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
}
    required init?(coder aDecoder: NSCoder) {
super.init(coder: aDecoder)
commonInit()
}
private func commonInit() {

}


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
