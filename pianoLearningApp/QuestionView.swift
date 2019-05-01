//
//  QAView.swift
//  pianoLearningApp
//


import UIKit

class QuestionView: UIView {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var backBtn: UIButton!
    

    @IBAction func doGoBack(sender: AnyObject) {
        self.removeFromSuperview()
    }
    
    func loadData() {
        
        APIManager.shared.getFAQ { (resault) in
            self.textView.text = resault
        }
    }
}
