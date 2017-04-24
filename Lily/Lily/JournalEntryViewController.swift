//
//  JournalEntryViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 3/23/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import Firebase

class JournalEntryViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var textView: UITextView!
    var entryDate: String!
    var date: Date!
    var journalKey: String!
    var journalEntry: String!
    
    @IBOutlet weak var journalEntryLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Entry Date: \(self.entryDate)")
        print("autoid \(self.journalKey ?? "no key?" )")
        self.textView.delegate = self
        self.createBordersInViews()
        
        self.setTextViewText(text: "")
        let headerDate = Helpers.getDateFromMMddyyyy(dateString: self.entryDate!)
        self.journalEntryLabel.text = Helpers.formatMediumDate(date: headerDate)
        self.setTextViewText(text: self.journalEntry)


    }

    
    func updateJournal() {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        
        if let uid = user?.uid {
            if let key = self.journalKey {
                ref.child("users/\(uid)/journals/\(key)/text)").setValue(self.textView.text)

            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("view will disappear")
        updateJournal()
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
    
    func setTextViewText(text: String) {
        self.textView.text = "\u{2022} \(text)"
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
