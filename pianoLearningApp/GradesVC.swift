//
//  GradesVC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/21.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class GradesVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var buttonBottomView: [UIView]!
    
    var gradesLeftViewController: UIViewController!
    var gradesRightViewController: UIViewController!
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
        gradesLeftViewController = self.storyboard?.instantiateViewController(withIdentifier: "gradesLeftVC") as! GradesLeftVC
        gradesRightViewController = self.storyboard?.instantiateViewController(withIdentifier: "gradesRightVC") as! GradesRightVC
        viewControllers = [gradesLeftViewController, gradesRightViewController]
        buttonBottomView[selectedIndex].isHidden = false
        didTapTabBar(buttons[selectedIndex])
    }


}
