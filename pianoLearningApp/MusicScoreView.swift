//
//  MusicScoreView.swift
//  MusicTest1
//
//  Created by 趙令文 on 2018/9/6.
//  Copyright © 2018年 趙令文. All rights reserved.
//

import UIKit
import AudioKit

protocol MusicScoreViewDelegate {
    func didFinishPlay()
    func shouldPlayNext()
    func noteShouldPlay(scoreIndex: Int, pitch: Int, time: Float, barIndex: Int, NoteIndex: Int)
}

let oscillator = AKOscillator()
let bank = AKOscillatorBank()
let envelope = AKAmplitudeEnvelope(oscillator)

class MusicScoreView: UIView {
    var delegate: MusicScoreViewDelegate?
    var viewW: CGFloat = 0
    var viewH: CGFloat = 0
    var unitH: CGFloat = 0
    var paddingH: CGFloat = 0
    var trebleW: CGFloat = 0    // 高(低)音記號
    var paddingTreble: CGFloat = 0 // 高(低)音記號水平間隔
    var numeralX: CGFloat = 0   // 節拍記號
    var noteW: CGFloat = 0
    var n1: Int = 4
    var n2: Int = 4
    var n3: Int = 4
    var n4: Int = 4
    var allSeg: Int = 0
    let noteHeads:[Float:String] =
        [0.03125:"quarter-head", 0.0625:"quarter-head",
         0.125:"quarter-head", 0.25:"quarter-head",
         0.5:"quarter-head", 1.0:"quarter-head",
         2:"half-head", 4:"whole-head"]
    let rnoteHeads:[Float:String] =
        [0.03125:"rquarter-head", 0.0625:"rquarter-head",
         0.125:"rquarter-head", 0.25:"rquarter-head",
         0.5:"rquarter-head", 1.0:"rquarter-head",
         2:"rhalf-head", 4:"rwhole-head"]
    
    let noteBodys:[Float:String] =
        [0.03125:"128th-", 0.0625:"64th-",
         0.125:"32nd-", 0.25:"16th-",
         0.5:"eighth-", 1.0:"quarter-",
         2.0:"quarter-", 4.0:"none"]
    let rnoteBodys:[Float:String] =
        [0.03125:"r128th-", 0.0625:"r64th-",
         0.125:"r32nd-", 0.25:"r16th-",
         0.5:"reighth-", 1.0:"quarter-",
         2.0:"quarter-", 4.0:"none"]
    let rests:[Float:String] =
        [0.03125:"128th-rest", 0.0625:"64th-rest",
         0.125:"32nd-rest", 0.25:"16th-rest",
         0.5:"eighth-rest", 1.0:"quarter-rest",
         2.0:"half-rest", 4.0:"whole-rest"]
    
    var isLastLeft = false
    
    var scoreArray: Array<Array<Array<Dictionary<String,String>>>>? = nil
    var noteArray: Array<Array<Bool>>? = nil
    
    var frameNow:CGRect? = nil
    var imageStandard = UIImage(named: "black_standard")
    var imageFail = UIImage(named: "black_fail")
    var imageTouch = UIImage(named: "black_touch")
    var barImageView:UIImageView? = nil
    var i = 0
    var k = 0
    var timer:Timer? = nil
    
    var drawX:CGFloat = 0
    var cdrawX:CGFloat = 0
    var barX:CGFloat = 0
    var steps:Array<CGFloat> = []
    var noteData:Array<(Int,Int)> = []
    var isFirstSeg = false
    var nextScoreView: MusicScoreView? = nil
    var isPause = false
    var isStart = false
    var beat:Float = 2.0
    var isFirstScoreView:Bool = false
    var isLastScoreView:Bool = false
    
    let noteNums: [Float:MIDINoteNumber] = [
        -34:0,-33.5:1,-33:2, -32.5:3,-32:4,-31:5,-30.5:6,-30:7,-29.5:8,-29:9,-28.5:10,-28:11,
        -27:12,-26.5:13,-26:14, -25.5:15,-25:16,-24:17,-23.5:18,-23:19,-22.5:20,-22:21,-21.5:22,-21:23,
        -20:24,-19.5:25,-19:26, -18.5:27,-18:28,-17:29,-16.5:30,-16:31,-15.5:32,-15:33,-14.5:34,-14:35,
        -13:36,-12.5:37,-12:38,-11.5:39,-11:40,-10:41,-9.5:42,-9:43,-8.5:44,-8:45,-7.5:46,-7:47,
        -6:48,-5.5:49,-5:50,-4.5:51,-4:52,-3:53,-2.5:54,-2:55,-1.5:56,-1:57,-0.5:58,0:59,
        1:60,1.5:61,2:62,2.5:63,3:64,4:65,4.5:66,5:67,5.5:68,6:69,6.5:70,7:71,
        8:72,8.5:73,9:74,9.5:75,10:76,11:77,11.5:78,12:79,12.5:80,13:81,13.5:82,14:83,
        15:84,15.5:85,16:86,16.5:87,17:88,18:89,18.5:90,19:91,19.5:92,20:93,20.5:94,21:95,
        22:96,22.5:97,23:98,23.5:99,24:100,25:101,25.5:102,26:103,26.5:104,27:105,27.5:106,28:107,
        29:108,29.5:109,30:110,30.5:111,31:112,32:113,32.5:114,33:115,33.5:116,34:117,34.5:118,35:119,
        36:120,36.5:121,37:122,37.5:123,38:124,39:125,39.5:126,40:127
    ]
    
    var scoreOrder:Int = 0
    var playMode = 0    // 0: 兩手; 1:左手; 2:右手
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            
            let t = context.ctm.inverted()
            context.concatenate(t)
            
            viewW = self.frame.size.width * 2
            viewH = self.frame.size.height * 2
            unitH = viewH / 20 // 3 + 4 + 6 + 4 + 3
            paddingH = viewW / 24
            trebleW = viewW / 16
            paddingTreble = trebleW / 8
            numeralX = paddingH + paddingTreble + trebleW + paddingTreble
            noteW = viewW / 48
            
            // 繪出基本的五線譜
            drawScore(in: context)
            barX = drawX
            // 讀取 scoreArray 來畫出音符
            var pos = drawX + noteW   // 初始 x 位置
            if (scoreArray != nil){
//                print("a score")
                steps = []
                noteData = []
                // 每一小節
                for s in 0..<scoreArray!.count {
                    let seg = scoreArray![s]
                    // 每一直行
                    for c in 0..<seg.count {
                        
                        let col = seg[c]
                        var lastTone = 99
                        var nMaxNote:Float = -99
                        
                        noteData.append((s,c))
                        
                        // 每個音符
                        for note in col {
                            var aNote:[String:String] = [:] // 加一空音符資料
                            
                            let mTone = Int(note["tone"]!)
                            let mNote = 4/Float(note["note"]!)!
                            let isDot = note["dot"] == "true"
                            let isSharp = note["sharp"] == "true"
                            var mRest:Float = 0.0
                            let isError = note["play"] == "false"
                            
                            aNote["note"] = note["tone"]!
                            aNote["note"] = note["note"]!
                            
                            // 休止符
                            if note["note"] == "-99" {
                                mRest = 4/Float(note["rest"]!)!
                                
                                // 處理時間間隔
                                nMaxNote = Float(note["rest"]!)!
                                
                                // 繪製休止符
                                drawRest(in: context, isBass: false, note: mRest, x: pos)
                            }else {
                                // 用來處理時間間隔, 找出最小的音符
                                if nMaxNote<Float(note["note"]!)! {
                                    if !isDot {
                                        nMaxNote = Float(note["note"]!)!
                                    }else{
                                        nMaxNote = Float(note["note"]!)! * 1.5
//                                        print("isDot:\(nMaxNote)")
                                    }
                                }
                                
                                // 繪製音符
                                if abs(lastTone - mTone!) == 1 {
                                    drawNote(in: context, tone: mTone!, note: Float(mNote),isNextTone: true, isSharp: isSharp, isDotted: isDot, x: pos,
                                             seg: s, col: c, isError: isError)
                                }else{
                                    drawNote(in: context, tone: mTone!, note: Float(mNote),isNextTone: false, isSharp: isSharp,
                                             isDotted:isDot, x: pos,
                                             seg: s, col: c, isError: isError)
                                }
                                lastTone = mTone!
                            }
                        }
                        
                        // 假設一拍為一秒
                        // 因為4分音符nMaxNote為4, 所以用 4 來除
                        // 最後一個除數, 是控制速度, 值越大速度越快, 相當於控制節拍
                        let num = Int(4/nMaxNote/0.015625/beat)
                        let dist = noteW*2/CGFloat(num)
                        let delay = Float(num) * Float(dist)
//                        print("\(s):\(c) => \(nMaxNote) => \(delay)")
                        for i in 1...num {
                            if i == 1 {
                                steps.append(dist * -1) // 用來判斷抵達下一col
                            }else{
                                steps.append(dist)
                            }
                        }
                        pos = pos + noteW*4
                    }
                    
                    // 每個 scoreView 的最後一小節, 不用再畫分隔線, 其他都要畫
                    if s < (scoreArray?.count)!-1 {
                        drawLine(in: context, x: pos - noteW*1)
                    }
                }
                
                if isFirstSeg {
                    initBar()
                }
            }
            context.restoreGState()
        }
    }
    
    func setBeat(setBeat: Float){
        beat = setBeat
        barImageView?.removeFromSuperview()
        setNeedsDisplay()
    }
    
    
    var didSet = false
    
    // 初始化進度條, 以及播放輸出
    func initBar(){
        if !didSet && isFirstSeg {
            AudioKit.output = bank
            bank.attackDuration = 0.05
            bank.decayDuration = 0.1
            bank.releaseDuration = 0.15
            bank.rampDuration = 1
            bank.vibratoRate = 0
            bank.vibratoDepth = 0
            
            let table = AKTable(.triangle, phase: 0, count:1024)
            bank.waveform = table
            didSet = true
        }
        
        
        do{
            try AudioKit.start()
        }catch{}
        
        // 第一個音符: (barX+noteW/2)/2
        // 第二個音符: (barX+noteW/2)/2+noteW*2
        // 所以間距為: noteW*2
        barImageView = UIImageView(image: imageTouch!)
        if !barImageView!.isDescendant(of: self) {
            addSubview(barImageView!)
        }
        barImageView?.isHidden = true;
        barImageView?.frame = CGRect(
            x: (barX+noteW/2)/2, y: CGFloat(0), width: noteW, height: viewH/2)
        
        frameNow = barImageView?.frame
        
        i = 0   // 起始 steps 的 index
        k = 0   // 音符資料noteData的 index
        
    }
    
    func setNextScoreView(in nextView: MusicScoreView){
        nextScoreView = nextView
    }
    
    // 設定目前播放進度位置
    @objc func setBarPos(){
        if isPause {return}
        if steps[i] < 0 {
            // 抵達下一個 col
            let (seg,col) = noteData[k]
            let nowNotes = scoreArray![seg][col]
            // 每個音符
            for note in nowNotes {
                let mTone:Int = Int(note["tone"]!)!
                let mNote:Float = 4/Float(note["note"]!)!
                let isDotted = note["note"] == "true"
                let isSharp = note["sharp"] == "true"
                
//                print("play => \(scoreOrder): \(mTone) : \(mNote)")
                
                if note["note"] != "-99" {
                    playNote(note: noteNums[Float(mTone)]!, isDotted: isDotted, isSharp: isSharp)
                }
                
                // 回傳
                // scoreOrder : 第幾個ScoreView
                // mTone : 音符
                // noteNums[mNote] : 音階
                // seg : 小節
                // col : 第幾個
                var meter = mTone
                if isDotted {
                    meter  = Int(meter * 1.5)
                }
                
                NotificationCenter.default.post(name: Notification.Name("nowNote"),
                                                object:(scoreOrder, mTone, noteNums[mNote], seg, col, isDotted, isSharp, meter))
                // delegate
//                print("play => \(scoreOrder): \(mTone) : \(mNote)")
                delegate?.noteShouldPlay(scoreIndex: scoreOrder, pitch: Int(noteNums[Float(mTone)] ?? 0), time: mNote, barIndex: seg, NoteIndex: col)
            }
//            print("----")
            k = k + 1
        }
        
        frameNow?.origin.x += abs(steps[i])
        barImageView?.frame = frameNow!
        if i == steps.count-1 {
            // 播放完畢
            NotificationCenter.default.post(name: Notification.Name("stop"),
                                            object:())
            self.delegate?.didFinishPlay()
            stopBar()
        }else{
            i = i + 1
        }
    }
    
    
    
    func setPlayMode(mode: Int){
        playMode = mode
    }
    func playNote(note: MIDINoteNumber, isDotted: Bool, isSharp: Bool){
        var pnote = note
        
        // right hand mode
        if note < 56 && playMode == 2 {
            return
        }
        // left hand mode
        if note >= 56 && playMode == 1 {
            return
        }
        
        let q1 = DispatchQueue(label:"play")
        q1.async {
            if isSharp {
                pnote = pnote + UInt8(0.5)
            }
            bank.play(noteNumber: pnote, velocity: 70)
            usleep(40*1000)
            bank.stop(noteNumber: pnote)
        }
    }
    
    // 播放指定的note, 延遲 length /1000 秒
    func playNote(note: MIDINoteNumber, length: UInt32){
        let q1 = DispatchQueue(label:"play")
        q1.async {
            bank.play(noteNumber: note, velocity: 70)
            usleep(length * 1000)
            bank.stop(noteNumber: note)
        }
    }
    
    var isBarHidden = false;
    
    func setHiddenBar(isHidden : Bool){
        isBarHidden = isHidden;
    }
    
    func changeBarImage(type : Int){
        
        if isBarHidden {
            barImageView?.image = nil;
            return;
        }
        
        if type == 1 {
            barImageView?.image = imageStandard
        }else if type == 2 {
            barImageView?.image = imageTouch
        }else if type == 3 {
            barImageView?.image = imageFail
        }
    }
    
    func stopBar() {
        isStart = false
        isPause = false
        barImageView?.isHidden = true;
        timer?.invalidate()
        
        // 這裡發斷點
//        NotificationCenter.default.post(name: Notification.Name("nextview"),
//                                        object:())
        self.delegate?.shouldPlayNext()
    }
    
    func startBar()  {
        if isStart {
            if isPause {
                isPause = false
            }
            return
        }else{
            isStart = true
            isPause = false
        }
        
        if !isFirstSeg{
            initBar()
        }
        
        barImageView?.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 0.015625/1.2,
                                     target: self,
                                     selector: #selector(self.setBarPos),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func pauseBar(){
        isPause = true
    }
    
    func setConfig(in n1:Int, n2:Int, n3:Int, n4:Int){
        self.n1 = n1; self.n2 = n2
        self.n3 = n3; self.n4 = n4
    }
    
    // 傳回總小節數
    func getSegs() -> Int {
        return allSeg
    }
    
    // 傳回總拍數
    func getBeats() -> Int {
        return n1 * allSeg
    }
    
    /*
     * jsonArray: 樂譜資料
     * start: 指定第幾小節開始
     * order: 設定為第幾條樂譜(橫列), zero-base
     * return: 顯示幾個小節
     */
    func setScore(in jsonArray: Array<Array<Array<Dictionary<String,String>>>>, start:Int, order: Int, isFirst:Bool, isLast:Bool) -> Int {
        
        isFirstScoreView = isFirst
        isLastScoreView = isLast
        scoreOrder = order
        
        if start == 0 {
            isFirstSeg = true
        }
        scoreArray = []
        var nDrawX = drawX
        var ret = 0
        
        // 每一小節
        noteArray = []
        var si = 0
        for i in start..<jsonArray.count {
            let seg = jsonArray[i]
            noteArray?.append([])  // 加一空小節陣列
            
            // 每一直行
            for _ in seg {
                nDrawX = nDrawX + noteW*4
                noteArray?[si].append(true)// 加一空直列 Bool = true
            }
            si = si + 1
            
            if nDrawX < viewW {
                scoreArray?.append(seg)
                ret = i
            }else{
                ret = i-1
                break
            }
        }
        setNeedsDisplay()
        return ret
    }
    
    // 取得目前樂譜所需 scoreView 數量
    func getScoreViewCount(in jsonArray: Array<Array<Array<Dictionary<String,String>>>>) -> Int {
        var count = 1
        var nDrawX = drawX
//        print("drawX = \(drawX)")
        noteArray = []
        // 每一小節
        for i in 0..<jsonArray.count {
            let seg = jsonArray[i]
            noteArray?.append([])  // 加一空小節陣列
            
            allSeg = allSeg + 1
            
            // 每一直行
            for _ in seg {
                nDrawX = nDrawX + noteW*4
                noteArray?[i].append(true)// 加一空直列 Bool = true
//                print("\(i) : nDrawX = \(nDrawX)")
            }
//            print("----")
            
            if nDrawX > viewW - noteW*4 {
//                print("========= \(viewW)")
                // 一排結束, 尚有資料
                count = count + 1
                nDrawX = drawX
            }
        }
        
        return count
    }
    
    
    // 高低音五線譜
    func drawScore(in context: CGContext){
        context.setLineWidth(2)
        context.setStrokeColor(
            red: 0, green: 0, blue: 0, alpha: 1)
        
        // brace image
        drawX = 8
        let brace = UIImage(named: "brace-105")?.cgImage
        context.draw(brace!, in:
            CGRect(x:drawX,y:unitH*3,
                   width:paddingH-16,height:unitH*14))
        drawX = drawX + paddingH-16
        
        
        // 左下角出發
        context.move(to: CGPoint(x:paddingH,y:unitH*3))
        context.addLine(to: CGPoint(
            x:viewW-paddingH, y:unitH*3))
        context.addLine(to: CGPoint(
            x:viewW-paddingH, y:unitH*17))
        context.addLine(to: CGPoint(
            x:paddingH, y:unitH*17))
        context.addLine(to: CGPoint(
            x:paddingH, y:unitH*3))
        context.drawPath(using: .stroke)
        
        
        
        for i in 13...16 {
            context.move(to: CGPoint(x:paddingH,y:unitH * CGFloat(i)))
            context.addLine(to: CGPoint(
                x:viewW-paddingH, y:unitH * CGFloat(i)))
            context.drawPath(using: .stroke)
        }
        
        for i in 4...7 {
            context.move(to: CGPoint(x:paddingH,y:unitH * CGFloat(i)))
            context.addLine(to: CGPoint(
                x:viewW-paddingH, y:unitH * CGFloat(i)))
            context.drawPath(using: .stroke)
        }
        
        // treble + bass image
        drawX = drawX + paddingTreble
        let treble = UIImage(named: "treble-clef")?.cgImage
        context.draw(treble!, in:
            CGRect(x:drawX,y:unitH*11,
                   width:trebleW/1.5,height:unitH*8))
        
        let base = UIImage(named: "bass-clef")?.cgImage
        context.draw(base!, in:
            CGRect(x:drawX, y:unitH*1.5,
                   width:trebleW/1.5,height:unitH*7))
        drawX = drawX + trebleW/1.5
        
        
        // 第一小節出現的數字 4/4
        drawX = drawX + paddingTreble
        if isFirstScoreView {
            let strImageN1 = String(format: "numeral-%d", n1)
            let strImageN2 = String(format: "numeral-%d", n2)
            let strImageN3 = String(format: "numeral-%d", n3)
            let strImageN4 = String(format: "numeral-%d", n4)
            let imgN1 = UIImage(named: strImageN1)?.cgImage
            let imgN2 = UIImage(named: strImageN2)?.cgImage
            let imgN3 = UIImage(named: strImageN3)?.cgImage
            let imgN4 = UIImage(named: strImageN4)?.cgImage
            context.draw(imgN1!, in:
                CGRect(x:drawX, y:unitH*15,
                       width:trebleW/3,height:unitH*2))
            context.draw(imgN2!, in:
                CGRect(x:drawX, y:unitH*13,
                       width:trebleW/3,height:unitH*2))
            context.draw(imgN3!, in:
                CGRect(x:drawX, y:unitH*5,
                       width:trebleW/3,height:unitH*2))
            context.draw(imgN4!, in:
                CGRect(x:drawX, y:unitH*3,
                       width:trebleW/3,height:unitH*2))
        }
        drawX = drawX + trebleW/3
        
        if isLastScoreView {
            context.setLineWidth(12)
            context.move(to:
                CGPoint(x:viewW-paddingH,y:unitH * CGFloat(3)))
            context.addLine(to:
                CGPoint(x:viewW-paddingH, y:unitH * CGFloat(17)))
            context.drawPath(using: .stroke)
            
            context.setLineWidth(2)
            context.move(to:
                CGPoint(x:viewW-paddingH-12,y:unitH * CGFloat(3)))
            context.addLine(to:
                CGPoint(x:viewW-paddingH-12, y:unitH * CGFloat(17)))
            context.drawPath(using: .stroke)
        }
        
    }
    
    
    
    // 畫出單一音符
    func drawNote(in context: CGContext,
                  tone: Int, note: Float, isNextTone: Bool,
                  isSharp: Bool, isDotted: Bool, x:CGFloat,
                  seg: Int, col: Int, isError: Bool){
        var tonePos: CGFloat = 0
        var isDrawSeg: Bool = false
        var isDrawSeg2: Bool = false
        
        tonePos = CGFloat(tone) * 0.5 + 11
        if Int(tonePos*10) % 10 != 0 {
            isDrawSeg = true
        }
        if tone <= -1 && tone >= -3{
            // 畫兩條
            isDrawSeg2 = true
        }
        
        // 處理音符
        let imgSharp = UIImage(named: "sharp")?.cgImage // 升記號影像
        let imgNoteHead = UIImage(named: noteHeads[note]!)?.cgImage // 音符影像
        let imgRNoteHead = UIImage(named: rnoteHeads[note]!)?.cgImage // 音符影像
        if !isNextTone {
            // 畫補充線段 兩條
            if isDrawSeg2 {
                context.move(to:
                    CGPoint(x:x-noteW/4,y:unitH*(12.5)-unitH/2))
                context.addLine(to: CGPoint(
                    x:x+noteW*5/4, y:unitH*(12.5)-unitH/2))
                context.drawPath(using: .stroke)
                
                context.move(to:
                    CGPoint(x:x-noteW/4,y:unitH*(11.5)-unitH/2))
                context.addLine(to: CGPoint(
                    x:x+noteW*5/4, y:unitH*(11.5)-unitH/2))
                context.drawPath(using: .stroke)
                
            }else if isDrawSeg {
                // 畫補充線段
                context.move(to:
                    CGPoint(x:x-noteW/4,y:unitH*(tonePos+1)-unitH/2))
                context.addLine(to: CGPoint(
                    x:x+noteW*5/4, y:unitH*(tonePos+1)-unitH/2))
                context.drawPath(using: .stroke)
            }
            
            
            if isError {
                context.draw(imgRNoteHead!, in:
                    CGRect(x:x, y:unitH*tonePos,
                           width:noteW,height:unitH*1))
                
            }else{
                // 繪出音符影像
                if noteArray?[seg][col] ?? true {
                    context.draw(imgNoteHead!, in:
                        CGRect(x:x, y:unitH*tonePos,
                               width:noteW,height:unitH*1))
                }else{
                    context.draw(imgRNoteHead!, in:
                        CGRect(x:x, y:unitH*tonePos,
                               width:noteW,height:unitH*1))
                }
            }
            
        }else{
            if isLastLeft {
                // 畫補充線段
                if isDrawSeg {
                    context.move(to:
                        CGPoint(x:(x-noteW)-noteW/4,y:unitH*(tonePos+1)-unitH/2))
                    context.addLine(to: CGPoint(
                        x:(x-noteW)+noteW*5/4, y:unitH*(tonePos+1)-unitH/2))
                    context.drawPath(using: .stroke)
                }
                
                // 繪出音符影像
                if noteArray?[seg][col] ?? true {
                    context.draw(imgNoteHead!, in:
                        CGRect(x:x-noteW, y:unitH*tonePos,
                               width:noteW,height:unitH*1))
                }else{
                    context.draw(imgRNoteHead!, in:
                        CGRect(x:x-noteW, y:unitH*tonePos,
                               width:noteW,height:unitH*1))
                }
                
            }else{
                // 畫補充線段
                if isDrawSeg {
                    context.move(to:
                        CGPoint(x:(x+noteW)-noteW/4,y:unitH*(tonePos+1)-unitH/2))
                    context.addLine(to: CGPoint(
                        x:(x+noteW)+noteW*5/4, y:unitH*(tonePos+1)-unitH/2))
                    context.drawPath(using: .stroke)
                }
                
                // 繪出音符影像
                if isError {
                    context.draw(imgRNoteHead!, in:
                        CGRect(x:x+noteW, y:unitH*tonePos,
                               width:noteW,height:unitH*1))
                }else{
                    if noteArray?[seg][col] ?? true {
                        context.draw(imgNoteHead!, in:
                            CGRect(x:x+noteW, y:unitH*tonePos,
                                   width:noteW,height:unitH*1))
                    }else{
                        context.draw(imgRNoteHead!, in:
                            CGRect(x:x+noteW, y:unitH*tonePos,
                                   width:noteW,height:unitH*1))
                    }
                }
                
            }
        }
        
        // 畫出身體, 是相鄰的音階則不畫身體
        if !isNextTone {
            if noteBodys[note] != "none" {
                if (tone >= 7) || (tone < -2 && tone > -15) {
                    // 左線
                    let body = noteBodys[note]! + "down"
                    let imgNoteBody = UIImage(named: body)?.cgImage
                    let rbody = rnoteBodys[note]! + "down"
                    let imgRNoteBody = UIImage(named: rbody)?.cgImage
                    
                    if isError {
                        context.draw(imgRNoteBody!, in:
                            CGRect(x:x, y:unitH*(tonePos-3),
                                   width:noteW,height:unitH*4))
                    }else {
                        if noteArray?[seg][col] ?? true {
                            context.draw(imgNoteBody!, in:
                                CGRect(x:x, y:unitH*(tonePos-3),
                                       width:noteW,height:unitH*4))
                        }else{
                            // 彈錯變色
                            context.draw(imgRNoteBody!, in:
                                CGRect(x:x, y:unitH*(tonePos-3),
                                       width:noteW,height:unitH*4))
                        }
                    }
                    
                    if isSharp {
                        context.draw(imgSharp!, in:
                            CGRect(x:x+noteW/2, y:unitH*tonePos,
                                   width:noteW/2,height:unitH*4/2))
                    }
                    
                    
                    isLastLeft = true
                }else{
                    // 右線
                    let body = noteBodys[note]! + "up"
                    let imgNoteBody = UIImage(named: body)?.cgImage
                    let rbody = rnoteBodys[note]! + "up"
                    let imgRNoteBody = UIImage(named: rbody)?.cgImage
                    
                    // 因為鬚鬚的關係, 需要往右移動
                    var xp: CGFloat = 0
                    if note >= 1 {
                        xp = x
                    }else{
                        xp = x + noteW/2
                    }
                    
                    if isError {
                        context.draw(imgRNoteBody!, in:
                            CGRect(x:xp, y:unitH*tonePos,
                                   width:noteW,height:unitH*4))
                        
                    }else {
                        if noteArray?[seg][col] ?? true {
                            context.draw(imgNoteBody!, in:
                                CGRect(x:xp, y:unitH*tonePos,
                                       width:noteW,height:unitH*4))
                            
                        }else{
                            // 彈錯變色
                            context.draw(imgRNoteBody!, in:
                                CGRect(x:xp, y:unitH*tonePos,
                                       width:noteW,height:unitH*4))
                        }
                    }
                    
                    if isSharp {
                        context.draw(imgSharp!, in:
                            CGRect(x:xp-noteW/2, y:unitH*tonePos,
                                   width:noteW/2,height:unitH*4/2))
                    }
                    
                    isLastLeft = false
                }
                
            }
        }
        
        // 附點記號
        if isDotted {
            let imgDotted = UIImage(named: "dot")?.cgImage
            context.draw(imgDotted!, in:
                CGRect(x:x+noteW*5/4, y:unitH*tonePos,
                       width:noteW/8,height:unitH/4))
            
        }
    }
    
    // 畫出休止符
    func drawRest(in context: CGContext,
                  isBass: Bool, note: Float, x:CGFloat){
        // 休止符
        let imgRest = UIImage(named: rests[note]!)?.cgImage
        if isBass {
            context.draw(imgRest!, in:
                CGRect(x:x, y:unitH*3.5,
                       width:noteW,height:unitH*3))
            
        }else{
            context.draw(imgRest!, in:
                CGRect(x:x, y:unitH*13.5,
                       width:noteW,height:unitH*3))
        }
        
    }
    
    // 彈錯變色
    func setSegCol2Red(order: Int, seg:Int, col:Int){
        if order == scoreOrder {
            noteArray?[seg][col] = false
            isFirstSeg = false
            setNeedsDisplay()
        }
    }
    
    func clearAllNotes(){
        scoreArray = nil
//        barImageView?.removeFromSuperview()
        barImageView = nil
        setNeedsDisplay()
    }
    
    func drawLine(in context: CGContext, x: CGFloat){
        // 左下角出發
        context.move(to: CGPoint(x:x,y:unitH*3))
        context.addLine(to: CGPoint(
            x:x, y:unitH*17))
        context.drawPath(using: .stroke)
    }
    
}
