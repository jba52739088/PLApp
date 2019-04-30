//
//  ViewController.swift
//  MusicTest1
//
//  Created by 趙令文 on 2018/9/6.
//  Copyright © 2018年 趙令文. All rights reserved.
//

import UIKit

protocol NoteSelectionDelegate {
    func didSelectNote(name: String)
}

class NoteSelectionVC: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var btnLevels: [UIButton]!
    @IBOutlet weak var btnBook1: UIButton!
    
    var delegate: NoteSelectionDelegate!
    var TabBar: TabBarVC!
    var listView: NoteSelectionListView!
    var notesArray: [String] = []
    var downloadedNotesArray: [String] = []
    var downloadView: BookDownloadView!
    var searchView: SearchView!
    var didSelectLevel = 1
    var didSelectBook = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()

        
        backBtn.isUserInteractionEnabled = false
        backBtn.isHidden = true
    }
    
    func readBookData() {
        
    }
    
    @IBAction func didSelectLevel(_ sender: UIButton) {
        self.didSelectLevel = sender.tag
    }
    
    
    @IBAction func delectSelectBook(_ sender: UIButton) {
        self.didSelectBook = sender.tag
        if (self.didSelectLevel == 1 && self.didSelectBook == 0) {
            notesArray = ["score1", "score2", "score3"]
        }else {
//            notesArray = downloadedNotesArray
            notesArray = []
            SQLiteManager.shared.loadSheets(level: "\(self.didSelectLevel)", book: "\(self.didSelectBook)") { (sheets) in
                for sheet in sheets {
                    notesArray.append(sheet.name)
                }
            }
        }
        listView = Bundle.main.loadNibNamed("NoteSelectionListView", owner: self, options: nil)?.first as! NoteSelectionListView
        listView.frame = self.backGroundView.bounds
        listView.tableView.delegate = self
        listView.tableView.dataSource = self
        listView.tableView.register(UINib(nibName: "NoteSelectionCell", bundle: nil), forCellReuseIdentifier: "NoteSelectionCell")
        listView.tableView.layoutSubviews()
        let gradient = CAGradientLayer()
        gradient.frame = listView.tableView.superview?.bounds ?? .null
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 0.8, 0.9, 1.0]
        listView.tableView.superview?.layer.mask = gradient
        listView.tableView.backgroundColor = .clear
        self.backGroundView.addSubview(listView)
        self.view.bringSubview(toFront: self.backGroundView)
        backBtn.isUserInteractionEnabled = true
        backBtn.isHidden = false
    }
    
    @IBAction func didTapBackToBookBtn(_ sender: Any) {
        if listView != nil {
            listView.removeFromSuperview()
            listView = nil
            backBtn.isUserInteractionEnabled = false
            backBtn.isHidden = true
            self.view.sendSubview(toBack: self.backGroundView)
        }
    }
    
    @IBAction func didTapBookDownload(_ sender: UIButton) {
        downloadView = Bundle.main.loadNibNamed("BookDownloadView", owner: self, options: nil)?.first as? BookDownloadView
        downloadView.frame = self.view.frame
        downloadView.delegate = self
        downloadView.initView(level: "学阶I :book1-1")
        self.view.addSubview(downloadView)
    }
    
    @IBAction func didTapSearchBtn(_ sender: UIButton) {
        searchView = Bundle.main.loadNibNamed("SearchView", owner: self, options: nil)?.first as? SearchView
        searchView.frame = self.view.frame
//        searchView.delegate = self
//        downloadView.initView(level: "学阶II :book1-3")
        self.view.addSubview(searchView)
    }
}

extension NoteSelectionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NoteSelectionCell = tableView.dequeueReusableCell(withIdentifier: "NoteSelectionCell", for: indexPath) as! NoteSelectionCell
        cell.textLabel?.text = "\(indexPath.row).  \(self.notesArray[indexPath.row])"
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sheetName = "\(self.didSelectLevel)_\(self.didSelectBook)_\(self.notesArray[indexPath.row])"
        self.delegate.didSelectNote(name: sheetName)
        UserDefaults.standard.set(sheetName, forKey: PIANO_LAST_NOTE_NAME)
        UserDefaults.standard.synchronize()
        self.didTapBackToBookBtn(self)
        self.TabBar.jumpToViewControllerBy(tag: 0)
    }
    
    
}

extension NoteSelectionVC: BookDownloadDelegate {
    func didTapButton() {
        if self.downloadView != nil {
            self.downloadView.removeFromSuperview()
            APIManager.shared.getSongDataOnline { (bool, scoreNames) in
                if (bool && scoreNames != nil) {
//                    self.downloadedNotesArray = scoreNames!
                    let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(scoreNames![0]).png")
                    let image    = UIImage(contentsOfFile: fileUrl.path)
                    self.btnBook1.setImage(image, for: .normal)
                    for scoreName in scoreNames! {
                        let score = scoreName.components(separatedBy: "_")
                        let sheet = Sheet(name: score[2],
                                          level: score[0],
                                          book: score[1],
                                          isDownloaded: true,
                                          completion: 0,
                                          recorded: "")
                        if !SQLiteManager.shared.insertSheetInfo(sheet) {
                            print("insertSheetInfo: \(scoreName) faild")
                        }
                    }
                    
                }
            }
        }
    }
    
    
}
