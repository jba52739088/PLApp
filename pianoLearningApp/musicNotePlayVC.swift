//
//  musicNotePlayVC.swift
//  pianoLearningApp
//


import UIKit
//import LSFloatingActionMenu
import AudioKit
import AVFoundation
import AVAudioSessionSetCategorySwift
import SwiftyJSON
//import HHFloatingView

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
    
    var keyboardView: KeyboardView!
    var selectionView: SelectionView!
    
    var alertView: AlertView!
    var actionAlertView: ActionAlertView!
    var alertType: ACTION_ALERT_TYPE!
    // AKMIDIListener
    let midi = AKMIDI()
    var i:UInt8 = 36
    let ms = 1000
    var isMidi_on = false // midi是否插入
    // 右下角功能列
    var actionMenu: HHFloatingView! // 右下功能鍵
    var muneIsOpen = false
    var floatBtnMode = [false, false, false, false, false]  // 0: isTempo, 1: isBgm, 2: isNavR, 3: isNavL, 4: isRepeat
    let floatBtnImgNames = ["main_sub_nav_tempo", "main_sub_nav_bgm", "main_sub_nav_l", "main_sub_nav_r", "main_sub_nav_repeat"]
    var constraintBottom: NSLayoutConstraint!
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
    // 播放暫存時間
    var lastRecordDate = ""
    
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
    var allCount = 0 // 全部音符
    var failedCount = 0 // 錯誤音符
    
    var deviation: TimeInterval = 0.2 // 誤差值
    var userDidPlayNote: String = ""
    var userDidPlayTime: TimeInterval = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spaceView_1.isHidden = true
        spaceView_2.isHidden = true
        midi.addListener(self)
        setPianoView()
        let imageGif = UIImage(named: "main_playstart")
        main_playstart_Btn.setImage(imageGif, for: .normal)
        
        self.setMidiInput()
        self.setPageIndex()
        self.setMain_tempplay_Btn(.OFF)
        // 若之前無讀取樂譜之情況
        if UserDefaultsKeys.LAST_NOTE_NAME == "" {
            emptyNoteView = Bundle.main.loadNibNamed("EmptyNoteView", owner: self, options: nil)?.first as! UIView
            emptyNoteView.frame = self.noteBackground.bounds
            self.noteBackground.addSubview(emptyNoteView)
        }
        
        // 炸彈
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let date = formatter.date(from: "2019/08/30 00:05")!
        let now = Date()
        if now >= date {
            self.boomIfNoMoney()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bmpLabel.text = "\(Int(self.bmpSlider.value)) bmp"
        if UserDefaultsKeys.LAST_NOTE_NAME != "" {
            self.shouldCleanNotes()
            self.showScoreView(file: UserDefaultsKeys.LAST_NOTE_NAME, isreadLocal: false)
        }
        setSubNavMenu()
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
            midi.openOutput(name: endpoint.name)
        }
        if midi.inputNames.count > 1 {
            self.showAlertView(message: "MIDI连接成功！！")
//            for item in midi.inputNames {
//                if item == "KEYBOARD" {
//
//                }
//            }
        }
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
        isRecording = false
        //
        scoreView.setPlayMode(mode: 0)
        scoreView2.setPlayMode(mode: 0)
        if self.floatBtnMode[2] {
            scoreView.setPlayMode(mode: 2)
            scoreView2.setPlayMode(mode: 2)
        }else if self.floatBtnMode[3] {
            scoreView.setPlayMode(mode: 1)
            scoreView2.setPlayMode(mode: 1)
        }
        
        scoreView.setBeat(setBeat: bmpSlider.value / 60)
        scoreView2.setBeat(setBeat: bmpSlider.value / 60)
        
        self.msPerBeat = (bmpSlider.value / 60) * 1000
        print("msPerBeat: \(self.msPerBeat)")
        
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
//        Metronome.shared.playBy(speed: Double(Int(self.bmpSlider.value)))
    }
    
    @IBAction func onClick_main_faster_Btn(_ sender: Any) {
//        Metronome.shared.stop()
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
                    self.actionMenu.close()
                    muneIsOpen = false
                }
                self.main_keyboard_Btn.isUserInteractionEnabled = false
                 self.actionMenu.isUserInteractionEnabled = false
                let imageGif = UIImage(named: "main_playstart copy")
                main_playstart_Btn.setImage(imageGif, for: .normal)
                isPlaying = !isPlaying
                self.audioPlayer?.play()
            }else {
                self.audioPlayer?.pause()
                self.main_keyboard_Btn.isUserInteractionEnabled = true
                self.actionMenu.isUserInteractionEnabled = true
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
                if self.floatBtnMode[0] {
                    Metronome.shared.play(bpm: Int(self.bmpSlider.value), completionHandler: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + (7 / 3) * (60 / self.bmpSlider.value)) {
                        if self.nowScoreIndex == 0 {
                            self.scoreView.startBar()
                        }else {
                            self.scoreView2.startBar()
                        }

                    }
                }else {
                    if self.nowScoreIndex == 0 {
                        self.scoreView.startBar()
                    }else {
                        self.scoreView2.startBar()
                    }

                }
                
                if isMidi_on {
                    if userHasPlay {
                        self.setMain_tempplay_Btn(.Recording)
                        self.isRecording = true
                    }else {
                        self.setMain_tempplay_Btn(.ON)
                    }
                }
            }else {
                Metronome.shared.stop()
                let imageGif = UIImage(named: "main_playstart")
                main_playstart_Btn.setImage(imageGif, for: .normal)
                isPlaying = !isPlaying
                if self.nowScoreIndex == 0 {
                    scoreView.pauseBar()
                }else {
                    scoreView2.pauseBar()
                }
                self.isRecording = false
                if isMidi_on {
                    if userHasPlay {
                        self.setMain_tempplay_Btn(.Recording)
                    }else {
                        self.setMain_tempplay_Btn(.ON)
                    }
                }                
            }
        }
    }
    
    @IBAction func onClick_main_tempplay_Btn(_ sender: Any) {
        self.setMain_tempplay_Btn(.RecordedPlaying)
        if !self.isRecording {
            self.showScoreView(file: (self.currentSongName ?? "") + "_" + self.lastRecordDate, isreadLocal: true)
        }else {
            self.onClick_main_playstart_Btn(self)
            self.showActionAlertView(.PLAY_PAUSED)
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
        self.resetScoreViewHeight {
            if self.pianoIsVisible{
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
    }
    
    @IBAction func testTouchDown(_ sender: Any) {
        self.receivedMIDINoteOn(noteNumber: 60, velocity: 1, channel: 1)

    }
    
    @IBAction func testTouchUp(_ sender: Any) {
        self.receivedMIDINoteOn(noteNumber: 60, velocity: 1, channel: 1)
    }
    
    func storeUserPlayedData(date: String) {
        if let paramsJSON = JSON(self.jsonArray) as? JSON {
            if let data = try? paramsJSON.rawData() {
                let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("\(self.currentSongName ?? "")_\(date).json") // Your json file name
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
        if isPlaying {
            self.onClick_main_playstart_Btn(self)
        }
        if (self.midi.inputNames.count > 0) {
//            for item in self.midi.inputNames {
//                if item == "KEYBOARD" {
            
            self.isMidi_on = true
            self.setMidiInput()
            if isPlaying {
                self.setMain_tempplay_Btn(.Recording)
            }else {
                self.setMain_tempplay_Btn(.ON)
            }
            
            
//                    return
//                }
//            }
        }else {
            self.isMidi_on = false
            self.setMain_tempplay_Btn(.OFF)
        }
        
    }
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.keyboardView.userDidPlay(note: Int(noteNumber))
            self.isRecording = self.isMidi_on
            if self.isRecording {
                if !self.userHasPlay {
                    self.userHasPlay = true
                    self.setMain_tempplay_Btn(.Recording)
                }
                self.userDidPlay = true
                self.userDidPlayNote = "\(noteNumber)"
                self.userDidPlayTime = Date().timeIntervalSince1970
            }else {
                 self.userDidPlay = true
            }
            
        }
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.keyboardView.userDidFinishPlay(note: Int(noteNumber))
            if self.isRecording {
                print("noteNumber: \(noteNumber)")
            }
        }
    }
}

//MARK: - MusicScoreViewDelegate

extension musicNotePlayVC: MusicScoreViewDelegate {
    func shouldPlayNext() {
        self.keyboardView.deselectAll()
//        print("nowSegs: \(nowSegs), allSegs: \(allSegs)")
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
        if NoteIndex != self.shouldNoteIndex || self.nowBarIndex != barIndex || NoteIndex == 0{
            self.keyboardView.deselectAll()
        }
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
        self.keyboardView.userShouldPlay(note: pitch)
//        print("self.jsonArray?[\(self.didBarIndex-1)][\(shouldNoteIndex)]")
//        print("\(self.jsonArray?[self.didBarIndex-1][shouldNoteIndex][0])")
        if isRecording {
            let thisDidBarIndex = self.didBarIndex-1
            let thisShouldNoteIndex = shouldNoteIndex
            let thisTime = Date().timeIntervalSince1970
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                self.userDidPlay = false
                let convertedNote = self.convertNoteNum(note: self.userDidPlayNote)
                print("convertedNote: \(convertedNote)")
                
                if self.userDidPlayTime >= thisTime - self.deviation && self.userDidPlayTime <= thisTime + self.deviation {
                    let shouldNote = self.jsonArray![thisDidBarIndex][thisShouldNoteIndex][0]["tone"]
                    if convertedNote != shouldNote {
                        self.jsonArray![thisDidBarIndex][thisShouldNoteIndex][0]["tone"] = convertedNote
                        
                    }
                }else {
                    self.jsonArray![thisDidBarIndex][thisShouldNoteIndex][0]["tone"] = "1"
                    self.jsonArray![thisDidBarIndex][thisShouldNoteIndex][0]["note"] = "-99"
                    self.jsonArray![thisDidBarIndex][thisShouldNoteIndex][0]["rest"] = "4"
                    self.jsonArray![thisDidBarIndex][thisShouldNoteIndex][0]["play"] = "false"
                }
            }
        }
    }
    
    func didFinishPlay() {
//        print("didFinishPlay scoreOrder: \(scoreOrder)")
        self.keyboardView.deselectAll()
//        print("nowSegs: \(nowSegs), allSegs: \(allSegs)")
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
                    
                    self.isRecording = false
                    self.setMain_tempplay_Btn(.Recorded)
                    self.showActionAlertView(.PLAY_FINISHED)
                    var allCount = 0
                    var failedCount = 0
                    for bars in self.jsonArray! {
                        for bar in bars {
                            allCount += 1
                            if bar[0]["play"] == "false" {
                                failedCount += 1
                            }
                        }
                    }
                    self.allCount = allCount
                    self.failedCount = failedCount
                }
                self.shouldCleanNotes()
                self.scoreView.stopBar()
                self.scoreView2.stopBar()
                Metronome.shared.stop()
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
    
    // 沒收到錢的炸彈
    @objc func boomIfNoMoney() {
        let alert = UIAlertController(title: nil, message: "請尊重智慧財產權", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            let i = [0, 1]
            print("\(i[2])")
        }
        alert.addAction(action)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
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
        self.actionMenu.isUserInteractionEnabled = true
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
        if self.alertType == nil { return }
        if self.actionAlertView != nil {
            switch self.alertType {
            case .PLAY_FINISHED?:
                print("储存成绩")
                print("allCount: \(self.allCount), self.failedCount: \(self.failedCount)")
                let scoreNameArray = self.currentSongName!.components(separatedBy: "_")
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                let result = formatter.string(from: date)
                self.storeUserPlayedData(date: result)
                self.lastRecordDate = result
                let completion = 100 * Float(self.allCount - self.failedCount) / Float(self.allCount)
                if let thisSheet = SQLiteManager.shared.loadSheetInfo(level: scoreNameArray[0], book: scoreNameArray[1], name: scoreNameArray[2]) {
                    if !SQLiteManager.shared.updateSheetInfo(level: scoreNameArray[0],
                                                            bookLevel: scoreNameArray[1],
                                                            name: scoreNameArray[2],
                                                            completion: Int(completion),
                                                            recorded: thisSheet.recorded + 1) {
                        print("updateSheetInfo after playing error")
                    }
                    if !SQLiteManager.shared.insertRecentData(level: Int(scoreNameArray[0]) ?? 0, date: result, sheetName: scoreNameArray[2], Completion: Int(completion)) {
                        if !SQLiteManager.shared.updateRecentData(level: Int(scoreNameArray[0]) ?? 0, date: result, sheetName: scoreNameArray[2], Completion: Int(completion)) {
                            print("insert and update recent info error")
                        }
                    }
                }
            case .PLAY_PAUSED?:
                print("继续")
            default:
                print("error")
            }
            self.actionAlertView.removeFromSuperview()
            self.alertType = nil
        }
    }
    
    func didTapRightBtn() {
        if self.alertType == nil { return }
        if self.actionAlertView != nil {
            switch self.alertType {
            case .PLAY_FINISHED?:
                print("不储存")
                self.shouldCleanNotes()
                self.scoreView.stopBar()
                self.scoreView2.stopBar()
                self.showScoreView(file: UserDefaultsKeys.LAST_NOTE_NAME, isreadLocal: false)
                self.setMain_tempplay_Btn(.ON)
            case .PLAY_PAUSED?:
                print("退出")
                self.shouldCleanNotes()
                self.scoreView.stopBar()
                self.scoreView2.stopBar()
                self.showScoreView(file: UserDefaultsKeys.LAST_NOTE_NAME, isreadLocal: false)
                self.setMain_tempplay_Btn(.ON)
            default:
                print("error")
            }
            self.actionAlertView.removeFromSuperview()
            self.alertType = nil
        }
    }
    
    
    
    
}

