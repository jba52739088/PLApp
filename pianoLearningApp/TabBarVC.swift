//
//  TabBarVC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/10.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class TabBarVC: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var buttonBottomView: [UIView]!
    
    var playViewController: UIViewController!
    var sheetsViewController: UIViewController!
    var gradesViewController: UIViewController!
    var accountViewController: UIViewController!
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        configViewControllers()
        
    }
    
    @IBAction func didTapTabBar(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        buttonBottomView[previousIndex].isHidden = true
        buttonBottomView[selectedIndex].isHidden = false
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        let vc = viewControllers[selectedIndex]
        addChildViewController(vc)
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    
    
    func configViewControllers() {
        for view in buttonBottomView {
            view.isHidden = true
        }
        playViewController = self.storyboard?.instantiateViewController(withIdentifier: "musicNotePlayVC")
        sheetsViewController = self.storyboard?.instantiateViewController(withIdentifier: "sheetsVC")
        gradesViewController = self.storyboard?.instantiateViewController(withIdentifier: "gradesVC")
        accountViewController = self.storyboard?.instantiateViewController(withIdentifier: "accountVC")
        viewControllers = [playViewController, sheetsViewController, gradesViewController, accountViewController]
        buttonBottomView[selectedIndex].isHidden = false
        didTapTabBar(buttons[selectedIndex])
    }


}
