//
//  GradesRightVC.swift
//  pianoLearningApp
//


import UIKit

class GradesRightVC: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var images: [UIImageView]!
    @IBOutlet var titles: [UILabel]!
    @IBOutlet weak var tableView: UITableView!
    
    
    var parentVC: GradesVC!
    var actionAlertView: ActionAlertView!
    var didSelectButton = 0
    var allScore: [String : Int] = [:]
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
    
    func configViewData() {
        guard self.parentVC != nil,
            self.parentVC._allScore != nil,
            self.parentVC._recentPlays != nil,
            self.parentVC._recentDates != nil
            else { return }
        switch self.parentVC.selectedIndex {
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
    }
    
    func showActionAlertView(songName: String) {
        actionAlertView = Bundle.main.loadNibNamed("ActionAlertView", owner: self, options: nil)?.first as? ActionAlertView
        actionAlertView.frame = self.view.frame
        actionAlertView.delegate = self
        actionAlertView.initAlert()
        actionAlertView.secondlabel.text = songName
        self.view.addSubview(actionAlertView)
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
        cell.delegate = self
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

extension GradesRightVC: praticeRecordCellDelegate {
    func didTapRecordBtn(songName: String?) {
        //
    }
    
    func didTapDeleteBtn(songName: String?) {
        guard songName != nil else { return }
        self.showActionAlertView(songName: songName!)
    }
    
    
}

extension GradesRightVC: actionAlertViewDelegate {
    func didTapLeftBtn() {
        if self.actionAlertView != nil {
            self.actionAlertView.removeFromSuperview()
        }
    }
    
    func didTapRightBtn() {
        if self.actionAlertView != nil {
            self.actionAlertView.removeFromSuperview()
        }
    }
    
    
    
    
}
