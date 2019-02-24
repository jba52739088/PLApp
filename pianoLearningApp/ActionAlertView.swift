//
//  AlertView.swift
//  pianoLearningApp
//


import UIKit

protocol actionAlertViewDelegate {
    func didTapLeftBtn()
    func didTapRightBtn()
}

class ActionAlertView: UIView {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var firstlabel: UILabel!
    @IBOutlet weak var secondlabel: UILabel!
    @IBOutlet weak var thirdlabel: UILabel!
    @IBOutlet weak var fourthlabel: UILabel!
    @IBOutlet var leftBtn: UIButton!
    @IBOutlet var rightBtn: UIButton!
    
    var delegate: actionAlertViewDelegate!
    
    
    @IBAction func tapLeft(sender: AnyObject) {
        self.delegate.didTapLeftBtn()
    }
    
    @IBAction func tapRight(sender: AnyObject) {
        self.delegate.didTapRightBtn()
    }
    
    func initAlert() {
        alertView.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        alertView.layer.borderWidth = 1
        alertView.layer.cornerRadius = 20
        alertView.layer.masksToBounds = true
        alertView.clipsToBounds = true
    }
}


