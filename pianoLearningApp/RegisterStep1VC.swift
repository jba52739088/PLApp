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
    
    var alertView: AlertView!
    
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
        if let acc = accountField.text, let pwd = passwordField.text, let checkPwd = checkField.text{
            if acc == "" || pwd == "" || checkPwd == "" {
                self.showAlertView(message: "请输入详细资料")
                return
            }else if !self.isValidEmail(testStr: acc) {
                print("account 非mail")
                self.showAlertView(message: "帐号非mail")
                return
            }else if !checkBox.isChecked {
                self.showAlertView(message: "请同意隐私权同意条款")
                return
            }else if pwd != checkPwd{
                self.showAlertView(message: "两次密码不同")
                return
            }
            APIManager.shared.accountIsExist(account: acc) { (status, data) in
                if status {
                    let registerStep2View: RegisterStep2View = Bundle.main.loadNibNamed("RegisterStep2View", owner: self, options: nil)?.first as! RegisterStep2View
                    registerStep2View.frame = self.view.frame
                    registerStep2View.initView()
                    registerStep2View.registerStep1VC = self
                    self.view.addSubview(registerStep2View)
                }else {
                    self.showAlertView(message: "帐号重复")
                    return
                }
            }
        }else {
            print("有栏位为空")
        }
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
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func showAlertView(message: String) {
        alertView = Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)?.first as? AlertView
        alertView.frame = self.view.frame
        alertView.initAlert(message: message)
        alertView.delegate = self
        alertView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.view.addSubview(alertView)
    }
}

extension RegisterStep1VC: alertViewDelegate {
    
    func didTapButton() {
        if self.alertView != nil {
            self.alertView.removeFromSuperview()
        }
        
    }
    
    
}
