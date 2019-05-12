//
//  GradesLeftVC.swift
//  pianoLearningApp
//

import UIKit

class GradesLeftVC: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var titleLabel_1: UILabel!
    @IBOutlet weak var titleLabel_2: UILabel!
    @IBOutlet weak var titleLabel_3: UILabel!
    
    var didSelectButton = 0
    var thisLevelSongs: [Sheet] = []
    var thisLevel = ""
    var recentDates = ""
    var recentPlays = ""
    var recentScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButtons()
        setTableView()
        configViewData()
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
        tableView.tableFooterView = UIView()
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
        configViewData()
    }
    
    func configViewData() {
        var level = ""
        switch self.didSelectButton {
        case 0:
            self.thisLevel = "Level I"
            level = "1"
        case 1:
            self.thisLevel = "Level II"
            level = "2"
        case 2:
            self.thisLevel = "Level III"
            level = "3"
        case 3:
            self.thisLevel = "Level IV"
            level = "4"
        case 4:
            self.thisLevel = "Level V"
            level = "5"
        default:
            self.thisLevel = "Level I"
            level = "1"
        }
        
        SQLiteManager.shared.loadSheets(level: level) { (sheets) in
            thisLevelSongs = sheets
            self.tableView.reloadData()
        }
        
        SQLiteManager.shared.loadRecent(level: Int(level) ?? 0) { (date, sheet, completion) in
            if date != "" {
                self.dateLabel.text = date.replace(target:"-",withString: "/")
                self.nameLabel.text =  self.thisLevel + "~" + sheet
                self.progressLabel.text = "\(completion) %"
                self.dateLabel.isHidden = false
                self.nameLabel.isHidden = false
                self.progressLabel.isHidden = false
                self.alertLabel.isHidden = true
                self.titleLabel_1.isHidden = false
                self.titleLabel_2.isHidden = false
                self.titleLabel_3.isHidden = false
            }else {
                self.dateLabel.isHidden = true
                self.nameLabel.isHidden = true
                self.progressLabel.isHidden = true
                self.alertLabel.isHidden = false
                self.titleLabel_1.isHidden = true
                self.titleLabel_2.isHidden = true
                self.titleLabel_3.isHidden = true
            }
        }
    }
    
}

//MARK: - UITableView
extension GradesLeftVC:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.thisLevelSongs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:HighScoreCell = tableView.dequeueReusableCell(withIdentifier: "HighScoreCell", for: indexPath) as! HighScoreCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.title.text = self.thisLevel + " ~ " + self.thisLevelSongs[indexPath.section].name
        cell.progress.text = "\(self.thisLevelSongs[indexPath.section].completion) %"
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

extension String{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
