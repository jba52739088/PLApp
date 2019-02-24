//
//  AlertView.swift
//  pianoLearningApp
//

import UIKit

protocol pwdAlertViewDelegate {
    func didTapCancelButton()
    func didTapSendButton()
}

class PwdAlertView: UIView {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var textField: UITextField!
//    @IBOutlet weak var button: UIButton!
    
    var delegate: pwdAlertViewDelegate!
    

    @IBAction func tapCancelButton(_ sender: Any) {
        self.delegate.didTapCancelButton()
    }
    
    @IBAction func tapSendButton(_ sender: Any) {
        self.delegate.didTapSendButton()
    }
    
    func initAlert() {
        textField.setLeftPaddingPoints(15)
        textField.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.clipsToBounds = true
        alertView.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        alertView.layer.borderWidth = 1
        alertView.layer.cornerRadius = 5
        alertView.layer.masksToBounds = true
        alertView.clipsToBounds = true
//        button.layer.masksToBounds = true
//        button.layer.cornerRadius = 5
//        button.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
//        button.layer.borderWidth = 1
//        button.clipsToBounds = true
    }
}


