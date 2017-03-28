//
//  EmotionViewCollectionViewCell.swift
//  Lily
//
//  Created by Tom Reinhart on 3/26/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class EmotionViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var emotionView: EmotionCellView!
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
    }
    
    func setView(v: UIView) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        self.addSubview(v)
    }
}
