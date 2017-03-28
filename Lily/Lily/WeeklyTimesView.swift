//
//  WeeklyTimesView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/2/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

@IBDesignable
class WeeklyTimesView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var weeklyView: WeeklyView!
    @IBOutlet weak var day01View: DayWithTimeView!
    @IBOutlet weak var day02View: DayWithTimeView!
    @IBOutlet weak var day03View: DayWithTimeView!
    @IBOutlet weak var day04View: DayWithTimeView!
    @IBOutlet weak var day05View: DayWithTimeView!
    @IBOutlet weak var day06View: DayWithTimeView!
    @IBOutlet weak var day07View: DayWithTimeView!
    @IBOutlet weak var day08View: DayWithTimeView!

    var views = [DayWithTimeView]()
    
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
        UINib(nibName: "WeeklyTimesView", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        self.views = [self.day01View, self.day02View, self.day03View, self.day04View, self.day05View, self.day06View, self.day07View, self.day08View]
        addSubview(view)
        
        
    }
    
    
    
    func setDayViewDateLabel(day: String, dayNumber: Int) {
        self.views[dayNumber].setDayLabel(title: day)
    }
    func setDayViewTimeLabel(time: String, dayNumber: Int) {
        self.views[dayNumber].setTimeLabel(time: time)
    }
    
    
}
