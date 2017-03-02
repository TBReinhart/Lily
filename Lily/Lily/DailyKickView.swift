//
//  DailyKickView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/1/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

@IBDesignable

class DailyKickView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var kickButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
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
        UINib(nibName: "DailyKickView", bundle: bundle).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = bounds
    }
    
    func setDayLabel(title: String) {
        self.dayLabel.text = title
    }
    
    @IBAction func kickButtonPressed(_ sender: Any) {
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
    }
    func setTimeLabel(time: String) {
        self.timeLabel.text = time
    }
}
