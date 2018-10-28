//
//  UserView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/13.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit



class UserView: UIView {

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet var iconSet: [UIImageView]!
    
    let iconNames = ["accounts_info_birth", "accounts_info_phone", "accounts_info_address", "accounts_info_edit"]
    let datePicker = UIDatePicker()
    var delegate: AccountPageDelegat?
    var isEditing = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    @IBAction func doModify(_ sender: UIButton) {
        if isEditing {
            self.delegate?.didModifyUserData(birth: self.birthTextField.text ?? "", phone: self.phoneTextField.text ?? "", address: self.addressTextField.text ?? ""){_ in
                self.initView()
            }
        }else {
            self.editingView()
        }
    }
    
    func initView() {
        for imgView in iconSet {
            imgView.image = UIImage(named: iconNames[imgView.tag])
        }
        accountTextField.isUserInteractionEnabled = false
        birthTextField.isUserInteractionEnabled = false
        phoneTextField.isUserInteractionEnabled = false
        addressTextField.isUserInteractionEnabled = false
        modifyButton.setTitle("     修改資料", for: .normal)
        accountTextField.text = My?.account
        birthTextField.text = My?.birth
        phoneTextField.text = My?.mobile
        addressTextField.text = My?.addr
        isEditing = false
        showDatePickerForDateField()
    }
    
    func editingView() {
        for imgView in iconSet {
            imgView.image = UIImage(named: iconNames[3])
        }
        birthTextField.isUserInteractionEnabled = true
        phoneTextField.isUserInteractionEnabled = true
        addressTextField.isUserInteractionEnabled = true
        modifyButton.setTitle("     修改完成", for: .normal)
        isEditing = true
    }
    
    func showDatePickerForDateField() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)
        picker.date = NSDate(dateString: birthTextField.text ?? "2018-01-01") as Date
        birthTextField.inputView = picker
    }
    
    
    @objc func updateDateField(sender: UIDatePicker) {
        birthTextField.text = formatDateForDisplay(date: sender.date)
    }
    
    fileprivate func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
}

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval: 0, since: d)
    }
}
