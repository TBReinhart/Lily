//
//  HomeViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 2/23/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    @IBOutlet weak var tileView01: TileView!
//    @IBOutlet weak var tileView02: TileView!
    fileprivate let sectionInsets = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 50.0, right: 20.0)

    
    @IBOutlet weak var TileCollectionView: UICollectionView!
    /**
     Weight
     Emotion
     Baby Movement Log
     My Journal
     Call the Doctor
     My Goals
     Tile Store
    */
    var images = ["balance", "Checklist", "Heart" ,"Baby", "journal", "CallDoctor", "Star", "Store", "water"]
    let titles: [String: String] = ["balance":"Weight Log", "Checklist": "Emotion Log", "Baby":"Baby Movement Log", "Heart":"Heart Rate", "journal": "My Journal", "CallDoctor": "Call the Doctor", "Star": "My Goals", "Store": "Tile Store", "water": "Water Consumption"]
    fileprivate var longPressGesture: UILongPressGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.TileCollectionView.delegate = self
        self.TileCollectionView.dataSource = self
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        self.TileCollectionView.addGestureRecognizer(longPressGesture)
        self.automaticallyAdjustsScrollViewInsets = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TileCell", for: indexPath) as! TileCollectionViewCell
        let tile = images[indexPath.row]
        
        
        let tileView = self.getTile(tile: tile)
        cell.genericTileView.addSubview(tileView)
        tileView.bindFrameToSuperviewBounds()
        
        return cell
    }
    
    func getTile(tile: String) -> UIView {
        
        if tile == "water" {
            let waterTile = WaterTileView()
            waterTile.setCupsLabel(cups: "10")
            waterTile.setGoalsCupLabel(text: "of 10 cups")
            waterTile.setImage(name: "water")
            return waterTile
        }

        
        let tileView = TileView()
        tileView.image.image = UIImage(named: tile)
        tileView.mainLabel.text = titles[tile]
        tileView.bottomLabel.text = ""
        tileView.middleLabel.isHidden = true
        
        if tile == "Heart" {
            tileView.middleLabel.isHidden = false
            tileView.middleLabel.text = "76"
        }
        return tileView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item: \(indexPath.row)")
    }
    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        // move your data order
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (2 + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / 2
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.TileCollectionView.indexPathForItem(at: gesture.location(in: self.TileCollectionView)) else {
                break
            }
            TileCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            TileCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            TileCollectionView.endInteractiveMovement()
        default:
            TileCollectionView.cancelInteractiveMovement()
        }
    }
}
extension UIView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
}
