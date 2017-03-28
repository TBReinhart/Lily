//
//  EmotionCellView.swift
//
//
//  Created by Tom Reinhart on 3/25/17.
//
//

import UIKit

@IBDesignable
class EmotionCellView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    var emotion: String!
    var isSelected: Bool!
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
        UINib(nibName: "EmotionCellView", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    
    }
    
    func setLabel(emotion: String) {
        self.emotion = emotion
        self.label.text = self.emotion
        self.isSelected = false
        self.label.sizeToFit()
    }
    
    
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        if self.isSelected == true {
            self.isSelected = false
            self.button.setImage(#imageLiteral(resourceName: "default_circle.png"), for: .normal)
            return
        } else {
            self.isSelected = true
        }
        
        switch self.emotion {
        case "frustrated":
            self.button.setImage(#imageLiteral(resourceName: "frustrated_circle.png"), for: .normal)
        case "overwhelmed":
            self.button.setImage(#imageLiteral(resourceName: "overwhelmed_circle.png"), for: .normal)
        case "sad":
            self.button.setImage(#imageLiteral(resourceName: "sad_circle.png"), for: .normal)
        case "happy":
            self.button.setImage(#imageLiteral(resourceName: "happy_circle.png"), for: .normal)
        case "angry":
            self.button.setImage(#imageLiteral(resourceName: "angry_circle.png"), for: .normal)
        case "nervous":
            self.button.setImage(#imageLiteral(resourceName: "nervous_circle.png"), for: .normal)
        case "like crying":
            self.button.setImage(#imageLiteral(resourceName: "like_crying_circle.png"), for: .normal)
        case "excited":
            self.button.setImage(#imageLiteral(resourceName: "excited_circle.png"), for: .normal)
        case "irate":
            self.button.setImage(#imageLiteral(resourceName: "irate_circle.png"), for: .normal)
        case "scared":
            self.button.setImage(#imageLiteral(resourceName: "scared_circle.png"), for: .normal)
        case "miserable":
            self.button.setImage(#imageLiteral(resourceName: "miserable_circle.png"), for: .normal)
        case "like laughing":
            self.button.setImage(#imageLiteral(resourceName: "like_laughing_circle.png"), for: .normal)
        default:
            self.button.setImage(#imageLiteral(resourceName: "default_circle.png"), for: .normal)
        }
    }
    
}
