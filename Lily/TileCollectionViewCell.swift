//
//  TileCollectionViewCell.swift
//  Lily
//
//  Created by Tom Reinhart on 2/23/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class TileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var genericTileView: UIView!
    
    override func prepareForReuse() {

        self.genericTileView = nil
        super.prepareForReuse()

    }
    
    func setView(v: UIView) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        self.addSubview(v)
    }
}
