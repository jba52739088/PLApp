//
//  DebugVC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 01/10/2019.
//  Copyright © 2019 ENYUHUANG. All rights reserved.
//

import UIKit
import AudioKit
import AVFoundation
import AVAudioSessionSetCategorySwift

class DebugVC: UIViewController {
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnLast: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet var btnSegArray: [UIButton]!
    @IBOutlet weak var scoreView: MusicScoreView!
    
    var allSegs = 0 // 所有小節數
    var nowSegs = 0       // 目前呈現到第n小節
    // 當前曲目名稱
    var currentSongName: String?
    var jsonArray: Array<Array<Array<Dictionary<String,String>>>>? // 譜data
    // 所有音符數
    var allNoteCount = 0
    // 錯誤的小節
    var wrongSegs: [Int] = []
    // 錯誤的[score: [小節]]
//    var wrongSeg: [[Int: [Int]]] = [[0: [2]], [0: [2]], [0: [2]], [0: [2]], [0: [2]], [0: [2]], [0: [2]], [0: [2]]]
    var wrongSeg: [[Int: [Int]]] = []
    // 目前顯示的最後一個錯誤按鈕
    var displayCount = 0
    // 每scoreView的seg數
    var segCountPerScore: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentSongName != nil {
            self.showUserScoreView(file: currentSongName!, isreadLocal: true)
        }
        
    }

    @IBAction func didClickPlayButton(_ sender: Any) {
        
    }
    
    @IBAction func didClickBackButton(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func didClickLast(_ sender: Any) {
        if self.displayCount < 4 { return }
        self.btnSegArray.forEach({$0.isHidden = false})
        self.displayCount  = Int(self.displayCount / 4) * 4 - 1
        for i in self.displayCount - 3 ... self.displayCount {
            self.btnSegArray[i % 4].setTitle("第\(self.wrongSegs[i] + 1)小節", for: .normal)
            self.btnSegArray[i % 4].setTitle("第\(self.wrongSegs[i] + 1)小節", for: .selected)
        }
        
    }
    
    @IBAction func didClickNext(_ sender: Any) {
        let firstCount = self.displayCount + 1
        if self.wrongSegs.count <= firstCount { return }
        let thisDisplayCount = ((firstCount + 3) -  self.wrongSegs.count - 1 ) >= 0 ? ((firstCount + 3)) : self.wrongSegs.count - 1
        
        
        if self.wrongSegs.count < firstCount + 3 {
            for i in 0 ..< self.btnSegArray.count {
                if i + 3 >= thisDisplayCount {
                    self.btnSegArray[i].isHidden = true
                }
            }
        }
        for i in firstCount ... thisDisplayCount {
            if !self.btnSegArray[i - firstCount].isHidden {
                self.btnSegArray[i - firstCount].setTitle("第\(self.wrongSegs[i] + 1)小節", for: .normal)
                self.btnSegArray[i - firstCount].setTitle("第\(self.wrongSegs[i] + 1)小節", for: .selected)
            }
        }
        self.displayCount = thisDisplayCount
    }
    
    @IBAction func didClickSegButton(_ sender: UIButton) {
        for btn in self.btnSegArray {
            btn.isSelected = false
        }
        sender.isSelected = true
        var first = 0
        if self.displayCount > 4 {
            first = Int(self.displayCount / 4) * 4
        }
        let scoreOrder = self.wrongSeg[first + sender.tag].keys.first ?? 0
        let start = scoreOrder == 0 ? 0 : self.segCountPerScore[scoreOrder - 1] + 1
        let _ = scoreView.setScore(in: self.jsonArray!,
                                   start: start,
                                   order: scoreOrder, isFirst: (first + sender.tag) == 0,
                                   isLast: self.segCountPerScore.count == (first + sender.tag))
        scoreView.setErrSegs(errorSegments: self.wrongSeg[first + sender.tag])
    }
    
    func setSongName(_ name: String) {
        currentSongName = name
    }
}

extension DebugVC {
    // 除錯
    func showUserScoreView(file: String, isreadLocal: Bool) {
        
        allSegs = 0 // 計算出所有小節
        nowSegs = 0 // 目前呈現的小節數
        // 讀取 JSON 字串資料
        var thisUrl = Bundle.main.url(forResource: file, withExtension: "json")
        if thisUrl == nil {
            thisUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(file).json")
        }
        self.currentSongName = file
        guard let url = thisUrl else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Array<Array<Array<Dictionary<String,String>>>>
            
            // 計算共幾個小節
            self.jsonArray = jsonArray
            allSegs = jsonArray.count
            // 計算共幾個音符
            for items in jsonArray {
                for item in items {
                    self.allNoteCount += item.count
                }
            }
            // 載入樂譜有幾列, 需要幾個 ScoreView
            var order = 0
            nowSegs = scoreView.setScore(in: jsonArray, start: nowSegs, order: order, isFirst: true, isLast: nowSegs>=allSegs-1)
            self.segCountPerScore.append(nowSegs)
            while nowSegs < allSegs - 1 {
                order += 1
                let count = scoreView.setScore(in: jsonArray, start: nowSegs + 1, order: order, isFirst: false, isLast: nowSegs>=allSegs-1)
                nowSegs = scoreView.setScore(in: jsonArray, start:nowSegs + 1, order: order, isFirst: false, isLast: count>=allSegs-1)
                self.segCountPerScore.append(nowSegs)
            }
            print("self.segCountPerScore: \(self.segCountPerScore)")
            let _ = scoreView.setScore(in: jsonArray, start: 0, order: 0, isFirst: true, isLast: self.segCountPerScore.count == 1)
            let wrongSeg = scoreView.setPlayScoreView(in: jsonArray)
            self.wrongSegs = wrongSeg
            self.configView()
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    private func configView() {
        let _wrongSeg = scoreView.getWrongSeg()

        for i in 0 ..< _wrongSeg.count {
            for item in _wrongSeg[i] ?? [] {
                self.wrongSeg.append([i: [item]])
            }
        }
        
        if self.wrongSegs.count < 4 {
            for i in 0 ..< self.btnSegArray.count {
                if i > self.wrongSegs.count - 1 {
                    self.btnSegArray[i].isHidden = true
                }else {
                    self.btnSegArray[i].setTitle("第\(self.wrongSegs[i] + 1)小節", for: .normal)
                    self.btnSegArray[i].setTitle("第\(self.wrongSegs[i] + 1)小節", for: .selected)
                    self.displayCount = i
                }
            }
        }else {
            for i in 0 ..< self.btnSegArray.count {
                self.btnSegArray[i].setTitle("第\(self.wrongSegs[i] + 1)小節", for: .normal)
                self.btnSegArray[i].setTitle("第\(self.wrongSegs[i] + 1)小節", for: .selected)
                self.displayCount = i
            }
        }
        self.didClickSegButton(self.btnSegArray[0])
    }
}
