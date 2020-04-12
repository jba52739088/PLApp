//
//  bookDownloadView.swift
//  pianoLearningApp
//
//  Created by Vincent_Huang on 2019/3/26.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import UIKit

protocol BookDownloadDelegate {
    func didTapButton()
}

class BookDownloadView: UIView {
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var levellabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    var delegate: BookDownloadDelegate!
    
    func initView(level: String) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeDownLoadView))
        self.backgroundView.addGestureRecognizer(tap)
        self.backgroundView.isUserInteractionEnabled = true
        downloadView.layer.cornerRadius = 5
        downloadView.layer.masksToBounds = true
        downloadView.clipsToBounds = true
        textField.setLeftPaddingPoints(15)
        textField.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        levellabel.text = level
    }
    
    func sendWrongDownloadCode() {
        textField.text = ""
        textField.placeholder = "重新输入序号"
        textField.layer.borderColor = UIColor.red.cgColor
    }
    
    @IBAction func tapButton(_ sender: Any) {
        self.delegate.didTapButton()
    }
    
    @objc func removeDownLoadView() {
        self.removeFromSuperview()
    }
}
