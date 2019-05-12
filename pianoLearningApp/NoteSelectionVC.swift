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
    @IBOutlet var btnBooks: [UIButton]!
    
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

        self.reloadLevelData()
        backBtn.isUserInteractionEnabled = false
        backBtn.isHidden = true
    }
    
    @IBAction func didSelectLevel(_ sender: UIButton) {
        self.didSelectLevel = sender.tag
        self.reloadLevelData()
    }
    
    
    @IBAction func delectSelectBook(_ sender: UIButton) {
        self.didSelectBook = sender.tag
        self.reloadBookData()
    }
    
    func reloadLevelData() {
        SQLiteManager.shared.loadBooks(level: self.didSelectLevel) { (books) in
            for book in books {
                if (book.bookLevel >= self.btnBooks.count) { return }
                if (book.isImgDownloaded) {
                    let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(book.name).png")
                    let image    = UIImage(contentsOfFile: fileUrl.path)
                    btnBooks[book.bookLevel].setImage(image, for: .normal)
                    btnBooks[book.bookLevel].imageView?.contentMode = .scaleAspectFill
                }else {
                    if APIManager.shared.getBookImage(level: book.level, bookName: book.name) {
                        SQLiteManager.shared.loadBookInfo(level: book.level, bookNo: book.bookLevel, completionHandler: { (aBook) in
                            let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(aBook.name).png")
                            let image    = UIImage(contentsOfFile: fileUrl.path)
                            btnBooks[aBook.bookLevel].setImage(image, for: .normal)
                            btnBooks[aBook.bookLevel].imageView?.contentMode = .scaleAspectFill
                        })
                    }
                }
                btnBooks[book.bookLevel].setTitle(book.name, for: .normal)
            }
        }
    }
    
    func reloadBookData() {
        notesArray = []
        SQLiteManager.shared.loadSheets(level: "\(self.didSelectLevel)", book: "\(self.didSelectBook)") { (sheets) in
            for sheet in sheets {
                notesArray.append(sheet.name)
            }
        }
        listView = Bundle.main.loadNibNamed("NoteSelectionListView", owner: self, options: nil)?.first as! NoteSelectionListView
        listView.frame = self.backGroundView.bounds
        listView.imgView.image = self.btnBooks[self.didSelectBook].imageView?.image
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
        cell.textLabel?.text = "\(indexPath.row + 1).  \(self.notesArray[indexPath.row])"
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
            if APIManager.shared.getSongDataOnline() {
                if self.listView != nil {
                    self.reloadLevelData()
                }else {
                    self.reloadLevelData()
                }
            }
        }
    }
    
    
}
