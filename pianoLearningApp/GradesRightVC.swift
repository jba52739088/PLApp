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
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var parentVC: GradesVC!
    var actionAlertView: ActionAlertView!
    var didSelectButton = 0
    var thisLevelSongs: [Sheet] = []
    var thisLevel = ""
    var thisSheet: Sheet?
    var sheetRecordedData: [String] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButtons()
        setTableView()
        configViewData()
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
        tableView.register(UINib(nibName: "ASheetRecordCell", bundle: nil), forCellReuseIdentifier: "aSheetRecordCell")
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
        thisSheet = nil
        self.images[didSelectButton].image = UIImage(named: "grades_practice_level\(didSelectButton + 1) copy")
        self.titles[didSelectButton].textColor = UIColor.darkText.withAlphaComponent(0.2)
        didSelectButton = sender.tag
        self.images[didSelectButton].image = UIImage(named: "grades_practice_level\(didSelectButton + 1)")
        self.titles[didSelectButton].textColor = UIColor.darkText.withAlphaComponent(1)
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
        if (self.thisSheet == nil) {
            SQLiteManager.shared.loadSheets(level: level) { (sheets) in
                thisLevelSongs = sheets
                self.tableView.reloadData()
            }
        }else {
            self.sheetRecordedData = self.getSheetRecordedData(sheetName: "\(self.thisSheet!.level)_\(self.thisSheet!.book)_\(self.thisSheet!.name)")
            self.tableView.reloadData()
        }
        
    }
    
    func showActionAlertView(songName: String) {
        actionAlertView = Bundle.main.loadNibNamed("ActionAlertView", owner: self, options: nil)?.first as? ActionAlertView
        actionAlertView.frame = self.view.frame
        actionAlertView.delegate = self
        actionAlertView.initAlert()
        actionAlertView.secondlabel.text = songName
        self.view.addSubview(actionAlertView)
    }
    
    func getSheetRecordedData(sheetName: String) -> [String] {
        var sheetNames: [String] = []
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: documentsPath)
        let fileManager = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: url.path)!
        for element in enumerator.allObjects {
            if let name = element as? String, name.contains("\(sheetName)_"){
                sheetNames.append(name.replace(target: ".json", withString: ""))
            }
        }
        return sheetNames
    }
    
    func deleteSheetRecordedData(sheetName: String) -> Bool {
        let fileManager = FileManager.default
        let documentsUrl =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsPath = URL(fileURLWithPath: documentsUrl).path
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: documentsPath)
            for fileName in fileNames {
                if (fileName.contains("\(sheetName)")){
                    let filePathName = "\(documentsPath)/\(sheetName).json"
                    try fileManager.removeItem(atPath: filePathName)
                }
            }
        } catch {
            print("Could not clear temp folder: \(error)")
            return false
        }
        return true
    }
}

//MARK: - UITableView
extension GradesRightVC:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if thisSheet == nil {
             return self.thisLevelSongs.count
        }else {
            return self.sheetRecordedData.count + 1
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if thisSheet == nil {
            let cell:praticeRecordCell = tableView.dequeueReusableCell(withIdentifier: "praticeRecordCell", for: indexPath) as! praticeRecordCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.delegate = self
            let title = self.thisLevel + " ~ " + self.thisLevelSongs[indexPath.section].name
            cell.titleBtn.titleEdgeInsets.left = 10
            cell.titleBtn.contentHorizontalAlignment = .left
            cell.titleBtn.setTitle(title, for: .normal)
            cell.deleteBtn.isHidden = !(self.thisLevelSongs[indexPath.section].hasRecord)
            cell.thisSheet = self.thisLevelSongs[indexPath.section]
            return cell
        }else {
            if indexPath.section == 0 {
                let cell:praticeRecordCell = tableView.dequeueReusableCell(withIdentifier: "praticeRecordCell", for: indexPath) as! praticeRecordCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.delegate = self
                let title = self.thisLevel + " ~ " + thisSheet!.name
                cell.titleBtn.titleEdgeInsets.left = 10
                cell.titleBtn.contentHorizontalAlignment = .left
                cell.titleBtn.setTitle(title, for: .normal)
                cell.deleteBtn.isHidden = !(thisSheet!.hasRecord)
                cell.thisSheet = thisSheet!
                return cell
            }else {
                let cell:ASheetRecordCell = tableView.dequeueReusableCell(withIdentifier: "aSheetRecordCell", for: indexPath) as! ASheetRecordCell
                let nameArray = self.sheetRecordedData[indexPath.section - 1].components(separatedBy: "_")
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.dateLabel.text =  nameArray[3].replace(target: "-", withString: "/")
                let sSheet = Sheet(name: self.sheetRecordedData[indexPath.section - 1], level: thisSheet!.level, book: thisSheet!.book, isDownloaded: thisSheet!.isDownloaded, completion: thisSheet!.completion, recorded: thisSheet!.recorded)
                cell.delegate = self
                cell.thisSheet = sSheet
                return cell
            }
        }
        
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
    func didTapTitleBtn(sheet: Sheet) {
        self.thisSheet = sheet
        self.configViewData()
    }
    
    func didTapRecordBtn(sheet: Sheet) {
        let sheetName = "\(sheet.level)_\(sheet.book)_\(sheet.name)"
        self.parentVC.delegate.didSelectNote(name: sheetName)
        UserDefaults.standard.set(sheetName, forKey: PIANO_LAST_NOTE_NAME)
        UserDefaults.standard.synchronize()
        self.appDelegate.TabBar.jumpToViewControllerBy(tag: 0)
    }
    
    func didTapDeleteBtn(sheet: Sheet, songName: String?) {
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

extension GradesRightVC: ASheetRecordCellDelegate {
    func didTapFollowBtn(sheet: Sheet) {
        print("follow: \(sheet.name) ")
    }
    
    func didTapPraticeBtn(sheet: Sheet) {
        print("pratice: \(sheet.name) ")
    }
    
    func didTapRemoveBtn(sheet: Sheet) {
        if self.deleteSheetRecordedData(sheetName: sheet.name) {
            if let aSheet = SQLiteManager.shared.loadSheetInfo(level: thisSheet!.level, book: thisSheet!.book, name: thisSheet!.name) {
                if SQLiteManager.shared.updateSheetInfo(level: aSheet.level,
                                                        bookLevel: aSheet.book,
                                                        name: aSheet.name,
                                                        completion: aSheet.completion,
                                                        recorded: aSheet.recorded - 1) {
                    self.configViewData()
                }
            }
            
        }
    }
}
