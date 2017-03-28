//
//  AdvicePanelView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/2/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SafariServices

@IBDesignable
class AdvicePanelView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var weeklyBarView: WeeklyBarView!
    @IBOutlet weak var adviceTextView: UITextView!
    @IBOutlet weak var adviceLinkButton: UIButton!
    @IBOutlet weak var title: UILabel!
    var adviceLinkSource = "http://americanpregnancy.org/pregnancy-health"
    
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
        UINib(nibName: "AdvicePanelView", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        
    }

    
    @IBAction func adviceLinkPressed(_ sender: Any) {
        print("advice pressed") 
        
    }
    
    func setAdviceText(advice: String) {
        self.adviceTextView.text = advice
        let fixedWidth = adviceTextView.frame.size.width
        adviceTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = adviceTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = adviceTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        adviceTextView.frame = newFrame;
        adviceTextView.isScrollEnabled = false
    }
    
    func setTitleLabel(title: String) {
        self.title.text = title
    }
    
    func setAdviceButtonText(source: String) {
        self.adviceLinkButton.titleLabel?.text = source
    }
    func setAdviceLinkSource(source: String) {
        self.adviceLinkSource = source
    }
    
}
