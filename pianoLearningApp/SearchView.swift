//
//  SearchView.swift
//  pianoLearningApp
//
//  Created by Vincent_Huang on 2019/3/26.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import UIKit

class SearchView: UIView {

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var backGround: UIView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hightConstraint: NSLayoutConstraint!
    
    var searchText = ""
    var parent: NoteSelectionVC!
    var levelData: [String] = []
    var tableFilterData: [String: [Sheet]] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resultsView.isHidden = true
        self.searchBarView.layer.cornerRadius = 15
        self.searchBarView.layer.masksToBounds = true
        self.searchBarView.clipsToBounds = true
        self.resultsView.layer.cornerRadius = 15
        self.resultsView.layer.masksToBounds = true
        self.resultsView.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeSearchView))
        self.backGround.addGestureRecognizer(tapGesture)
        self.tableView.register(UINib(nibName: "SearchHeaderCell", bundle: nil), forCellReuseIdentifier: "headerCell")
        self.tableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.register(UINib(nibName: "SearchNothingCell", bundle: nil), forCellReuseIdentifier: "nothingCell")
        
        self.searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)


    }
    
    @IBAction func clickCancelBtn(_ sender: Any) {
        self.removeFromSuperview()
    }

    @objc func closeSearchView() {
        self.removeFromSuperview()
    }
}

extension SearchView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchText != "" && self.levelData.count == 0 {
            return 1
        }
        return self.levelData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchText != "" && self.levelData.count == 0 {
            return 1
        }
        return (tableFilterData[levelData[section]] ?? []).count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.searchText != "" && self.levelData.count == 0 {
            let cell:SearchNothingCell = tableView.dequeueReusableCell(withIdentifier: "nothingCell", for: indexPath) as! SearchNothingCell
            return cell
        }
        if indexPath.row == 0 {
            let cell:SearchHeaderCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! SearchHeaderCell
            cell.title.text = levelData[indexPath.section]
            cell.selectionStyle = .none
            return cell
        }else {
            let cell:SearchCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
            cell.title.text = levelData[indexPath.section]
            cell.name.text = tableFilterData[levelData[indexPath.section]]![indexPath.row - 1].name
            cell.name.highlight(searchedText: self.searchText, color: .orange)
            cell.selectionStyle = .none
            cell.aSheet = tableFilterData[levelData[indexPath.section]]![indexPath.row - 1]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thisSheet = tableFilterData[levelData[indexPath.section]]![indexPath.row - 1]
        let sheetName = "\(thisSheet.level)_\(thisSheet.book)_\(thisSheet.name)"
        self.parent.delegate.didSelectNote(name: sheetName)
        UserDefaults.standard.set(sheetName, forKey: PIANO_LAST_NOTE_NAME)
        UserDefaults.standard.synchronize()
        self.parent.didTapBackToBookBtn(self)
        self.parent.TabBar.jumpToViewControllerBy(tag: 0)
        self.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        hightConstraint.constant = tableView.contentSize.height
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        self.searchText  = self.searchField.text!
        
        if self.searchText.count >= 0 {
            resultsView.isHidden = false
            self.levelData = []
            self.tableFilterData = [:]
            SQLiteManager.shared.searchSheet(keyword: self.searchText) { (sheets) in
                if sheets.count != 0 {
                    var level_cn = ""
                    for sheet in sheets {
                        switch sheet.level {
                        case "1":
                            level_cn = "I"
                        case "2":
                            level_cn = "II"
                        case "3":
                            level_cn = "III"
                        case "4":
                            level_cn = "IV"
                        case "5":
                            level_cn = "V"
                        default:
                            print(".........?????")
                        }
                        if self.tableFilterData["学阶 \(level_cn)"] == nil {
                            self.levelData.append("学阶 \(level_cn)")
                            self.tableFilterData["学阶 \(level_cn)"] = [sheet]
                        }else {
                            self.tableFilterData["学阶 \(level_cn)"]?.append(sheet)
                        }
                    }
                }else {
                    self.levelData = []
                    self.tableFilterData = [:]
                }
            }
        }else{
            resultsView.isHidden = true
            self.levelData = []
            self.tableFilterData = [:]
            
        }
        tableView.reloadData()
    }

}

extension UILabel {
    
    func highlight(searchedText: String?, color: UIColor = .red) {
        guard let txtLabel = self.text?.lowercased(), let searchedText = searchedText?.lowercased() else {
            return
        }
        
        let attributeTxt = NSMutableAttributedString(string: txtLabel)
        let range: NSRange = attributeTxt.mutableString.range(of: searchedText, options: .caseInsensitive)
        
        attributeTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: color, range: range)
        
        self.attributedText = attributeTxt
    }
    
}
