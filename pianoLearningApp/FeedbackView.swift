//
//  FeedbackView.swift
//  pianoLearningApp
//


import UIKit

class FeedbackView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var delegate: AccountPageDelegat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    func initView() {
        
        self.textView.layer.cornerRadius = 5
        self.textView.layer.masksToBounds = true
        self.textView.clipsToBounds = true
        self.button.layer.cornerRadius = 5
        self.button.layer.masksToBounds = true
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
    }
    
    @IBAction func sendFeedback(_ sender: Any) {
        if let text = textView.text, text != "" {
            self.delegate?.sendFeedback(message: text, completionHandler: { (isSucceed) in
                if isSucceed {
                    if let didSendFeedbackView = Bundle.main.loadNibNamed("didSendFeedback", owner: self, options: nil)?.first as? didSendFeedback {
                        didSendFeedbackView.frame = self.frame
                        self.textView.text = ""
                        self.addSubview(didSendFeedbackView)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            didSendFeedbackView.removeFromSuperview()
                        })
                    }
                }
            })
        }
    }
}
