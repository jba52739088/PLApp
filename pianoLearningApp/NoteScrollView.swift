//
//  NoteScrollView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/9/17.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import Foundation

class NoteScrollView: UIScrollView {
    
    var views:[MusicNoteView] = []
    var jsonArray: Array<Array<Array<Dictionary<String,String>>>> = []
    var allSegs = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        readJSON()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        readJSON()
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        setupNoteScrollView
    }
    
//    func createNoteViews() -> [MusicNoteView] {
//        let url = Bundle.main.url(forResource: "score2", withExtension: "json")
//        do {
//            let data = try Data(contentsOf: url!)
//            let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Array<Array<Array<Dictionary<String,String>>>>
//            let allSegs = jsonArray.count
//
////            var n = 0
////            while n < allSegs - 1 {
////                let view = MusicNoteView(frame: self.frame)
////                n = view.view_1.setScore(in: jsonArray, start: 0)
////            }
//
//            var n = scoreView.setScore(in: jsonArray, start:0)
//
//            if n<allSegs-1 {
//                scoreView.setNextScoreView(in: scoreView2)
//                scoreView2.isHidden = false
//                scoreView2.setConfig(in: 4, n2: 4, n3: 4, n4: 4)
//                scoreView2.setScore(in: jsonArray, start:n+1)
//            }
//
//
//        }catch{
//            print(error.localizedDescription)
//        }
//        return []
//    }
    
    func createNoteViews() -> [MusicNoteView] {
        readJSON()
//        let scoreViewFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height / 2)
//        var viewList: [MusicScoreView] = []
//        let firstScoreView = MusicScoreView(frame: scoreViewFrame)
//        firstScoreView.backgroundColor = UIColor.clear
//        firstScoreView.setConfig(in: 4, n2: 4, n3: 4, n4: 4)
//        var n = firstScoreView.setScore(in: jsonArray, start: 0)
//        viewList.append(firstScoreView)
//        while n <= allSegs - 1 {
//            print("n: \(n)")
//            let nextScoreView = MusicScoreView(frame: scoreViewFrame)
//            nextScoreView.backgroundColor = UIColor.clear
//            viewList[viewList.count - 1].setNextScoreView(in: nextScoreView)
//            nextScoreView.setConfig(in: 4, n2: 4, n3: 4, n4: 4)
//            n = nextScoreView.setScore(in: jsonArray, start: n + 1)
//            print("allSegs: \(allSegs), n: \(n)")
//            viewList.append(nextScoreView)
//        }
//        print("Listview.count: \(viewList.count)")
//
        
        
        
        
        
        
        let view1:MusicNoteView = Bundle.main.loadNibNamed("MusicNoteView", owner: self, options: nil)?.first as! MusicNoteView
//        view1.backgroundColor = UIColor.red
        view1.frame = self.frame
        view1.setStackView(count: 1, start: 0)
//        view1.setStackView(count: 1)
        let view2:MusicNoteView = Bundle.main.loadNibNamed("MusicNoteView", owner: self, options: nil)?.first as! MusicNoteView
        view2.backgroundColor = UIColor.yellow
        let view3:MusicNoteView = Bundle.main.loadNibNamed("MusicNoteView", owner: self, options: nil)?.first as! MusicNoteView
        view3.backgroundColor = UIColor.green
        let view4:MusicNoteView = Bundle.main.loadNibNamed("MusicNoteView", owner: self, options: nil)?.first as! MusicNoteView
        view4.backgroundColor = UIColor.gray
        let view5:MusicNoteView = Bundle.main.loadNibNamed("MusicNoteView", owner: self, options: nil)?.first as! MusicNoteView
        view5.backgroundColor = UIColor.blue
        return [view1, view2, view3, view4, view5]
    }
    
    func setupNoteScrollView(views : [UIView]) {
//        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.contentSize = CGSize(width: self.frame.width * CGFloat(views.count), height: self.frame.height)
        self.isPagingEnabled = true
        
        for i in 0 ..< views.count {
            views[i].frame = CGRect(x: self.frame.width * CGFloat(i), y: 0, width: self.frame.width, height: self.frame.height)
            self.addSubview(views[i])
        }
    }
    
    
    
    
    
    func readJSON() {
        // 讀取 JSON 字串資料
        let url = Bundle.main.url(forResource: "score2", withExtension: "json")
        do {
            let data = try Data(contentsOf: url!)
            jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Array<Array<Array<Dictionary<String,String>>>>
            allSegs = jsonArray.count
            print("allSegs: \(allSegs)")
        }catch{
            print(error.localizedDescription)
        }
    }
    
    

}


