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
    
    var delegate: NoteSelectionDelegate!
    var TabBar: TabBarVC!
    var listView: NoteSelectionListView!
    var notesArray: [String] = []
   
    override func viewDidLoad() {
        super.viewDidLoad()

        
        backBtn.isUserInteractionEnabled = false
        backBtn.isHidden = true
    }
    
    func readBookData() {
        
    }
    
    @IBAction func delectSelectBook(_ sender: UIButton) {
        if sender.tag == 0 {
            notesArray = ["score1", "score2"]
        }else {
            notesArray = ["score3"]
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
    
}

extension NoteSelectionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NoteSelectionCell = tableView.dequeueReusableCell(withIdentifier: "NoteSelectionCell", for: indexPath) as! NoteSelectionCell
        cell.textLabel?.text = "\(indexPath.row).  Level I ~ Minuet In G Major"
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.didSelectNote(name: self.notesArray[indexPath.row])
        UserDefaults.standard.set(self.notesArray[indexPath.row], forKey: PIANO_LAST_NOTE_NAME)
        UserDefaults.standard.synchronize()
        self.didTapBackToBookBtn(self)
        self.TabBar.jumpToViewControllerBy(tag: 0)
    }
    
    
}
