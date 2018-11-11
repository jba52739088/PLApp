//
//  musicNotePlayVC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/9/9.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit
import LSFloatingActionMenu
import PianoView
import MusicTheorySwift
import AudioKit

class musicNotePlayVC_back: UIViewController {
    
    @IBOutlet weak var main_slower_Btn: UIButton!
    @IBOutlet weak var main_playstart_Btn: UIButton!
    @IBOutlet weak var main_faster_Btn: UIButton!
    @IBOutlet weak var main_tempplay_Btn: UIButton!
    @IBOutlet weak var main_follow_Btn: UIButton!
    @IBOutlet weak var main_justplay_Btn: UIButton!
    @IBOutlet weak var main_keyboard_Btn: UIButton!
    @IBOutlet weak var main_sub_nav_open_Btn: UIButton!
    
//    @IBOutlet weak var pianoBackground: UIView!
    var pianoBackground: CustomPianoView!
//    @IBOutlet weak var pianoView: PianoView!
    @IBOutlet weak var playControllerView: UIView!
    @IBOutlet weak var musicNoteView: UIView!
    @IBOutlet weak var musicNoteViewBottom: NSLayoutConstraint!
    
    
    @IBOutlet weak var noteBackground: UIView!
    var scrollView: NoteScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    
    
    @IBOutlet weak var scoreView: MusicScoreView!
    @IBOutlet weak var scoreView2: MusicScoreView!
    
//    weak var scoreView: MusicScoreView!
    
    
    var views:[MusicNoteView] = []
//    var views:[MusicScoreView] = []
    
    
    var isPlaying = false
    
    var actionMenu: LSFloatingActionMenu!
    
    let midi = AKMIDI()
    var i:UInt8 = 36
    let ms = 1000
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        setPianoView()
      
        let imageGif = UIImage.gifImageWithName("playing")
        main_playstart_Btn.setImage(imageGif, for: .normal)
        
        setSubNavMenu()
        
        
        midi.addListener(self)
        midi.openInput()
        let ends:[EndpointInfo] = midi.destinationInfos
        for endpoint in ends {
            print(endpoint.name + ":" + endpoint.displayName)
        }
        
        midi.openOutput("連接埠 1")
        
        
        
        
        setPageController()
        
        
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveNotification(_:)),
            name: NSNotification.Name(rawValue: "nowNote"),
            object: nil)
    }
    
    
    func setPianoView() {
        pianoBackground = CustomPianoView(frame: CGRect(x: 0, y: self.musicNoteView.frame.maxY - 185, width: self.view.frame.width, height: 185))
        self.view.insertSubview(pianoBackground, belowSubview: musicNoteView)
//        self.view.addSubview(pianoBackground)
        
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
        pageControl.numberOfPages = views.count
        pageControl.currentPage = 0
        self.view.bringSubview(toFront: pageControl)
    }

    func test() {
        
//        // 讀取 JSON 字串資料
//        let url = Bundle.main.url(forResource: "score2", withExtension: "json")
//        do {
//            let data = try Data(contentsOf: url!)
//            let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Array<Array<Array<Dictionary<String,String>>>>
//            let allSegs = jsonArray.count
//            
//            scrollView = NoteScrollView(frame: self.noteBackground.frame)
//            scoreView.setConfig(in: 4, n2: 4, n3: 4, n4: 4)
//            views = self.scrollView.createNoteViews()
//            self.scrollView.setupNoteScrollView(views: views)
//            scrollView.delegate = self
////            self.noteBackground.addSubview(scrollView)
//            
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
        
    }
    
    @IBAction func onClick_main_slower_Btn(_ sender: Any) {
        
        DispatchQueue.main.async {
            let note1 = Pitch(midiNote: 60)
            self.pianoBackground.pianoView.highlightNote(note: note1)
            let note2 = Pitch(midiNote: 62)
            self.pianoBackground.pianoView.selectNote(note: note2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.pianoBackground.pianoView.unhighlightNote(note: note1)
                self.pianoBackground.pianoView.deselectNote(note: note2)
            })
        }
        
    }
    
    @IBAction func onClick_main_faster_Btn(_ sender: Any) {
        
        DispatchQueue.main.async {
            let note1 = Pitch(midiNote: 61)
            self.pianoBackground.pianoView.highlightNote(note: note1)
            let note2 = Pitch(midiNote: 63)
            self.pianoBackground.pianoView.selectNote(note: note2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.pianoBackground.pianoView.unhighlightNote(note: note1)
                self.pianoBackground.pianoView.deselectNote(note: note2)
            })
        }
        
    }

    @IBAction func onClick_main_playstart_Btn(_ sender: Any) {
        if self.scrollView == nil {
            self.test()
            return
        }
        
        if !isPlaying {
            let imageGif = UIImage.gifImageWithName("recording")
            main_playstart_Btn.setImage(imageGif, for: .normal)
            isPlaying = !isPlaying
            
            
            
            scoreView.startBar()
        }else {
            let imageGif = UIImage.gifImageWithName("playing")
            main_playstart_Btn.setImage(imageGif, for: .normal)
            isPlaying = !isPlaying
            
            
            
            scoreView.pauseBar()
            scoreView2.pauseBar()
        }
    }
    
    var pianoIsVisible = false
    
    
    @IBAction func onClick_main_keyboard_Btn(_ sender: Any) {
        if !pianoIsVisible {
            pianoIsVisible = true
            self.musicNoteView.layoutIfNeeded()
            self.musicNoteViewBottom.constant = 165
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
        
    }
    
    var muneIsOpen = false
    
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
    
    
    var ii = 0
    
    // 即時收到目前 bar 的音符音階資料
    @objc func receiveNotification(_ notification: Notification){
        if ii == 2 {
            self.pianoBackground.pianoView.deselectAll()
            ii = 0
        }
        if let (tone,note) = notification.object as? (Int,Float) {
            print("Got it => \(tone + 53) : \(note)")
            let note = Pitch(midiNote: tone + 53)
            self.pianoBackground.pianoView.selectNote(note: note)
            ii += 1
            
        }
    }
}

extension musicNotePlayVC_back: AKMIDIListener {
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
//            self.value1.text = "Key: " + String(noteNumber) + "; " +
//                "Speed: " + String(velocity)
            let note = Pitch(midiNote: Int(noteNumber))
            self.pianoBackground.pianoView.highlightNote(note: note)
        }
        
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            //            self.value1.text = "Key: " + String(noteNumber) + "; " +
            //                "Speed: " + String(velocity)
            let note = Pitch(midiNote: Int(noteNumber))
            self.pianoBackground.pianoView.unhighlightNote(note: note)
        }
    }
}

extension musicNotePlayVC_back: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/self.noteBackground.frame.width)
        pageControl.currentPage = Int(pageIndex)

    }

}
