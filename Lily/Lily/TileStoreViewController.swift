//
//  TileStoreViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 3/20/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class TileStoreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    fileprivate let sectionInsets = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 50.0, right: 20.0)
    @IBOutlet weak var TileCollectionView: UICollectionView!

//    var images = ["Activity", "Moon", "balance", "Checklist", "Heart" ,"Baby", "journal", "CallDoctor", "Star", "Store", "water", "Calendar"]
    var images = ["baby_heart_rate", "medication_log", "morning_sickness", "contraction_timer", "nutrition"]
    
    let titles: [String: String] = ["baby_heart_rate":"My Baby's Heartbeat", "medication_log":"Medication Log", "morning_sickness": "Morning Sickness Tracker", "contraction_timer":"Contraction Timer", "nutrition":"Nutrition"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TileCollectionView.delegate = self
        self.TileCollectionView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TileCell", for: indexPath) as! TileCollectionViewCell
        let tile = images[indexPath.row]
        
        let tileView = self.getTile(tile: tile)
        cell.setView(v: tileView)
        tileView.bindFrameToSuperviewBounds()
        
        return cell
    }
    
    func getTile(tile: String) -> UIView {
        let tileView = TileView()
        tileView.image.image = UIImage(named: tile)
        tileView.image.contentMode = .scaleAspectFit

//        if titles[tile] == "Morning Sickness Tracker" {
//            tileView.mainLabel.text = "Morning Sickness\n Tracker"
//        } else {
//            tileView.mainLabel.text = titles[tile]
//        }
        
        tileView.mainLabel.text = titles[tile]

        
        tileView.bottomLabel.text = ""
        tileView.middleLabel.isHidden = true
        
        if tile == "baby_heart_rate" {
            tileView.bottomLabel.text = "$0.99"
        } else {
            tileView.bottomLabel.text = "Free"
        }
        return tileView
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item: \(indexPath.row)")
        print(self.images[indexPath.row])
        // ["Activity", "Moon", "balance", "Checklist", "Heart" ,"Baby", "journal", "CallDoctor", "Star", "Store", "water", "Calendar"]
        switch self.images[indexPath.row] {
        case "Activity":
            self.performSegue(withIdentifier: "activitySegue", sender: nil)
        case "Moon":
            self.performSegue(withIdentifier: "sleepSegue", sender: nil)
        case "Checklist":
            self.performSegue(withIdentifier: "emotionsSegue", sender: nil)
        case "Heart":
            self.performSegue(withIdentifier: "heartRateSegue", sender: nil)
        case "Baby":
            self.performSegue(withIdentifier: "babyMovementSegue", sender: nil)
        case "journal":
            self.performSegue(withIdentifier: "journalSegue", sender: nil)
        case "CallDoctor":
            if let url = URL(string: "tel://\(7247669463)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case "Star":
            self.performSegue(withIdentifier: "goalsSegue", sender: nil)
        case "Store":
            self.performSegue(withIdentifier: "storeSegue", sender: nil)
        case "Calendar":
            self.performSegue(withIdentifier: "thisDaySegue", sender: nil)
        case "water":
            self.performSegue(withIdentifier: "waterSegue", sender: nil)
        case "balance":
            self.performSegue(withIdentifier: "weightSegue", sender: nil)
        default:
            return
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let backItem = UIBarButtonItem()
        backItem.title = "Home"
        navigationItem.backBarButtonItem = backItem
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        // move your data order
        swap(&self.images[sourceIndexPath.row], &self.images[destinationIndexPath.row])
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
}
