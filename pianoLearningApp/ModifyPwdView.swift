//
//  ModifyPwdView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/15.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class ModifyPwdView: UIView {

    @IBOutlet weak var oldPwdTextField: UITextField!
    @IBOutlet weak var oldPwdBtn: UIButton!
    @IBOutlet var oldPwdIncorrectViews: [UIView]!
    @IBOutlet weak var newPwdTextField: UITextField!
    @IBOutlet weak var re_newPwdTextField: UITextField!
    @IBOutlet weak var modifyBtn: UIButton!
    @IBOutlet weak var checkNewPwdImage: UIImageView!
    @IBOutlet weak var checkNewPwdLabel: UILabel!
    @IBOutlet var newPwdIncorrectViews: [UIView]!
    @IBOutlet var reightSideViews: [UIView]!
    
    var delegate: AccountPageDelegat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
        
    }
    
    @IBAction func ToCheckOldPwd(_ sender: Any) {
        oldPwdTextField.resignFirstResponder()
        newPwdTextField.resignFirstResponder()
        re_newPwdTextField.resignFirstResponder()
        if let pwd = self.oldPwdTextField.text, let correctPwd = My?.passwd{
            if pwd == "" || pwd != correctPwd {
                for view in oldPwdIncorrectViews {
                    view.isHidden = false
                }
                self.oldPwdTextField.background = UIImage(named: "accounts_password_enterbar_error")
            }else if pwd != "" && pwd == correctPwd{
                self.oldPwdTextField.background = UIImage(named: "accounts_password_enterbar")
                for view in oldPwdIncorrectViews {
                    view.isHidden = true
                }
                self.didEnterCorrectPwd()
            }
        }
    }
    
    @IBAction func toModifyPassword(_ sender: Any) {
        oldPwdTextField.resignFirstResponder()
        newPwdTextField.resignFirstResponder()
        re_newPwdTextField.resignFirstResponder()
        if let newPwd = self.newPwdTextField.text,
            let re_newPwd = self.re_newPwdTextField.text {
            if newPwd != "" && newPwd == re_newPwd {
                self.delegate?.didModifyPassword(password: newPwd, completionHandler: { (isSucceed) in
                    if isSucceed {
                        self.checkNewPwdLabel.text = "您的密码已更新成功!!!"
                        self.checkNewPwdImage.image = UIImage(named: "accounts_password_finish")
                        for view in self.newPwdIncorrectViews {
                            view.isHidden = false
                        }
                    }else {
                        self.checkNewPwdLabel.text = "密码不符"
                        self.checkNewPwdImage.image = UIImage(named: "accounts_password_error")
                        for view in self.newPwdIncorrectViews {
                            view.isHidden = false
                        }
                    }
                })
            }else {
                self.checkNewPwdLabel.text = "密码不符"
                self.checkNewPwdImage.image = UIImage(named: "accounts_password_error")
                for view in self.newPwdIncorrectViews {
                    view.isHidden = false
                }
            }
        }
    }
    
    func initView() {
        oldPwdTextField.setLeftPaddingPoints(15)
        newPwdTextField.setLeftPaddingPoints(15)
        re_newPwdTextField.setLeftPaddingPoints(15)
        for view in oldPwdIncorrectViews {
            view.isHidden = true
        }
        for view in newPwdIncorrectViews {
            view.isHidden = true
        }
        
        for view in reightSideViews {
            view.alpha = 0.3
            view.isUserInteractionEnabled = false
        }
    }
    
    func didEnterCorrectPwd() {
        for view in oldPwdIncorrectViews {
            view.isHidden = true
        }
        for view in newPwdIncorrectViews {
            view.isHidden = true
        }
        
        for view in reightSideViews {
            view.alpha = 1
            view.isUserInteractionEnabled = true
        }
    }
}
