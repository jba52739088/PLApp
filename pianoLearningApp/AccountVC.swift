//
//  accountVC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/13.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class AccountVC: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var buttonLabels: [UILabel]!
    var customviews: [UIView] = []
    var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomViews()
    }
    
    func setCustomViews() {
        let UserView: UserView = Bundle.main.loadNibNamed("UserView", owner: self, options: nil)?.first as! UserView
        UserView.frame = self.contentView.bounds
        customviews.append(UserView)
        let ModifyPwdView: ModifyPwdView = Bundle.main.loadNibNamed("ModifyPwdView", owner: self, options: nil)?.first as! ModifyPwdView
        ModifyPwdView.frame = self.contentView.bounds
        customviews.append(ModifyPwdView)
        let AddPhoto: AddPhoto = Bundle.main.loadNibNamed("AddPhoto", owner: self, options: nil)?.first as! AddPhoto
        AddPhoto.frame = self.contentView.bounds
        customviews.append(AddPhoto)
        let QAView: QAView = Bundle.main.loadNibNamed("QAView", owner: self, options: nil)?.first as! QAView
        QAView.frame = self.contentView.bounds
        customviews.append(QAView)
        let LanguageView: LanguageView = Bundle.main.loadNibNamed("LanguageView", owner: self, options: nil)?.first as! LanguageView
        LanguageView.frame = self.contentView.bounds
        customviews.append(LanguageView)
        let FeedbackView: FeedbackView = Bundle.main.loadNibNamed("FeedbackView", owner: self, options: nil)?.first as! FeedbackView
        FeedbackView.frame = self.contentView.bounds
        customviews.append(FeedbackView)
        let VolumeView: VolumeView = Bundle.main.loadNibNamed("VolumeView", owner: self, options: nil)?.first as! VolumeView
        VolumeView.frame = self.contentView.bounds
        customviews.append(VolumeView)
        didTapTabBar(buttons[selectedIndex])
    }
    
    @IBAction func didTapTabBar(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        let previousView = customviews[previousIndex]
        previousView.removeFromSuperview()
        let view = customviews[selectedIndex]
        view.frame = contentView.bounds
        contentView.addSubview(view)
        
    }
    
}
