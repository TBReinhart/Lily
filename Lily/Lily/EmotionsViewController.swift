//
//  EmotionsViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 3/25/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SafariServices
class EmotionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var advicePanelView: AdvicePanelView!
    let advice = "A new baby may add emotional stress to your life. It’s natural to feel worried, exhausted, and anxious all at once.\n\nDuring the first trimester, you may experience mood swings and sudden weepiness. You should seek understanding and emotional support from your partner and be candid with your physician.\n\nDuring the second trimester, bodily changes may affect your emotions. You may feel frustrated and worry about labor and delivery. Focus on making healthy lifestyle choices and educate yourself about your pregnancy.\n\nDuring the third trimester, the reality of motherhood may begin to sink in. You may feel anxious and overwhelmed. Consider journaling your thoughts and planning aheald for delivery."
    let sourceLink = "http://www.mayoclinic.org/healthy-lifestyle/pregnancy-week-by-week/in-depth/pregnancy/art-20047732?pg=2"
    let adviceTitle = "HOW SHOULD I BE FEELING?"
    let source = "Mayo Clinic"
    
    @IBOutlet weak var emotionsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emotionsCollectionView.dataSource = self
        self.emotionsCollectionView.delegate = self
        
        self.advicePanelView.adviceLinkButton.addTarget(self, action: #selector(self.adviceTapped), for: .touchUpInside)
        self.setAdvice(advice: self.advice)
        self.setAdviceLink(source: self.source)
        self.setAdviceTitle(title: self.adviceTitle)
        self.setAdviceURL(source: self.sourceLink)
        // Do any additional setup after loading the view.
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmotionCell", for: indexPath) as! EmotionViewCollectionViewCell
        let emotion = self.getEmotion(index: indexPath.row)
        
        cell.emotionView.setLabel(emotion: emotion)
        return cell
    }
    
    func getEmotion(index: Int) -> String {
        switch index {
        case 0:
            return "frustrated"
        case 1:
            return "overwhelmed"
        case 2:
            return "sad"
        case 3:
            return "happy"
        case 4:
            return "angry"
        case 5:
            return "nervous"
        case 6:
            return "like crying"
        case 7:
            return "excited"
        case 8:
            return "irate"
        case 9:
            return "scared"
        case 10:
            return "miserable"
        case 11:
            return "like laughing"
        default:
            return "other"
        }
    }
    
    func adviceTapped() {
        let url = self.advicePanelView.adviceLinkSource
        let svc = SFSafariViewController(url: URL(string:url)!)
        present(svc, animated: true, completion: nil)
    }
    func setAdviceTitle(title: String) {
        self.advicePanelView.setTitleLabel(title: title)
    }
    func setAdvice(advice: String) {
        self.advicePanelView.setAdviceText(advice: advice)
    }
    func setAdviceLink(source: String) {
        self.advicePanelView.setAdviceButtonText(source: source)
    }
    func setAdviceURL(source: String) {
        self.advicePanelView.setAdviceLinkSource(source: source)
    }
}