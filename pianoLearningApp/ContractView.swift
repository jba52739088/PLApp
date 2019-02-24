//
//  ContractView.swift
//  pianoLearningApp
//


import UIKit

class ContractView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contractView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var agreeBtn: UIButton!
    
    weak var registerStep1VC: RegisterStep1VC!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initView() {
        contentView.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = true
        
        if let url = URL(string: "http://114.34.5.111:5880/docs/privacy.txt") {
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                self.textView.text = text
            }
            catch {
                /* error handling here */
                
            }
        }
    }
    
    @IBAction func tapAgreeBtn(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}
