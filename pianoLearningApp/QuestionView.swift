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
        
        if let url = URL(string: "http://114.34.5.111:5880/apis/faq.php?cmd=all") {
//            if let url = URL(string: "http://114.34.5.111:5880/docs/guide.txt") {
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                self.textView.text = text
            }
            catch {
                /* error handling here */
                
            }
        }
    }
}
