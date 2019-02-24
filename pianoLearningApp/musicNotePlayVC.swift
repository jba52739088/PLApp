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
    // 現在五線譜跑到第幾小節
    var nowBarIndex = 0
    // 跑到第幾個scoreView
    var nowScoreIndex = 0
    
    // scoreView判斷用
    var pianoIsVisible = false
    var didBegin = false
    var order = 0
    var n = 0
    var allSegs = 0
    
    //录音
    let session = AVAudioSession.sharedInstance()
//    var audioRecorder: AVAudioRecorder?
//    var audioPlayer: AVAudioPlayer?
    let audioURL = URL(fileURLWithPath: NSTemporaryDirectory() + "audio.ima4")
    var midiPlayer: AVMIDIPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPianoView()
        let imageGif = UIImage(named: "main_playstart")
        main_playstart_Btn.setImage(imageGif, for: .normal)
        setSubNavMenu()
        self.setMidiInput()
        setPageController()
        
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
            self.showScoreView(file: UserDefaultsKeys.LAST_NOTE_NAME)
        }
       
    }
    
    // 左边slider
    @IBAction func didDragBmpSlider(_ sender: UISlider) {
        self.bmpLabel.text = "\(Int(sender.value)) bmp"
    }
    
    @IBAction func didFinishDragSlider(_ sender: UISlider) {
        print(Int(sender.value))
        self.didFinishPlay(scoreOrder: 0)
    }
    
    func setMidiInput() {
        midi.addListener(self)
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
    
    func setPageController() {
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        self.view.bringSubview(toFront: pageControl)
    }

    

    // 寫死兩個sroreView
    func showScoreView(file: String) {
//        scoreView2.isHidden = true
        scoreView.setBeat(setBeat: bmpSlider.value / 60)
        scoreView2.setBeat(setBeat: bmpSlider.value / 60)
        // 讀取 JSON 字串資料
        guard let url = Bundle.main.url(forResource: file, withExtension: "json") else { return }
        self.currentSongName = file
        do {
            let data = try Data(contentsOf: url)
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Array<Array<Array<Dictionary<String,String>>>>
            allSegs = jsonArray.count
            scoreView.setConfig(in: 3, n2: 4, n3: 3, n4: 4)
            scoreView.delegate = self

//            // 載入樂譜有幾列, 需要幾個 ScoreView
//            let lines = scoreView.getScoreViewCount(in: jsonArray)
//            print("scoreview count = \(lines)")
            if  order != 0 {
                order += 1
            }
            if  n != 0 {
                n += 1
            }
            let scoreViewN = scoreView.setScore(in: jsonArray, start: n, order: order, isFirst: n == 0, isLast: n>=allSegs-1)
            n = scoreView.setScore(in: jsonArray, start: n, order: order, isFirst: n == 0, isLast: scoreViewN>=allSegs-1)

            if n<allSegs-1 {
                order += 1
                scoreView.setNextScoreView(in: scoreView2)
                scoreView2.isHidden = false
                scoreView2.setConfig(in: 3, n2: 4, n3: 3, n4: 4)
                let score2ViewN = scoreView2.setScore(in: jsonArray, start:n+1, order: order, isFirst: false, isLast: n>=allSegs-1)
                n = scoreView2.setScore(in: jsonArray, start:n+1, order: order, isFirst: false, isLast: score2ViewN>=allSegs-1)
                scoreView2.delegate = self
                if n<allSegs-1 {
                    scoreView2.setNextScoreView(in: scoreView)
                }else {
                    scoreView2.setNextScoreView(in: nil)
                }
            }else {
                scoreView.setNextScoreView(in: nil)
            }
            didBegin = true

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
//            let imageGif = UIImage.gifImageWithName("playing")
            let imageGif = UIImage(named: "main_playstart")
            main_playstart_Btn.setImage(imageGif, for: .normal)
        }
        
        
    }
    
    
    @IBAction func onClick_main_playstart_Btn(_ sender: Any) {
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
                    self.showScoreView(file: UserDefaultsKeys.LAST_NOTE_NAME)
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
                
            }else {
                let imageGif = UIImage(named: "main_playstart")
                main_playstart_Btn.setImage(imageGif, for: .normal)
                isPlaying = !isPlaying
                if self.nowScoreIndex == 0 {
                    scoreView.pauseBar()
                }else {
                    scoreView2.pauseBar()
                }
            }
        }
    }
    
    //MARK: - 點擊鍵盤按鈕
    /// 點擊鍵盤按鈕
    @IBAction func onClick_main_keyboard_Btn(_ sender: Any) {
        if isPlaying {
            self.onClick_main_playstart_Btn(self)
        }
//        self.clearScoreNotes()
        if self.nowScoreIndex == 0 {
            scoreView.isHidden = false
        }else {
            scoreView2.isHidden = true
        }
        if !pianoIsVisible {
            pianoIsVisible = true
//            self.musicNoteView.layoutIfNeeded()
            self.musicNoteView.frame.size.height -= 165
            self.musicNoteViewBottom.constant += 165
            UIView.animate(withDuration: 0.3, animations: {
                self.musicNoteView.layoutIfNeeded()
            })
        }else {
            pianoIsVisible = false
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
        }
        
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            let note = Pitch(midiNote: Int(noteNumber))
            self.pianoBackground.pianoView.unhighlightNote(note: note)
        }
    }
}

//MARK: - MusicScoreViewDelegate

extension musicNotePlayVC: MusicScoreViewDelegate {

    // scoreIndex：score, Pith：音名, time：拍子, barIndex：小節, NoteIndex：第幾個音符
    func noteShouldPlay(scoreIndex: Int, pitch: UInt8, time: Float, barIndex: Int, NoteIndex: Int) {
        if NoteIndex != self.shouldNoteIndex || self.nowBarIndex != barIndex{
            self.pianoBackground.pianoView.deselectAll()
        }
        
        self.nowBarIndex = barIndex
        self.shouldNoteIndex = NoteIndex
        self.nowScoreIndex = scoreIndex % 2
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
        print("nowScoreIndex: \(nowScoreIndex)")
        let note = Pitch(midiNote: Int(pitch))
        self.pianoBackground.pianoView.selectNote(note: note)
    }
    
    func didFinishPlay(scoreOrder: Int) {
        print("didFinishPlay scoreOrder: \(scoreOrder)")
        self.pianoBackground.pianoView.deselectAll()
        guard let song = self.currentSongName else { return }
        print("n: \(n), allSegs: \(allSegs)")
        if n<allSegs-1 {
            if scoreOrder % 2 != 1 {
                self.scoreView2.startBar()
            }else {
//                self.clearScoreNotes()
                self.showScoreView(file: song)
                self.scoreView.startBar()
            }
        }else {
            let imageGif = UIImage(named: "main_playstart")
            main_playstart_Btn.setImage(imageGif, for: .normal)
            self.isPlaying = false
            self.bmpSlider.isUserInteractionEnabled = true
//            self.showScoreView(file: song)
            self.nowScoreIndex = 0
            self.didBegin = false
            self.order = 0
            self.n = 0
            self.allSegs = 0
//            self.showScoreView(file: song)
            self.scoreView.stopBar()
            self.scoreView2.stopBar()
        }
        

//        let imageGif = UIImage.gifImageWithName("playing")
        
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
        self.showScoreView(file: name)
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
