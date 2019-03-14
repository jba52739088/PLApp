//
//  musicNotePlayVC.swift
//  pianoLearningApp
//


import UIKit
import LSFloatingActionMenu
import PianoView
import MusicTheorySwift
import AudioKit
import AVFoundation
import AVAudioSessionSetCategorySwift
import SwiftyJSON

class musicNotePlayVC: UIViewController {
    
    // 功能鍵列
    @IBOutlet weak var playControllerView: UIView!
    @IBOutlet weak var main_slower_Btn: UIButton!
    @IBOutlet weak var main_playstart_Btn: UIButton!
    @IBOutlet weak var main_faster_Btn: UIButton!
    @IBOutlet weak var main_tempplay_Btn: UIButton!
    @IBOutlet weak var main_tempplay_Title: UILabel!
    @IBOutlet weak var main_follow_Btn: UIButton!
    @IBOutlet weak var main_justplay_Btn: UIButton!
    @IBOutlet weak var progressSlider: CustomMainSlider!
    
    // 五線譜區
    @IBOutlet weak var musicNoteView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var musicNoteViewBottom: NSLayoutConstraint!     // 底部高度
    @IBOutlet weak var bmpSlider: CustomSubSlider!                  // 彈奏速度Slider
    @IBOutlet weak var bmpLabel: UILabel!                           // 彈奏速度Label
    @IBOutlet weak var main_keyboard_Btn: UIButton!                 // 開啟鍵盤
    @IBOutlet weak var main_sub_nav_open_Btn: UIButton!             // 右下功能鍵
    @IBOutlet weak var noteBackground: UIView!                      // 五線譜區
    
    // 預設scoreView
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scoreView: MusicScoreView!
    @IBOutlet weak var scoreView2: MusicScoreView!
    @IBOutlet weak var spaceView_1: UIView!
    @IBOutlet weak var spaceView_2: UIView!
    
    // 其他顯示
    @IBOutlet weak var segsLabel: UILabel!
    @IBOutlet weak var noteTimeLabel: UILabel!
    
    var pianoBackground: CustomPianoView!
    var selectionView: SelectionView!
    
    var alertView: AlertView!
    var actionAlertView: ActionAlertView!
    // AKMIDIListener
    let midi = AKMIDI()
    var i:UInt8 = 36
    let ms = 1000
    var isMidi_on = false // midi是否插入
    // 右下角功能列
    var actionMenu: LSFloatingActionMenu!
    var muneIsOpen = false
    // 錄音＆播放&演奏曲
    var audioPlayer: AVAudioPlayer?
    // 是否播放中
    var isPlaying = false
    // 是否為演奏模式
    var isJustplay = false
    // 當前曲目名稱
    var currentSongName: String?
    // empty NOTE VIEW
    var emptyNoteView: UIView!
    // 現在五線譜跑到目前小節中第n個音符
    var shouldNoteIndex = 0
    // 現在五線譜跑到當下第幾小節
    var nowBarIndex = 0
    // 剛剛五線譜跑到當下第幾小節
    var lastBarIndex = 0
    // 五線譜跑到全部第幾小節
    var didBarIndex = 0
    // 跑到哪一個scoreView(0: 上面 1:下面)
    var nowScoreIndex = 0
    // 跑到第幾個scoreView
    var nowScoreView = 0
    // 所有scoreView數量
    var allScoreViewCount = 0
    // 所有音符數
    var allNoteCount = 0
    // 目前音符數
    var nowNoteCount = 0
    // 是否有下一個五線譜
    var hasMoreScore = false
    
    // scoreView判斷用
    var jsonArray: Array<Array<Array<Dictionary<String,String>>>>? // 譜data
    var pianoIsVisible = false  // 是否有鋼琴
    var didBegin = false        // 是否有準備播放的譜
    var order = 0   // 開始小節
    var nowSegs = 0       // 目前呈現到第n小節
    var allSegs = 0 // 所有小節數
    
    // 記錄使用者彈奏
    var userHasPlay = false
    var isRecording = false
    var recordTime: Int = 0
    var userDidPlay = false
    var isReadLocal = false
    var msPerBeat: Float = 0 // 一拍幾毫秒
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spaceView_1.isHidden = true
        spaceView_2.isHidden = true
        midi.addListener(self)
        setPianoView()
        let imageGif = UIImage(named: "main_playstart")
        main_playstart_Btn.setImage(imageGif, for: .normal)
        setSubNavMenu()
        self.setMidiInput()
        self.setPageIndex()
        self.setMain_tempplay_Btn(.OFF)
        // 若之前無讀取樂譜之情況
        if UserDefaultsKeys.LAST_NOTE_NAME == "" {
            emptyNoteView = Bundle.main.loadNibNamed("EmptyNoteView", owner: self, options: nil)?.first as! UIView
            emptyNoteView.frame = self.noteBackground.bounds
            self.noteBackground.addSubview(emptyNoteView)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bmpLabel.text = "\(Int(self.bmpSlider.value)) bmp"
        if UserDefaultsKeys.LAST_NOTE_NAME != "" {
            self.shouldCleanNotes()
            self.showScoreView(file: UserDefaultsKeys.LAST_NOTE_NAME, isreadLocal: false)
        }
    }
    
    // 左边slider
    @IBAction func didDragBmpSlider(_ sender: UISlider) {
        self.bmpLabel.text = "\(Int(sender.value)) bmp"
    }
    
    @IBAction func didFinishDragSlider(_ sender: UISlider) {
        print(Int(sender.value))
        nowSegs = 0
//        self.didFinishPlay()
        if UserDefaultsKeys.LAST_NOTE_NAME != "" {
            self.shouldCleanNotes()
            self.showScoreView(file: UserDefaultsKeys.LAST_NOTE_NAME, isreadLocal: false)
        }
    }
    
    func setMidiInput() {
        
        midi.openInput()
        let ends:[EndpointInfo] = midi.destinationInfos
        for endpoint in ends {
            print(endpoint.name + ":" + endpoint.displayName)
            midi.openOutput(endpoint.name)
        }
        if midi.inputNames.count > 0 {
            for item in midi.inputNames {
                if item == "KEYBOARD" {
                    
                }
            }
        }
//        midi.openOutput("連接埠 1")
//        midi.openOutput("Session 1")
    }

    func setPageIndex() {
        self.pageControl.numberOfPages = self.allScoreViewCount
        self.pageControl.currentPage = self.nowScoreView
        
    }

    // 寫死兩個sroreView
    func showScoreView(file: String, isreadLocal: Bool) {
        
        //
        allScoreViewCount = 1   // 共需要幾條
        allSegs = 0 // 計算出所有小節
        nowSegs = 0 // 目前呈現的小節數
        nowScoreView = 0
        hasMoreScore = false
        nowBarIndex = 0
        lastBarIndex = 0
        didBarIndex = 0
        allNoteCount = 0
        nowNoteCount = 0
        segsLabel.text = "小節 0"
        noteTimeLabel.text = "拍數 0"
        isReadLocal = false
        userHasPlay = false
        //
        
        scoreView.setBeat(setBeat: bmpSlider.value / 60)
        scoreView2.setBeat(setBeat: bmpSlider.value / 60)
        
        self.msPerBeat = (bmpSlider.value / 60) * 1000
        print("msPerBeat: \(self.msPerBeat)")
        
        // 讀取 JSON 字串資料
        var thisUrl = Bundle.main.url(forResource: file, withExtension: "json")
        self.currentSongName = file
        if isreadLocal {
            self.isReadLocal = true
            thisUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("\(self.currentSongName ?? "")_userPlayedData.json")
            self.currentSongName = "\(self.currentSongName ?? "")_userPlayedData.json"
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
            scoreView.setConfig(in: 3, n2: 4, n3: 3, n4: 4)
            scoreView.delegate = self
            scoreView2.delegate = self
            // 載入樂譜有幾列, 需要幾個 ScoreView
            let lines = scoreView.getScoreViewCount(in: jsonArray)
            self.allScoreViewCount = lines
            self.setPageIndex()
            didBegin = true
            // 載入第一條
            let scoreViewN = scoreView.setScore(in: jsonArray, start: nowSegs, order: 0, isFirst: true, isLast: nowSegs>=allSegs-1)
            nowSegs = scoreView.setScore(in: jsonArray, start: nowSegs, order: 0, isFirst: true, isLast: scoreViewN>=allSegs-1)
            
            // 載入第二條
            if nowSegs < allSegs - 1 {
                hasMoreScore = true
                scoreView2.isHidden = false
                // 載入樂譜
                let score2ViewN = scoreView2.setScore(in: jsonArray, start:nowSegs+1, order: 1, isFirst: false, isLast: nowSegs>=allSegs-1)
                nowSegs = scoreView2.setScore(in: jsonArray, start:nowSegs+1, order: 1, isFirst: false, isLast: score2ViewN>=allSegs-1)
            }
            //
        }catch{
            print(error.localizedDescription)
        }
    }

    @IBAction func onClick_main_slower_Btn(_ sender: Any) {

    }
    
    @IBAction func onClick_main_faster_Btn(_ sender: Any) {

    }
    @IBAction func onClick_main_just_play_Btn(_ sender: Any) {
        if !self.isJustplay {
            selectionView = Bundle.main.loadNibNamed("SelectionView", owner: self, options: nil)?.first as? SelectionView
            selectionView.frame = self.musicNoteView.frame
            selectionView.delegate = self
            selectionView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.addSubview(selectionView)
        }else {
            self.main_justplay_Btn.setImage(UIImage(named: "main_justplay"), for: .normal)
            self.isJustplay = false
            let imageGif = UIImage(named: "main_playstart")
            main_playstart_Btn.setImage(imageGif, for: .normal)
        }
        
        
    }
    
    
    @IBAction func onClick_main_playstart_Btn(_ sender: Any) {
        isRecording = false
        if self.isJustplay {
            if !isPlaying {
                if self.pianoIsVisible {
                    self.onClick_main_keyboard_Btn(self.main_keyboard_Btn)
                }
                if muneIsOpen {
                    self.onClick_main_sub_nav_open_Btn(self.main_sub_nav_open_Btn)
                }
                self.main_keyboard_Btn.isUserInteractionEnabled = false
                 self.main_sub_nav_open_Btn.isUserInteractionEnabled = false
                let imageGif = UIImage(named: "main_playstart copy")
                main_playstart_Btn.setImage(imageGif, for: .normal)
                isPlaying = !isPlaying
                self.audioPlayer?.play()
            }else {
                self.audioPlayer?.pause()
                self.main_keyboard_Btn.isUserInteractionEnabled = true
                self.main_sub_nav_open_Btn.isUserInteractionEnabled = true
                let imageGif = UIImage(named: "main_playstart")
                main_playstart_Btn.setImage(imageGif, for: .normal)
                isPlaying = !isPlaying
            }
        }else {
            if !self.didBegin {
                if UserDefaultsKeys.LAST_NOTE_NAME != "" {
                    self.showScoreView(file: UserDefaultsKeys.LAST_NOTE_NAME, isreadLocal: false)
                    return
                }
            }
            
            if !isPlaying {
                let imageGif = UIImage(named: "main_playstart copy")
                main_playstart_Btn.setImage(imageGif, for: .normal)
                isPlaying = !isPlaying
                 self.bmpSlider.isUserInteractionEnabled = false
                if self.nowScoreIndex == 0 {
                    scoreView.startBar()
                }else {
                    scoreView2.startBar()
                }
                self.isRecording = true
                self.setMain_tempplay_Btn(.Recording)
//                self.main_tempplay_Btn.setImage(UIImage(named: "main_stop"), for: .normal)
                
            }else {
                let imageGif = UIImage(named: "main_playstart")
                main_playstart_Btn.setImage(imageGif, for: .normal)
                isPlaying = !isPlaying
                if self.nowScoreIndex == 0 {
                    scoreView.pauseBar()
                }else {
                    scoreView2.pauseBar()
                }
                self.isRecording = false
                self.setMain_tempplay_Btn(.Recording)
//                self.main_tempplay_Btn.setImage(UIImage(named: "main_stop"), for: .normal)
            }
        }
    }
    
    @IBAction func onClick_main_tempplay_Btn(_ sender: Any) {
        if !self.isRecording {
            self.showScoreView(file: self.currentSongName ?? "", isreadLocal: true)
        }else {
            self.showActionAlertView()
        }
    }
    
    //MARK: - 點擊鍵盤按鈕
    /// 點擊鍵盤按鈕
    @IBAction func onClick_main_keyboard_Btn(_ sender: Any) {
        if isPlaying {
            self.onClick_main_playstart_Btn(self)
        }
        if self.nowScoreIndex == 0 {
            scoreView.isHidden = false
        }else {
            scoreView2.isHidden = true
        }
        if !pianoIsVisible {
            pianoIsVisible = true
            spaceView_1.isHidden = false
            spaceView_2.isHidden = false
            self.musicNoteView.frame.size.height -= 165
            self.musicNoteViewBottom.constant += 165
            UIView.animate(withDuration: 0.3, animations: {
                self.musicNoteView.layoutIfNeeded()
                
            })
        }else {
            pianoIsVisible = false
            spaceView_1.isHidden = true
            spaceView_2.isHidden = true
            self.musicNoteView.layoutIfNeeded()
            self.musicNoteViewBottom.constant -= 165
            self.musicNoteView.frame.size.height += 165
            UIView.animate(withDuration: 0.3, animations: {
                self.musicNoteView.layoutIfNeeded()
                
            })
        }
        if pianoIsVisible{
            if self.nowScoreIndex % 2 != 0 {
                self.scoreView.isHidden = true
                self.scoreView2.isHidden = false
            }else {
                self.scoreView.isHidden = false
                self.scoreView2.isHidden = true
            }
        }else {
            self.scoreView.isHidden = false
            self.scoreView2.isHidden = false
        }
        self.setPageIndex()
    }
    
    @IBAction func onClick_main_sub_nav_open_Btn(_ sender: UIButton) {
        self.actionMenu.startPoint = CGPoint(x: self.main_sub_nav_open_Btn.center.x - self.main_sub_nav_open_Btn.frame.width - 12, y:  self.main_sub_nav_open_Btn.center.y - 20)
        if !muneIsOpen{
            self.actionMenu.isHidden = false
            self.actionMenu.open()
            muneIsOpen = !muneIsOpen
        }else{
            self.actionMenu.close()
            self.actionMenu.isHidden = true
            muneIsOpen = !muneIsOpen
        }

        
        
    }
    
    @IBAction func testTouchDown(_ sender: Any) {
        self.receivedMIDINoteOn(noteNumber: 60, velocity: 1, channel: 1)

    }
    
    @IBAction func testTouchUp(_ sender: Any) {
        self.receivedMIDINoteOn(noteNumber: 60, velocity: 1, channel: 1)
    }
    
    func storeUserPlayedData() {
        if let paramsJSON = JSON(self.jsonArray) as? JSON {
            if let data = try? paramsJSON.rawData() {
                let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("\(self.currentSongName ?? "")_userPlayedData.json") // Your json file name
                try? data.write(to: fileUrl)
            }
        }
    }
    
    func convertNoteNum(note: String) -> String {
        let noteNums = ["0": "-34","1": "-33.5","10": "-28.5","100": "24","101": "25","102": "25.5","103": "26","104": "26.5","105": "27","106": "27.5","107": "28","108": "29","109": "29.5","11": "-28","110": "30","111": "30.5","112": "31","113": "32","114": "32.5","115": "33","116": "33.5","117": "34","118": "34.5","119": "35","12": "-27","120": "36","121": "36.5","122": "37","123": "37.5","124": "38","125": "39","126": "39.5","127": "40","13": "-26.5","14": "-26","15": "-25.5","16": "-25","17": "-24","18": "-23.5","19": "-23","2": "-33","20": "-22.5","21": "-22","22": "-21.5","23": "-21","24": "-20","25": "-19.5","26": "-19","27": "-18.5","28": "-18","29": "-17","3": "-32.5","30": "-16.5","31": "-16","32": "-15.5","33": "-15","34": "-14.5","35": "-14","36": "-13","37": "-12.5","38": "-12","39": "-11.5","4": "-32","40": "-11","41": "-10","42": "-9.5","43": "-9","44": "-8.5","45": "-8","46": "-7.5","47": "-7","48": "-6","5": "-31","50": "-5","51": "-4.5","52": "-4","53": "-3","54": "-2.5","55": "-2","56": "-1.5","57": "-1","58": "-0.5","59": "0","6": "-30.5","60": "1","61": "1.5","62": "2","63": "2.5","64": "3","65": "4","66": "4.5","67": "5","68": "5.5","69": "6","7": "-30","70": "6.5","71": "7","72": "8","73": "8.5","74": "9","75": "9.5","76": "10","77": "11","78": "11.5","79": "12","8": "-29.5","80": "12.5","81": "13","82": "13.5","83": "14","84": "15","85": "15.5","86": "16","87": "16.5","88": "17","89": "18","9": "-29","90": "18.5","91": "19","92": "19.5","93": "20","94": "20.5","95": "21","96": "22","97": "22.5","98": "23","99": "23.5","49":"-5.5"]
        return noteNums[note] ?? ""
    }
    
    
}

//MARK: - 監聽鍵盤點擊
extension musicNotePlayVC: AKMIDIListener {
    func receivedMIDISetupChange() {
        if (self.midi.inputNames.count > 0) {
            for item in self.midi.inputNames {
                if item == "KEYBOARD" {
                    self.showAlertView(message: "MIDI连接成功！！")
                    self.isMidi_on = true
                    self.setMidiInput()
                    self.setMain_tempplay_Btn(.ON)
                    return
                }
            }
        }
        self.isMidi_on = false
        self.setMain_tempplay_Btn(.OFF)
    }
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            let note = Pitch(midiNote: Int(noteNumber))
            self.pianoBackground.pianoView.highlightNote(note: note)
            if self.isRecording {
                let convertedNote = self.convertNoteNum(note: "\(noteNumber)")
                self.userDidPlay = true
                print("convertedNote: \(convertedNote)")
                let shouldNote = self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["tone"]
                if convertedNote != shouldNote {
                    self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["tone"] = convertedNote
                    self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["play"] = "false"
                }
            }else {
                 self.userDidPlay = true
            }
            
        }
//        print("\(self.jsonArray?[self.didBarIndex-1][shouldNoteIndex][0])")
        
        
        
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            let note = Pitch(midiNote: Int(noteNumber))
            self.pianoBackground.pianoView.unhighlightNote(note: note)
            if self.isRecording {
                print("noteNumber: \(noteNumber)")
            }
        }
    }
}

//MARK: - MusicScoreViewDelegate

extension musicNotePlayVC: MusicScoreViewDelegate {
    func shouldPlayNext() {
        self.pianoBackground.pianoView.deselectAll()
        print("nowSegs: \(nowSegs), allSegs: \(allSegs)")
        if nowScoreView % 2 == 0 {
            // 播放下面樂譜
            if hasMoreScore{
                scoreView2.startBar()
            }
            
            // 載入下一條的樂譜
            if nowSegs < allSegs - 1 {
                hasMoreScore = true
                // 載入樂譜
                let scoreViewN = scoreView.setScore(in: jsonArray!, start:nowSegs+1, order:nowScoreView+2, isFirst:false, isLast: false)
                nowSegs = scoreView.setScore(in: jsonArray!, start:nowSegs+1, order:nowScoreView+2, isFirst:false, isLast: scoreViewN>=allSegs-1)
                
                
            }else{
                hasMoreScore = false
            }
        }else {
            // 播放上面樂譜
            if hasMoreScore {
                scoreView.startBar()
            }
            
            // 載入下一條的樂譜
            if nowSegs < allSegs - 1 {
                hasMoreScore = true
                // 載入樂譜
                let score2ViewN = scoreView2.setScore(in: jsonArray!, start:nowSegs+1, order:nowScoreView+2, isFirst:false, isLast: false)
                nowSegs = scoreView2.setScore(in: jsonArray!, start:nowSegs+1, order:nowScoreView+2, isFirst:false, isLast: score2ViewN>=allSegs-1)
            }else{
                hasMoreScore = false
            }
        }
        nowScoreView = nowScoreView + 1
    }
    

    // scoreIndex：score, Pith：音名, time：拍子, barIndex：小節, NoteIndex：第幾個音符
    func noteShouldPlay(scoreIndex: Int, pitch: Int, time: Float, barIndex: Int, NoteIndex: Int) {
        if NoteIndex != self.shouldNoteIndex || self.nowBarIndex != barIndex{
            self.pianoBackground.pianoView.deselectAll()
        }
        if !userDidPlay && self.didBarIndex > 0 && isRecording && !self.isReadLocal{
            self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["tone"] = "1"
            self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["note"] = "-99"
            self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["rest"] = "4"
            self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["play"] = "false"
        }
        userDidPlay = false
        self.lastBarIndex = self.nowBarIndex
        self.segsLabel.text = "小節 \(barIndex)"
        self.noteTimeLabel.text = "拍數 \(Int(time))"
        self.nowBarIndex = barIndex + 1
        if (self.nowBarIndex == 1 && self.lastBarIndex != 1){
            self.didBarIndex += 1
        }else {
            self.didBarIndex += (self.nowBarIndex - self.lastBarIndex)
        }
        self.nowNoteCount += 1
        self.progressSlider.value = Float(self.nowNoteCount) / Float(self.allNoteCount)
        self.shouldNoteIndex = NoteIndex
        self.nowScoreIndex = scoreIndex % 2
        self.nowScoreView = scoreIndex
        self.pageControl.currentPage = scoreIndex
        self.segsLabel.text = "小節 \(self.didBarIndex)"
        self.noteTimeLabel.text = "拍數 \(Int(time))"
        if scoreIndex % 2 != 0 {
            if pianoIsVisible {
                self.scoreView.isHidden = true
                self.scoreView2.isHidden = false
            }
        }else {
//            self.showScoreView(file: song)
            if pianoIsVisible {
                self.scoreView.isHidden = false
                self.scoreView2.isHidden = true
            }
        }
//        print("nowScoreIndex: \(nowScoreIndex)")
        self.setPageIndex()
        let note = Pitch(midiNote: pitch)
        self.pianoBackground.pianoView.selectNote(note: note)
        print("self.jsonArray?[\(self.didBarIndex-1)][\(shouldNoteIndex)]")
        print("\(self.jsonArray?[self.didBarIndex-1][shouldNoteIndex][0])")
    }
    
    func didFinishPlay() {
//        print("didFinishPlay scoreOrder: \(scoreOrder)")
        self.pianoBackground.pianoView.deselectAll()
        print("nowSegs: \(nowSegs), allSegs: \(allSegs)")
        if (nowSegs<allSegs-1){
            
        }else{
            if self.nowScoreView < self.allScoreViewCount {
                if nowScoreIndex != 1 {
                    self.scoreView2.startBar()
                }else {
                    self.scoreView.startBar()
                }
            }else {
                if self.isRecording{
                    if !userDidPlay && self.didBarIndex > 0 && isRecording && !self.isReadLocal{
                        // 若最後一個沒彈也要記錄
                        self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["tone"] = "1"
                        self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["note"] = "-99"
                        self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["rest"] = "4"
                        self.jsonArray![self.didBarIndex-1][self.shouldNoteIndex][0]["play"] = "false"
                    }
                    self.storeUserPlayedData()
                    self.isRecording = false
//                    self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay"), for: .normal)
                    self.setMain_tempplay_Btn(.Recorded)
                }
                self.shouldCleanNotes()
                self.scoreView.stopBar()
                self.scoreView2.stopBar()
            }
        }
    }
    
    func shouldCleanNotes() {
        let imageGif = UIImage(named: "main_playstart")
        main_playstart_Btn.setImage(imageGif, for: .normal)
        self.isPlaying = false
        self.bmpSlider.isUserInteractionEnabled = true
        self.allScoreViewCount = 1
        self.nowScoreIndex = 0
        self.didBegin = false
        self.order = 0
        self.nowSegs = 0
        self.allSegs = 0
    }
}

extension musicNotePlayVC: SelectionViewDelegate {
    func didTapCancel() {
        if self.selectionView != nil {
            self.main_justplay_Btn.setImage(UIImage(named: "main_justplay"), for: .normal)
            self.isJustplay = false
            self.selectionView.removeFromSuperview()
            self.selectionView = nil
        }
    }
    
    func playTest1() {
//        showScoreView(file: "score1")
        do {
            if let fileURL = Bundle.main.path(forResource: "score1", ofType: "wav") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                audioPlayer?.numberOfLoops = 0
                audioPlayer?.delegate = self
//                audioPlayer?.play()
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        if self.selectionView != nil {
            self.main_justplay_Btn.setImage(UIImage(named: "main_justplay_speed2"), for: .normal)
            self.isJustplay = true
            self.selectionView.removeFromSuperview()
            self.selectionView = nil
        }
    }
    
    func playTest2() {
//        showScoreView(file: "score2")
        do {
            if let fileURL = Bundle.main.path(forResource: "score1", ofType: "wav") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                audioPlayer?.numberOfLoops = 0
                audioPlayer?.delegate = self
//                audioPlayer?.play()
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        if self.selectionView != nil {
            self.main_justplay_Btn.setImage(UIImage(named: "main_justplay_speed2"), for: .normal)
            self.isJustplay = true
            self.selectionView.removeFromSuperview()
            self.selectionView = nil
        }
    }
}


// did select Note delegate
extension musicNotePlayVC: NoteSelectionDelegate {
    func didSelectNote(name: String) {
        if self.emptyNoteView != nil {
            self.emptyNoteView.removeFromSuperview()
            self.self.emptyNoteView = nil
        }
        self.showScoreView(file: name, isreadLocal: false)
    }
}


extension musicNotePlayVC: AVAudioRecorderDelegate, AVAudioPlayerDelegate  {
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        print("Interruption")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("play end")
        self.main_keyboard_Btn.isUserInteractionEnabled = true
        self.main_sub_nav_open_Btn.isUserInteractionEnabled = true
        self.isPlaying = false
    }
}

extension musicNotePlayVC: alertViewDelegate {
    func didTapButton() {
        if self.alertView != nil {
            self.alertView.removeFromSuperview()
        }
    }
}

extension musicNotePlayVC: actionAlertViewDelegate {
    func didTapLeftBtn() {
        if self.actionAlertView != nil {
            self.actionAlertView.removeFromSuperview()
        }
    }
    
    func didTapRightBtn() {
        if self.actionAlertView != nil {
            self.actionAlertView.removeFromSuperview()
        }
    }
    
    
    
    
}

