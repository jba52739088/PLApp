//
//  GradesVC.swift
//  pianoLearningApp
//

import UIKit
import SwiftyJSON

class GradesVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var buttonBottomView: [UIView]!
    
    var TabBar: TabBarVC!
    var gradesLeftViewController: GradesLeftVC!
    var gradesRightViewController: GradesRightVC!
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0
    var delegate: NoteSelectionDelegate!

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
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
        let vc = viewControllers[selectedIndex]
        addChild(vc)
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    
    func configViewControllers() {
        for view in buttonBottomView {
            view.isHidden = true
        }
        gradesLeftViewController = self.storyboard?.instantiateViewController(withIdentifier: "gradesLeftVC") as! GradesLeftVC
        gradesRightViewController = self.storyboard?.instantiateViewController(withIdentifier: "gradesRightVC") as! GradesRightVC
        gradesRightViewController.parentVC = self
        viewControllers = [gradesLeftViewController, gradesRightViewController]
        buttonBottomView[selectedIndex].isHidden = false
        didTapTabBar(buttons[selectedIndex])
    }


}
