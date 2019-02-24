//
//  QAView.swift
//  pianoLearningApp
//


import UIKit

class QAView: UIView {

    
    @IBAction func TapQABtn(_ sender: Any) {
        let QuestionView: QuestionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)?.first as! QuestionView
        QuestionView.frame = self.bounds
        self.addSubview(QuestionView)
        QuestionView.loadData()
    }
    
    @IBAction func tapSupportBtn(_ sender: Any) {
        let UserSupportView: UserSupportView = Bundle.main.loadNibNamed("UserSupportView", owner: self, options: nil)?.first as! UserSupportView
        UserSupportView.frame = self.bounds
        self.addSubview(UserSupportView)
        UserSupportView.loadData()
    }
}
