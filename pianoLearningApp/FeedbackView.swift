//
//  FeedbackView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/15.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class FeedbackView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    func initView() {
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor(red: 121, green: 85, blue: 72, alpha: 1).cgColor
        self.textView.layer.cornerRadius = 3
        self.textView.layer.masksToBounds = true
        self.button.layer.cornerRadius = 3
        self.button.layer.masksToBounds = true
    }
    
    @IBAction func sendFeedback(_ sender: Any) {
        
    }
}
