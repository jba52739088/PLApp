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
    
    var parentVC: GradesVC!
    var didSelectButton = 0
    var allScore: Dictionary<String, Int> = [:]
    var allSong: [String] = []
    var thisLevel = ""
    var recentDates = ""
    var recentPlays = ""
    var recentScore = 0
    
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
        configViewData()
    }
    
    func configViewData() {
        guard self.parentVC != nil,
            self.parentVC._allScore != nil,
            self.parentVC._recentPlays != nil,
            self.parentVC._recentDates != nil
            else { return }
        switch self.didSelectButton {
        case 0:
            self.thisLevel = "Level I"
        case 1:
            self.thisLevel = "Level II"
        case 2:
            self.thisLevel = "Level III"
        case 3:
            self.thisLevel = "Level IV"
        case 4:
            self.thisLevel = "Level V"
        default:
            self.thisLevel = "Level I"
        }
        self.recentPlays = self.parentVC._recentPlays[self.thisLevel] ?? ""
        self.allScore = self.parentVC._allScore[self.thisLevel] ?? [:]
        self.recentScore = self.allScore[self.recentPlays] ?? 0
        self.recentDates = self.parentVC._recentDates[self.thisLevel] ?? ""
        self.allSong = self.allScore.keys.sorted()
        self.tableView.reloadData()
        self.dateLabel.text = self.recentDates
        self.nameLabel.text = self.thisLevel + " ~ " + self.recentPlays
        var score = 0
        for s in self.allScore.values.sorted() {
            score += s
        }
        self.progressLabel.text = "\(score / self.allSong.count) %"
    }
    
}

//MARK: - UITableView
extension GradesLeftVC:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.allSong.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:HighScoreCell = tableView.dequeueReusableCell(withIdentifier: "HighScoreCell", for: indexPath) as! HighScoreCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.title.text = self.thisLevel + " ~ " + self.allSong[indexPath.section]
        cell.progress.text = "\(self.allScore[self.allSong[indexPath.section]] ?? 0) %"
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
