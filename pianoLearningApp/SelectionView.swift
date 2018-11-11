//
//  SelectionView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/30.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation
import UIKit

protocol SelectionViewDelegate {
    func didTapCancel()
    func playTest1()
    func playTest2()
}

class SelectionView: UIView {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var button_1: UIButton!
    @IBOutlet weak var button_2: UIButton!
    @IBOutlet weak var button_Cancel: UIButton!
    
    var delegate: SelectionViewDelegate!
    
    @IBAction func selectTest1(_ sender: Any) {
        self.delegate.playTest1()
    }
    
    @IBAction func selectTest2(_ sender: Any) {
        self.delegate.playTest2()
    }
    
    @IBAction func doCancel(_ sender: Any) {
        self.delegate.didTapCancel()
    }
    
    func initAlert(message: String) {
        alertView.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        alertView.layer.borderWidth = 1
        alertView.layer.cornerRadius = 5
        alertView.layer.masksToBounds = true
        alertView.clipsToBounds = true
        button_Cancel.layer.masksToBounds = true
        button_Cancel.layer.cornerRadius = 5
        button_Cancel.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        button_Cancel.layer.borderWidth = 1
        button_Cancel.clipsToBounds = true
    }
}
