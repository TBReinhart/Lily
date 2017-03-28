//
//  JournalEntryViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 3/23/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class JournalEntryViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var textView: UITextView!

    var entryDate: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Entry Date: \(self.entryDate!)")
        self.textView.delegate = self
        self.createBordersInViews()
        self.setTextViewText()
    }


    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // If the replacement text is "\n" and the
        // text view is the one you want bullet points
        // for
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            if textView.text.characters.count == 1 {
                textView.text = "\u{2022} "
            }
            return true
            
        }
        
        if (text == "\n") {
            // If the replacement text is being added to the end of the
            // text view, i.e. the new index is the length of the old
            // text view's text...
            
            
            if range.location == textView.text.characters.count {
                // Simply add the newline and bullet point to the end
                let updatedText: String = textView.text! + "\n \u{2022} "
                textView.text = updatedText
            }
            else {
                
                // Get the replacement range of the UITextView
                let beginning: UITextPosition = textView.beginningOfDocument
                let start: UITextPosition = textView.position(from: beginning, offset: range.location)!
                let end: UITextPosition = textView.position(from: start, offset: range.length)!
                let textRange: UITextRange = textView.textRange(from: start, to: end)!
                // Insert that newline character *and* a bullet point
                // at the point at which the user inputted just the
                // newline character
                textView.replace(textRange, withText: "\n \u{2022} ")
                // Update the cursor position accordingly
                let cursor: NSRange = NSMakeRange(range.location + "\n \u{2022} ".characters.count, 0)
                textView.selectedRange = cursor
            }
            
            return false
            
            
        }
        // Else return yes
        return true
    }
    
    func setTextViewText() {
        self.textView.text = "\u{2022} My stomach hurts \n\u{2022} I have been vomiting twice per day every day\n\u{2022} I have felt sad and overwhelmed for the past few days"
    }
    
    func createBordersInViews() {
        let customFrame : CGRect = CGRectMake(0,0,bottomView.frame.width,0.5)
        let customView : UIView = UIView(frame: customFrame)
        customView.backgroundColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)
        self.bottomView.addSubview(customView)
        
        let customTopFrame : CGRect = CGRectMake(0,topView.frame.height-0.5,topView.frame.width,0.5)
        let customTopView : UIView = UIView(frame: customTopFrame)
        customTopView.backgroundColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)
        self.topView.addSubview(customTopView)
    }
}
