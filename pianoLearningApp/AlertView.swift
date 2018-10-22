//
//  AlertView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/2.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

protocol alertViewDelegate {
    func didTapButton()
}

class AlertView: UIView {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var delegate: alertViewDelegate!
    

    @IBAction func tapButton(_ sender: Any) {
        self.delegate.didTapButton()
    }
    
    func initAlert(message: String) {
        alertView.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        alertView.layer.borderWidth = 1
        alertView.layer.cornerRadius = 5
        alertView.layer.masksToBounds = true
        alertView.clipsToBounds = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        label.text = message
    }
}


