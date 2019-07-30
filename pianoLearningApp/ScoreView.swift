//
//  ScrollView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 29/07/2019.
//  Copyright © 2019 ENYUHUANG. All rights reserved.
//

import UIKit

class ScoreView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topSpaceView: UIView!
    @IBOutlet weak var musicScoreViewA: MusicScoreView!
    @IBOutlet weak var musicScoreViewB: MusicScoreView!
    @IBOutlet weak var bottomSpaceView: UIView!
    
    private var jsonArray: Array<Array<Array<Dictionary<String,String>>>>? // 譜data
    private var allScoreViewCount = 0 // 需要的MusicScoreView量
    private var allSegs = 0 // 所有小節數
    private var nowSegs = 0       // 目前呈現到第n小節
    private var nowScoreView = 0     // 跑到第幾個scoreView
    private var hasMoreScore = false // 是否有下一個五線譜
    private var nowBarIndex = 0 // 現在跑到該scoreView第幾小節
    private var lastBarIndex = 0 // 上一音符跑到該scoreView第幾小節
    private var didBarIndex = 0 // 五線譜跑到全部小節中第幾小節
    private var allNoteCount = 0 // 所有音符數
    private var nowNoteCount = 0 // 目前彈到音符數
//    private
//    private
    
    
    func hide() {
        self.musicScoreViewA.isHidden = true
        self.musicScoreViewB.isHidden = true
    }
    
    // 顯示sroreView
    func showScoreView(file: String, playMode: Int, bmp: Float, completeHandler: (_ isSucceed: Bool) -> Void) {
        
        allScoreViewCount = 1
        allSegs = 0
        nowSegs = 0
        nowScoreView = 0
        hasMoreScore = false
        nowBarIndex = 0
        lastBarIndex = 0
        didBarIndex = 0
        allNoteCount = 0
        nowNoteCount = 0
        musicScoreViewA.setPlayMode(mode: playMode)
        musicScoreViewB.setPlayMode(mode: playMode)
        musicScoreViewA.setBeat(setBeat: bmp / 60)
        musicScoreViewB.setBeat(setBeat: bmp / 60)
        
        // 讀取 JSON 字串資料
        var thisUrl = Bundle.main.url(forResource: file, withExtension: "json")
        if thisUrl == nil {
            thisUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(file).json")
        }
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
            musicScoreViewA.setConfig(in: 3, n2: 4, n3: 3, n4: 4)
            musicScoreViewA.delegate = self
            musicScoreViewB.delegate = self
            // 載入樂譜有幾列, 需要幾個 ScoreView
            let lines = musicScoreViewA.getScoreViewCount(in: jsonArray)
            self.allScoreViewCount = lines
            // 載入第一條
            let scoreViewN = musicScoreViewA.setScore(in: jsonArray, start: nowSegs, order: 0, isFirst: true, isLast: nowSegs>=allSegs-1)
            nowSegs = musicScoreViewA.setScore(in: jsonArray, start: nowSegs, order: 0, isFirst: true, isLast: scoreViewN>=allSegs-1)
            
            // 載入第二條
            if nowSegs < allSegs - 1 {
                hasMoreScore = true
                musicScoreViewB.isHidden = false
                // 載入樂譜
                let score2ViewN = musicScoreViewB.setScore(in: jsonArray, start:nowSegs+1, order: 1, isFirst: false, isLast: nowSegs>=allSegs-1)
                nowSegs = musicScoreViewB.setScore(in: jsonArray, start:nowSegs+1, order: 1, isFirst: false, isLast: score2ViewN>=allSegs-1)
            }
            completeHandler(true)
        }catch{
            print("load file error:  \(error.localizedDescription)")
            completeHandler(false)
        }
    }
    
    func getAllScoreViewCount() -> Int {
        return self.allScoreViewCount
    }
    
    func getCurrentScoreView() -> Int {
        return self.nowScoreView
    }
    
}

extension ScoreView: MusicScoreViewDelegate {
    func didFinishPlay() {
        
    }
    
    func shouldPlayNext() {
        
    }
    
    func noteShouldPlay(scoreIndex: Int, pitch: Int, time: Float, barIndex: Int, NoteIndex: Int) {
        
    }
    
    
}
