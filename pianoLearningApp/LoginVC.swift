//
//  LoginVC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/1.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgetPwdBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    let btnAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20),
        NSAttributedStringKey.foregroundColor : UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1),
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }


    @IBAction func tapLogin(_ sender: Any) {
        
    }
    
    @IBAction func tapForgetBtn(_ sender: Any) {
        
    }
    
    @IBAction func tapRegisterBtn(_ sender: Any) {
        
    }
    
    func initView() {
        accountField.setLeftPaddingPoints(15)
        passwordField.setLeftPaddingPoints(15)
        textFieldBackground.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        textFieldBackground.layer.borderWidth = 1
        textFieldBackground.layer.cornerRadius = 5
        textFieldBackground.layer.masksToBounds = true
        textFieldBackground.clipsToBounds = true
        loginBtn.layer.cornerRadius = 5
        loginBtn.layer.masksToBounds = true
        loginBtn.clipsToBounds = true
        registerBtn.layer.cornerRadius = 5
        registerBtn.layer.masksToBounds = true
        registerBtn.clipsToBounds = true
        let attributeString = NSMutableAttributedString(string: "忘记密码了吗？",
                                                        attributes: btnAttributes)
        forgetPwdBtn.setAttributedTitle(attributeString, for: .normal)
    }
}



extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
