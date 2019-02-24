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
    
    var gradesLeftViewController: GradesLeftVC!
    var gradesRightViewController: GradesRightVC!
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0
    
    var _allScore: [String : [String : Int]]!
    var _recentDates: [String : String]!
    var _recentPlays: [String : String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViewControllers()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getFakeJson()
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
        gradesLeftViewController.parentVC = self
        gradesRightViewController.parentVC = self
    }
    
    func getFakeJson() {
        if let path : String = Bundle.main.path(forResource: "FakeScore", ofType: "json") {
            let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
           if let json = JSON(parseJSON: jsonString!).dictionaryObject,
            let allScore = json["allScore"] as? [String : [String : Int]],
                let recentDates = json["recentDate"] as? [String : String],
                let recentPlays = json["recentPlay"] as? [String : String] {
            self._allScore = allScore
            self._recentDates = recentDates
            self._recentPlays = recentPlays
            gradesLeftViewController.configViewData()
            }
        }
    }


}
