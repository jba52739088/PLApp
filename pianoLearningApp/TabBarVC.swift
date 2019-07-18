//
//  TabBarVC.swift
//  pianoLearningApp
//


import UIKit

class TabBarVC: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var buttonBottomView: [UIView]!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var playViewController: musicNotePlayVC!
    var sheetsViewController: NoteSelectionVC!
    var gradesViewController: GradesVC!
    var accountViewController: UIViewController!
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.TabBar = self
        configViewControllers()
        
    }
    
    @IBAction func didTapTabBar(_ sender: UIButton) {
        self.jumpToViewControllerBy(tag: sender.tag)
    }
    
    func jumpToViewControllerBy(tag: Int) {
        let previousIndex = selectedIndex
        selectedIndex = tag
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
        playViewController = self.storyboard?.instantiateViewController(withIdentifier: "musicNotePlayVC") as! musicNotePlayVC
        sheetsViewController = self.storyboard?.instantiateViewController(withIdentifier: "sheetsVC") as! NoteSelectionVC
        gradesViewController = self.storyboard?.instantiateViewController(withIdentifier: "gradesVC") as! GradesVC
        accountViewController = self.storyboard?.instantiateViewController(withIdentifier: "accountVC")
        sheetsViewController.TabBar = self
        sheetsViewController.delegate = playViewController
        gradesViewController.delegate = playViewController
        viewControllers = [playViewController, sheetsViewController, gradesViewController, accountViewController]
        buttonBottomView[selectedIndex].isHidden = false
        didTapTabBar(buttons[selectedIndex])
    }


}
