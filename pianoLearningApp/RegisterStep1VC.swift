//
//  RegisterStep1VC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/1.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class RegisterStep1VC: UIViewController {
    
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var checkField: UITextField!
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    let btnAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12),
        NSAttributedStringKey.foregroundColor : UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1),
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    @IBAction func tapCheckBtn(_ sender: Any) {
//        checkBox.isChecked = !checkBox.isChecked
        let contractView: ContractView = Bundle.main.loadNibNamed("ContractView", owner: self, options: nil)?.first as! ContractView
        contractView.frame = self.view.frame
        contractView.initView()
        contractView.registerStep1VC = self
        self.view.addSubview(contractView)
    }
    
    @IBAction func tapNextBtn(_ sender: Any) {
        let registerStep2View: RegisterStep2View = Bundle.main.loadNibNamed("RegisterStep2View", owner: self, options: nil)?.first as! RegisterStep2View
        registerStep2View.frame = self.view.frame
        registerStep2View.initView()
        registerStep2View.registerStep1VC = self
        self.view.addSubview(registerStep2View)
    }
    
    func initView() {
        accountField.setLeftPaddingPoints(15)
        passwordField.setLeftPaddingPoints(15)
        checkField.setLeftPaddingPoints(15)
        textFieldBackground.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        textFieldBackground.layer.borderWidth = 1
        textFieldBackground.layer.cornerRadius = 5
        textFieldBackground.layer.masksToBounds = true
        textFieldBackground.clipsToBounds = true
        nextBtn.layer.cornerRadius = 5
        nextBtn.layer.masksToBounds = true
        nextBtn.clipsToBounds = true
        let attributeString = NSMutableAttributedString(string: "你已同意本公司之隐私权用户协议",
                                                        attributes: btnAttributes)
        checkBtn.setAttributedTitle(attributeString, for: .normal)
    }
}
