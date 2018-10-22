//
//  GradesRightVC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/21.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class GradesRightVC: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var images: [UIImageView]!
    @IBOutlet var titles: [UILabel]!
    @IBOutlet weak var tableView: UITableView!
    
    var didSelectButton = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButtons()
        setTableView()
        
    }
    
    func initButtons() {
        
        for img in self.images {
            if img.tag != didSelectButton {
                img.image = UIImage(named: "grades_practice_level\(img.tag + 1) copy")
            }
        }
        
        for label in self.titles {
            if label.tag != didSelectButton {
                label.textColor = UIColor.darkText.withAlphaComponent(0.2)
            }
        }
    }
    
    func setTableView() {
        tableView.register(UINib(nibName: "praticeRecordCell", bundle: nil), forCellReuseIdentifier: "praticeRecordCell")
        tableView.layoutSubviews()
        let gradient = CAGradientLayer()
        gradient.frame = tableView.superview?.bounds ?? .null
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 0.8, 0.9, 1.0]
        tableView.superview?.layer.mask = gradient
        tableView.backgroundColor = .clear
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        self.images[didSelectButton].image = UIImage(named: "grades_practice_level\(didSelectButton + 1) copy")
        self.titles[didSelectButton].textColor = UIColor.darkText.withAlphaComponent(0.2)
        didSelectButton = sender.tag
        self.images[didSelectButton].image = UIImage(named: "grades_practice_level\(didSelectButton + 1)")
        self.titles[didSelectButton].textColor = UIColor.darkText.withAlphaComponent(1)
    }
    
    

}

//MARK: - UITableView
extension GradesRightVC:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:praticeRecordCell = tableView.dequeueReusableCell(withIdentifier: "praticeRecordCell", for: indexPath) as! praticeRecordCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
