//
//  ActivityTileView.swift
//  Lily
//
//  Created by Tom Reinhart on 2/28/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import UICircularProgressRing
@IBDesignable
class ActivityTileView: UIView {
    
    @IBOutlet weak var progressView: UICircularProgressRingView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var ofTotalTimeLabel: UILabel!
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
        UINib(nibName: "ActivityTile", bundle: bundle).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = bounds
        self.progressView.outerRingColor = self.progressView.outerRingColor.withAlphaComponent(0.3)
    }
    
    func setProgressRing(value: Double, maxValue: Double, animationDuration: Double = 3) {
        self.progressView.viewStyle = 2
        self.progressView.maxValue = CGFloat(maxValue)
        self.progressView.setProgress(value: CGFloat(value), animationDuration: TimeInterval(animationDuration), completion: nil)
        
        
    }
    func setTotalLabel(total: String) {
        self.ofTotalTimeLabel.text = "  of \(total) min"
    }
    
    func setMainLabel(title: String) {
        self.mainLabel.text = title
    }
}
