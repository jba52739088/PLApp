//
//  GradesLeftVC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/21.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class GradesLeftVC: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var didSelectButton = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButtons()
        setTableView()
    }
    
    func initButtons() {
        for btn in self.buttons {
            if btn.tag != 0 {
                btn.setImage(UIImage(named: "sheets_level\(btn.tag + 1)_lock"), for: .normal)
            }
        }
    }
    
    func setTableView() {
        tableView.register(UINib(nibName: "HighScoreCell", bundle: nil), forCellReuseIdentifier: "HighScoreCell")
        tableView.layoutSubviews()
        let gradient = CAGradientLayer()
        gradient.frame = tableView.superview?.bounds ?? .null
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 0.8, 0.9, 1.0]
        tableView.superview?.layer.mask = gradient
        tableView.backgroundColor = .clear
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        self.buttons[didSelectButton].setImage(UIImage(named: "sheets_level\(didSelectButton + 1)_lock"), for: .normal)
        didSelectButton = sender.tag
        self.buttons[didSelectButton].setImage(UIImage(named: "sheets_level\(didSelectButton + 1)"), for: .normal)
    }
    
}

//MARK: - UITableView
extension GradesLeftVC:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:HighScoreCell = tableView.dequeueReusableCell(withIdentifier: "HighScoreCell", for: indexPath) as! HighScoreCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
