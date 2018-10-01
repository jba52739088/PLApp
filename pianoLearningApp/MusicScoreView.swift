//
//  MusicScoreView.swift
//  MusicTest1
//
//  Created by 趙令文 on 2018/9/6.
//  Copyright © 2018年 趙令文. All rights reserved.
//

import UIKit

class MusicScoreView: UIView {
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
    let noteHeads:[Float:String] =
        [0.03125:"quarter-head", 0.0625:"quarter-head",
         0.125:"quarter-head", 0.25:"quarter-head",
         0.5:"quarter-head", 1.0:"quarter-head",
         2:"half-head", 4:"whole-head"]
    let noteBodys:[Float:String] =
        [0.03125:"128th-", 0.0625:"64th-",
         0.125:"32nd-", 0.25:"16th-",
         0.5:"eighth-", 1.0:"quarter-",
         2.0:"quarter-", 4.0:"none"]
    let rests:[Float:String] =
        [0.03125:"128th-rest", 0.0625:"64th-rest",
         0.125:"32nd-rest", 0.25:"16th-rest",
         0.5:"eighth-rest", 1.0:"quarter-rest",
         2.0:"half-rest", 4.0:"whole-rest"]
    
    var isLastLeft = false
    
    var scoreArray: Array<Array<Array<Dictionary<String,String>>>>? = nil
    
    var frameNow:CGRect? = nil
    var image = UIImage(named: "black_standard")
    var imageView:UIImageView? = nil
    var i = 0
    var k = 0
    var timer:Timer? = nil
    
    var drawX:CGFloat = 0
    var barX:CGFloat = 0
    var steps:Array<CGFloat> = []
    var noteData:Array<(Int,Int)> = []
    var isFirstSeg = false
    var nextScoreView: MusicScoreView? = nil
    var isPause = false
    
    var isStart = false
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            
            let t = context.ctm.inverted()
            context.concatenate(t)
            
            viewW = self.frame.size.width * 2
            viewH = self.frame.size.height * 2
            unitH = viewH / 20  // 3 + 4 + 6 + 4 + 3
            paddingH = viewW / 24
            trebleW = viewW / 16
            paddingTreble = trebleW / 8
            numeralX = paddingH + paddingTreble + trebleW + paddingTreble
            noteW = viewW / 40
            
            // 繪出基本的五線譜
            drawScore(in: context, isFirst: true)
            barX = drawX
            // 讀取 scoreArray 來畫出音符
            var pos = drawX + noteW   // 初始 x 位置
            if (scoreArray != nil){
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
                            let mTone = Int(note["tone"]!)
                            let mNote = 4/Float(note["note"]!)!
                            
                            // 用來處理時間間隔, 找出最小的音符
                            if nMaxNote<Float(note["note"]!)! {
                                nMaxNote = Float(note["note"]!)!
                            }
                            
                            
                            // 繪製音符
                            if abs(lastTone - mTone!) == 1 {
                                drawNote(in: context, tone: mTone!, note: mNote,isNextTone: true, x: pos)
                            }else{
                                drawNote(in: context, tone: mTone!, note: mNote,isNextTone: false, x: pos)
                            }
                            lastTone = mTone!
                        }
                        
                        // 假設一拍為一秒
                        // 因為4分音符nMaxNote為4, 所以除以 4
                        let num = Int(nMaxNote/4/0.015625)
                        let dist = noteW*2/CGFloat(num)
                        for i in 1...num {
                            if i == 1 {
                                steps.append(dist * -1)
                            }else{
                                steps.append(dist)
                            }
                            
                        }
                        pos = pos + noteW*4
                    }
                    drawLine(in: context, x: pos - noteW*1)
                    //pos = pos + noteW*1
                }
                
                if isFirstSeg {
                    initBar()
                }
            }
            context.restoreGState()
        }
    }
    
    func initBar(){
        // 第一個音符: (barX+noteW/2)/2
        // 第二個音符: (barX+noteW/2)/2+noteW*2
        // 所以間距為: noteW*2
        imageView = UIImageView(image: image!)
        imageView?.frame = CGRect(
            x: (barX+noteW/2)/2, y: CGFloat(0), width: noteW, height: viewH/2)
        addSubview(imageView!)
        
        frameNow = imageView?.frame
        
        i = 0   // 起始 steps 的 index
        k = 0   // 音符資料noteData的 index
        
    }
    
    func setNextScoreView(in nextView: MusicScoreView){
        nextScoreView = nextView
    }
    
    @objc func setBarPos(){
        if isPause {return}
        
        if steps[i] < 0 {
            let (seg,col) = noteData[k]
            let nowNotes = scoreArray![seg][col]
            // 每個音符
            for note in nowNotes {
                let mTone = Int(note["tone"]!)
                let mNote = 4/Float(note["note"]!)!
                //print("\(mTone) : \(mNote)")
                NotificationCenter.default.post(name: Notification.Name("nowNote"),
                                                object:(mTone, mNote))
            }
            //print("----")
            k = k + 1
        }
        
        frameNow?.origin.x += abs(steps[i])
        imageView?.frame = frameNow!
        if i == steps.count-1 {
            stopBar()
        }else{
            i = i + 1
        }
    }
    
    func stopBar() {
        isStart = false
        isPause = false
        timer?.invalidate()
        if (nextScoreView != nil){
            imageView?.isHidden = true
            nextScoreView?.startBar()
        }
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
//        timer = Timer.scheduledTimer(withTimeInterval: 0.015625, repeats: true) { (timer) in
//            self.setBarPos()
//        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.015625,
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
    
    /*
     * jsonArray: 樂譜資料
     * start: 指定第幾小節開始
     * return: 顯示幾個小節
     */
    func setScore(in jsonArray: Array<Array<Array<Dictionary<String,String>>>>, start:Int) -> Int {
        
        if start == 0 {
            isFirstSeg = true
        }
        scoreArray = []
        var nDrawX = drawX
        var ret = 0
        
        // 每一小節
        for i in start..<jsonArray.count {
            let seg = jsonArray[i]
            // 每一直行
            for _ in seg {
                nDrawX = nDrawX + noteW*4
            }
            
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
    
    // 高低音五線譜
    func drawScore(in context: CGContext, isFirst: Bool){
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
                   width:trebleW,height:unitH*8))
        
        let base = UIImage(named: "bass-clef")?.cgImage
        context.draw(base!, in:
            CGRect(x:drawX, y:unitH*1.5,
                   width:trebleW,height:unitH*7))
        drawX = drawX + trebleW
        
        
        // 第一小節出現的數字 4/4
        drawX = drawX + paddingTreble
        if isFirst {
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
                       width:trebleW/2,height:unitH*2))
            context.draw(imgN2!, in:
                CGRect(x:drawX, y:unitH*13,
                       width:trebleW/2,height:unitH*2))
            context.draw(imgN3!, in:
                CGRect(x:drawX, y:unitH*5,
                       width:trebleW/2,height:unitH*2))
            context.draw(imgN4!, in:
                CGRect(x:drawX, y:unitH*3,
                       width:trebleW/2,height:unitH*2))
        }
        drawX = drawX + trebleW/2
    }
    
    
    
    // 畫出單一音符
    func drawNote(in context: CGContext,
                  tone: Int, note: Float, isNextTone: Bool, x:CGFloat){
        var tonePos: CGFloat = 0
        var isDrawSeg: Bool = false
        
        tonePos = CGFloat(tone) * 0.5 + 11
        if Int(tonePos*10) % 10 != 0 {
            isDrawSeg = true
        }
        
        // 音符
        let imgNoteHead = UIImage(named: noteHeads[note]!)?.cgImage
        if !isNextTone {
            // 畫補充線段
            if isDrawSeg {
                context.move(to:
                    CGPoint(x:x-noteW/4,y:unitH*(tonePos+1)-unitH/2))
                context.addLine(to: CGPoint(
                    x:x+noteW*5/4, y:unitH*(tonePos+1)-unitH/2))
                context.drawPath(using: .stroke)
            }
            
            context.draw(imgNoteHead!, in:
                CGRect(x:x, y:unitH*tonePos,
                       width:noteW,height:unitH*1))
            
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
                
                context.draw(imgNoteHead!, in:
                    CGRect(x:x-noteW, y:unitH*tonePos,
                           width:noteW,height:unitH*1))
                
            }else{
                // 畫補充線段
                if isDrawSeg {
                    context.move(to:
                        CGPoint(x:(x+noteW)-noteW/4,y:unitH*(tonePos+1)-unitH/2))
                    context.addLine(to: CGPoint(
                        x:(x+noteW)+noteW*5/4, y:unitH*(tonePos+1)-unitH/2))
                    context.drawPath(using: .stroke)
                }
                
                context.draw(imgNoteHead!, in:
                    CGRect(x:x+noteW, y:unitH*tonePos,
                           width:noteW,height:unitH*1))
                
            }
        }
        
        // 畫出身體, 是相鄰的音階則不畫身體
        if !isNextTone {
            if noteBodys[note] != "none" {
                if (tone >= 7) || (tone > -15) {
                    // 左線
                    let body = noteBodys[note]! + "down"
                    let imgNoteBody = UIImage(named: body)?.cgImage
                    context.draw(imgNoteBody!, in:
                        CGRect(x:x, y:unitH*(tonePos-3),
                               width:noteW,height:unitH*4))
                    isLastLeft = true
                }else{
                    // 右線
                    let body = noteBodys[note]! + "up"
                    // 因為鬚鬚的關係, 需要往右移動
                    var xp: CGFloat = 0
                    if note >= 1 {
                        xp = x
                    }else{
                        xp = x + noteW/2
                    }
                    
                    let imgNoteBody = UIImage(named: body)?.cgImage
                    context.draw(imgNoteBody!, in:
                        CGRect(x:xp, y:unitH*tonePos,
                               width:noteW,height:unitH*4))
                    isLastLeft = false
                }
                
            }
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
    
    func drawLine(in context: CGContext, x: CGFloat){
        // 左下角出發
        context.move(to: CGPoint(x:x,y:unitH*3))
        context.addLine(to: CGPoint(
            x:x, y:unitH*17))
        context.drawPath(using: .stroke)
    }
    
}
