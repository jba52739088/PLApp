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
    var actionMenu: LSFloatingActionMenu!
    
    var alertView: AlertView!
    let midi = AKMIDI()
    var i:UInt8 = 36
    let ms = 1000
    // 右下角功能列
    var muneIsOpen = false
    // 錄音＆播放&演奏曲
    var audioPlayer: AVAudioPlayer?
//    var audioRecorder: AVAudioRecorder!
//    var meterTimer:Timer!
//    var isAudioRecordingGranted: Bool!
//    var isRecording = false
//    var isRecordPlaying = false
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
    
    
//    var hasMoreScore = false  // 後面是否還有譜
    
    // 播放聲音
    let session = AVAudioSession.sharedInstance()
    // 記錄使用者彈奏
    weak var recordTimer: Timer?
    var isRecording = false
    var recordTime: Int = 0
    var playData: [PlayData] = []
    var userDidPlay = false
    var isReadLocal = false
    var msPerBeat: Float = 0 // 一拍幾毫秒
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spaceView_1.isHidden = true
        spaceView_2.isHidden = true
        setPianoView()
        let imageGif = UIImage(named: "main_playstart")
        main_playstart_Btn.setImage(imageGif, for: .normal)
        setSubNavMenu()
        self.setMidiInput()
        self.setPageIndex()
        
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
        }
        midi.openOutput("連接埠 1")
    }
    
    func showAlertView(message: String) {
        alertView = Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)?.first as? AlertView
        alertView.frame = self.view.frame
        alertView.delegate = self
        alertView.initAlert(message: message)
        self.view.addSubview(alertView)
    }
    
    func setPianoView() {
        pianoBackground = CustomPianoView(frame: CGRect(x: 0, y: self.musicNoteView.frame.maxY - 185, width: self.view.frame.width, height: 185))
        self.view.insertSubview(pianoBackground, belowSubview: musicNoteView)
    }
    
    func setSubNavMenu() {
        var mune: Array<LSFloatingActionMenuItem> = []
        let tempoBtn = LSFloatingActionMenuItem(image: UIImage(named: "main_sub_nav_tempo"), highlightedImage: UIImage(named: "main_sub_nav_tempo_touched"))
        tempoBtn?.itemSize = main_sub_nav_open_Btn.frame.size
        mune.append(tempoBtn!)
        let bgmBtn = LSFloatingActionMenuItem(image: UIImage(named: "main_sub_nav_bgm"), highlightedImage: UIImage(named: "main_sub_nav_bgm_touched"))
        bgmBtn?.itemSize = main_sub_nav_open_Btn.frame.size
        mune.append(bgmBtn!)
        let rBtn = LSFloatingActionMenuItem(image: UIImage(named: "main_sub_nav_r"), highlightedImage: UIImage(named: "main_sub_nav_r_touched"))
        rBtn?.itemSize = main_sub_nav_open_Btn.frame.size
        mune.append(rBtn!)
        let lBtn = LSFloatingActionMenuItem(image: UIImage(named: "main_sub_nav_l"), highlightedImage: UIImage(named: "main_sub_nav_l_touched"))
        lBtn?.itemSize = main_sub_nav_open_Btn.frame.size
        mune.append(lBtn!)
        let repeatBtn = LSFloatingActionMenuItem(image: UIImage(named: "main_sub_nav_repeat"), highlightedImage: UIImage(named: "main_sub_nav_repeat_touched"))
        repeatBtn?.itemSize = main_sub_nav_open_Btn.frame.size
        mune.append(repeatBtn!)
        self.actionMenu = LSFloatingActionMenu(frame: self.musicNoteView.frame, direction: LSFloatingActionMenuDirection.right, menuItems: mune, menuHandler: { (item, index) in
            //
        }, closeHandler: {
            self.muneIsOpen = false
            self.actionMenu.isHidden = true
        })
        self.actionMenu.itemSpacing = 12
        self.actionMenu.startPoint = CGPoint(x: main_sub_nav_open_Btn.center.x - main_sub_nav_open_Btn.frame.width - 12, y:  self.main_sub_nav_open_Btn.center.y - 20)
        self.actionMenu.rotateStartMenu = true
        self.view.addSubview(self.actionMenu)
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
        self.nowBarIndex = 0
        self.lastBarIndex = 0
        self.didBarIndex = 0
        self.allNoteCount = 0
        self.nowNoteCount = 0
        self.segsLabel.text = "小節 0"
        self.noteTimeLabel.text = "拍數 0"
        self.isReadLocal = false
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
    
    func clearScoreNotes() {
        scoreView.clearAllNotes()
        scoreView2.clearAllNotes()
    }
 
    @IBAction func onClick_main_slower_Btn(_ sender: Any) {
//        if !isPlaying{
//            scoreView.clearAllNotes()
//            scoreView2.clearAllNotes()
//            showScoreView(file: "score1")
//        }
//
//        DispatchQueue.main.async {
//            let note1 = Pitch(midiNote: 60)
//            self.pianoBackground.pianoView.highlightNote(note: note1)
//            let note2 = Pitch(midiNote: 62)
//            self.pianoBackground.pianoView.selectNote(note: note2)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//                self.pianoBackground.pianoView.unhighlightNote(note: note1)
//                self.pianoBackground.pianoView.deselectNote(note: note2)
//            })
//        }
//        UserDefaults.standard.set("score1", forKey: PIANO_LAST_NOTE_NAME)
//        UserDefaults.standard.synchronize()
    }
    
    @IBAction func onClick_main_faster_Btn(_ sender: Any) {
//        if !isPlaying{
//            scoreView.clearAllNotes()
//            scoreView2.clearAllNotes()
//            showScoreView(file: "score2")
//        }
//        DispatchQueue.main.async {
//            let note1 = Pitch(midiNote: 61)
//            self.pianoBackground.pianoView.highlightNote(note: note1)
//            let note2 = Pitch(midiNote: 63)
//            self.pianoBackground.pianoView.selectNote(note: note2)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//                self.pianoBackground.pianoView.unhighlightNote(note: note1)
//                self.pianoBackground.pianoView.deselectNote(note: note2)
//            })
//        }
//        UserDefaults.standard.set("score2", forKey: PIANO_LAST_NOTE_NAME)
//        UserDefaults.standard.synchronize()
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
        recordTimer?.invalidate()
        isRecording = false
        recordTimer = nil
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
                self.main_tempplay_Btn.setImage(UIImage(named: "main_stop"), for: .normal)
                
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
                self.main_tempplay_Btn.setImage(UIImage(named: "main_stop"), for: .normal)
            }
        }
    }
    
    @IBAction func onClick_main_tempplay_Btn(_ sender: Any) {
        if !self.isRecording {
            
            self.showScoreView(file: self.currentSongName ?? "", isreadLocal: true)
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
        let noteNums = ["49": "-5.5", "19": "-23", "117": "34", "88": "17", "62": "2", "116": "33.5", "16": "-25", "4": "-32", "85": "15.5", "126": "39.5", "22": "-21.5", "5": "-31", "67": "5", "20": "-22.5", "44": "-8.5", "79": "12", "99": "23.5", "60": "1", "36": "-13", "77": "11", "3": "-32.5", "41": "-10", "59": "0", "108": "29", "18": "-23.5", "50": "-5", "17": "-24", "33": "-15", "120": "36", "23": "-21", "127": "40", "86": "16", "84": "15", "91": "19", "32": "-15.5", "64": "3", "112": "31", "66": "4.5", "6": "-30.5", "0": "-34", "28": "-18", "119": "35", "98": "23", "26": "-19", "30": "-16.5", "89": "18", "35": "-14", "2": "-33", "82": "13.5", "78": "11.5", "61": "1.5", "46": "-7.5", "38": "-12", "106": "27.5", "118": "34.5", "97": "22.5", "94": "20.5", "52": "-4", "24": "-20", "110": "30", "54": "-2.5", "69": "6", "72": "8", "121": "36.5", "87": "16.5", "101": "25", "125": "39", "10": "-28.5", "71": "7", "83": "14", "63": "2.5", "109": "29.5", "9": "-29", "15": "-25.5", "95": "21", "39": "-11.5", "96": "22", "7": "-30", "12": "-27", "14": "-26", "114": "32.5", "74": "9", "92": "19.5", "122": "37", "27": "-18.5", "102": "25.5", "93": "20", "47": "-7", "111": "30.5", "104": "26.5", "76": "10", "103": "26", "25": "-19.5", "65": "4", "115": "33", "57": "-1", "124": "38", "48": "-6", "45": "-8", "40": "-11", "73": "8.5", "123": "37.5", "90": "18.5", "70": "6.5", "11": "-28", "21": "-22", "68": "5.5", "51": "-4.5", "42": "-9.5", "1": "-33.5", "107": "28", "53": "-3", "113": "32", "34": "-14.5", "80": "12.5", "31": "-16", "37": "-12.5", "81": "13", "100": "24", "29": "-17", "75": "9.5", "55": "-2", "13": "-26.5", "58": "-0.5", "105": "27", "8": "-29.5", "43": "-9", "56": "-1.5"]
        return noteNums[note] ?? ""
    }
    
    
}

//MARK: - 監聽鍵盤點擊
extension musicNotePlayVC: AKMIDIListener {
    func receivedMIDISetupChange() {
        if (self.midi.inputNames.count == 2) || (self.midi.inputNames.count == 1 && self.midi.inputNames[0] == "KEYBOARD") {
            self.showAlertView(message: "MIDI连接成功！！")
            self.setMidiInput()
        }
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
                self.recordTimer?.invalidate()
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
                    self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay"), for: .normal)
                }
                self.recordTimer = nil
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

class PlayData: NSObject {
    var index: Int!
    var note: Int!
    var starTime: Int!
    var endTime: Int!
    init(index: Int, note: Int, starTime: Int, endTime: Int) {
        self.index = index
        self.note = note
        self.starTime = starTime
        self.endTime = endTime
    }
}
