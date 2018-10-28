//
//  RegisterStep2View.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/2.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class RegisterStep2View: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var birthField: UITextField!
    @IBOutlet weak var adressField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var agreeBtn: UIButton!
    
    weak var registerStep1VC: RegisterStep1VC!
    let datePicker = UIDatePicker()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initView() {
        birthField.setLeftPaddingPoints(15)
        adressField.setLeftPaddingPoints(15)
        phoneField.setLeftPaddingPoints(15)
        textFieldBackground.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        textFieldBackground.layer.borderWidth = 1
        textFieldBackground.layer.cornerRadius = 5
        textFieldBackground.layer.masksToBounds = true
        textFieldBackground.clipsToBounds = true
        agreeBtn.layer.cornerRadius = 5
        agreeBtn.layer.masksToBounds = true
        agreeBtn.clipsToBounds = true
        showDatePickerForDateField()
    }
    
    @IBAction func tapAgreeBtn(_ sender: Any) {
        if let birth = birthField.text, let addr = adressField.text, let phone = phoneField.text, let acc = registerStep1VC.accountField.text, let pwd = registerStep1VC.passwordField.text{
            if birth == "" || addr == "" || phone == "" || acc == "" || pwd == ""{
                self.registerStep1VC.showAlertView(message: "请输入详细资料")
                return
            }
            
            APIManager.shared.register(name: acc, account: acc, password: pwd, birth: birth, mobile: phone, address: addr) { [weak self] (status) in
                if status {
                    let alertView: AlertView = Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)?.first as! AlertView
                    alertView.frame = self!.frame
                    alertView.initAlert(message: "已将确认连结寄到您的箱，\n烦请前往确认，谢谢！")
                    alertView.delegate = self
                    self!.addSubview(alertView)
                }else {
                    self!.registerStep1VC.showAlertView(message: "请输入详细资料")
                    return
                }
            }
        }
    }
    
    func showDatePickerForDateField() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)
        birthField.inputView = picker
    }
    
    
    @objc func updateDateField(sender: UIDatePicker) {
        birthField.text = formatDateForDisplay(date: sender.date)
    }
    
    fileprivate func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

}

extension RegisterStep2View: alertViewDelegate {
    
    func didTapButton() {
        self.removeFromSuperview()
        let loginVC = self.registerStep1VC.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        self.registerStep1VC.present(loginVC, animated: true, completion: nil)
    }
    
    
}
