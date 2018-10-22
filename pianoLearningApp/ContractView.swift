//
//  ContractView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/2.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class ContractView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contractView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var agreeBtn: UIButton!
    
    weak var registerStep1VC: RegisterStep1VC!
    
//    class func instantiateFromNib() -> ContractView{
//        return Bundle.main.loadNibNamed("ContractView", owner: self, options: nil)?.first as! ContractView
//
//    }
    
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
    }
    
    @IBAction func tapAgreeBtn(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}
