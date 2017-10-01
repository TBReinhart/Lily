//
//  WeeklyBarView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/2/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

protocol SignInDelegate: class {    // <-- needs :class for weak
    func signIn()
    func weightForwardWeek()
}


class WeeklyBarView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var dateRangeLabel: UILabel!
    weak var delegate: SignInDelegate?
    
    
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
        UINib(nibName: "WeeklyBarView", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
    }
    func hideBackButton() {
        self.backButton.isHidden = true
    }
    func showBackButton() {
        self.backButton.isHidden = false
    }
    func hideForwardButton() {
        self.forwardButton.isHidden = true
    }
    func showForwardButton() {
        self.forwardButton.isHidden = false
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        print("back pressed")
        delegate?.signIn()
    }
    
    @IBAction func forwardButtonPressed(_ sender: Any) {
        print("forward pressed")
        delegate?.weightForwardWeek()

    }
    
    func setDateRangeLabel(title: String) {
        self.dateRangeLabel.text = title
    }
    
    

}
