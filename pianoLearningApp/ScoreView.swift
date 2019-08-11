//
//  ScrollView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 29/07/2019.
//  Copyright © 2019 ENYUHUANG. All rights reserved.
//

import UIKit

protocol ScoreViewDelegate {
    func unClickAllPianoKey()
    func getProgress(value: Float)
    func lightPianoKey(note: Int)
    func didFinishWholeSheet()
}

class ScoreView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topSpaceView: UIView!
    @IBOutlet weak var musicScoreViewA: MusicScoreView!
    @IBOutlet weak var musicScoreViewB: MusicScoreView!
    @IBOutlet weak var bottomSpaceView: UIView!
    
    var delegate: ScoreViewDelegate!
    private var _isPlaying = false
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
    private var nowScoreIndex = 0 // 跑到哪一個scoreView(0: 上面 1:下面)
    private var shouldNoteIndex = 0 // 現在五線譜跑到目前小節中第n個音符 (判斷目前要亮的按鍵)
    private var order = 0   // scroeViews下一次產生時起始小節
//    private
//    private
    
    
    func hide() {
        self.musicScoreViewA.isHidden = true
        self.musicScoreViewB.isHidden = true
    }
    
    func isPlaying() -> Bool {
        return self._isPlaying
    }
    
    func play() {
        if self.nowScoreIndex == 0 {
            self.musicScoreViewA.startBar()
        }else {
            self.musicScoreViewB.startBar()
        }
    }
    
    func pause() {
        if self.nowScoreIndex == 0 {
            self.musicScoreViewA.pauseBar()
        }else {
            self.musicScoreViewB.pauseBar()
        }
    }
    
    func stop() {
        self.musicScoreViewA.stopBar()
        self.musicScoreViewB.stopBar()
    }
    
    func shouldResizeScoreView(completeHandler: () -> Void) {
        completeHandler()
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
        self.delegate.unClickAllPianoKey()
        if (nowSegs >= allSegs-1) {
            if self.nowScoreView < self.allScoreViewCount {
                if nowScoreIndex != 1 {
                    self.musicScoreViewB.startBar()
                }else {
                    self.musicScoreViewA.startBar()
                }
            }else {
//                if self.isRecording{
//
//                    self.isRecording = false
//                    self.setMain_tempplay_Btn(.Recorded)
//                    self.showActionAlertView(.PLAY_FINISHED)
//                    var allCount = 0
//                    var failedCount = 0
//                    for bars in self.jsonArray! {
//                        for bar in bars {
//                            allCount += 1
//                            if bar[0]["play"] == "false" {
//                                failedCount += 1
//                            }
//                        }
//                    }
//                    self.allCount = allCount
//                    self.failedCount = failedCount
//                }
                self._isPlaying = false
                self.allScoreViewCount = 1
                self.nowScoreIndex = 0
                self.order = 0
                self.nowSegs = 0
                self.allSegs = 0
                self.musicScoreViewA.stopBar()
                self.musicScoreViewB.stopBar()
                Metronome.shared.stop()
            }
        }
    }
    
    func shouldPlayNext() {
        self.delegate.unClickAllPianoKey()
        if nowScoreView % 2 == 0 {
            // 播放下面樂譜
            if hasMoreScore{
                musicScoreViewB.startBar()
            }
            
            // 載入下一條的樂譜
            if nowSegs < allSegs - 1 {
                hasMoreScore = true
                // 載入樂譜
                let scoreViewN = musicScoreViewA.setScore(in: jsonArray!, start:nowSegs+1, order:nowScoreView+2, isFirst:false, isLast: false)
                nowSegs = musicScoreViewA.setScore(in: jsonArray!, start:nowSegs+1, order:nowScoreView+2, isFirst:false, isLast: scoreViewN>=allSegs-1)
                
                
            }else{
                hasMoreScore = false
            }
        }else {
            // 播放上面樂譜
            if hasMoreScore {
                musicScoreViewA.startBar()
            }
            
            // 載入下一條的樂譜
            if nowSegs < allSegs - 1 {
                hasMoreScore = true
                // 載入樂譜
                let score2ViewN = musicScoreViewB.setScore(in: jsonArray!, start:nowSegs+1, order:nowScoreView+2, isFirst:false, isLast: false)
                nowSegs = musicScoreViewB.setScore(in: jsonArray!, start:nowSegs+1, order:nowScoreView+2, isFirst:false, isLast: score2ViewN>=allSegs-1)
            }else{
                hasMoreScore = false
            }
        }
        nowScoreView = nowScoreView + 1
    }
    
    func noteShouldPlay(scoreIndex: Int, pitch: Int, time: Float, barIndex: Int, NoteIndex: Int) {
        if NoteIndex != self.shouldNoteIndex || self.nowBarIndex != barIndex || NoteIndex == 0{
            self.delegate.unClickAllPianoKey()
            // 記錄上一個小節
            self.lastBarIndex = self.nowBarIndex
            // 更新目前小節
            self.nowBarIndex = barIndex + 1
            // 記錄已跑全部小節中第幾小節
            if (self.nowBarIndex == 1 && self.lastBarIndex != 1){
                self.didBarIndex += 1
            }else {
                self.didBarIndex += (self.nowBarIndex - self.lastBarIndex)
            }
            // 記錄已跑多少音符並送出
            self.nowNoteCount += 1
            self.delegate.getProgress(value: Float(self.nowNoteCount) / Float(self.allNoteCount))
            self.shouldNoteIndex = NoteIndex
            self.nowScoreIndex = scoreIndex % 2
            self.nowScoreView = scoreIndex
            self.delegate.lightPianoKey(note: pitch)
        }
    }
    
    
}
