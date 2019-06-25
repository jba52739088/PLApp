//
//  musicNotePlayVC_view.swift
//  pianoLearningApp
//
//  Created by Vincent_Huang on 2019/3/13.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import Foundation
import UIKit
import LSFloatingActionMenu

enum RECORD_TYPE: String {
    case OFF = "off"
    case ON = "on"
    case Recording = "Recording"
    case Recorded = "Recorded"
    case RecordedPlaying = "RecordedPlaying"
}

enum ACTION_ALERT_TYPE: String {
    case PLAY_FINISHED = "playFinished"
    case PLAY_PAUSED = "playPaused"
}

extension musicNotePlayVC {
    
    // 设定播放暂存按钮
    func setMain_tempplay_Btn(_ status: RECORD_TYPE) {
        if userHasPlay {
            switch status {
            case RECORD_TYPE.ON:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = false
                self.main_tempplay_Title.isHidden = false
            case RECORD_TYPE.OFF:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay_lock"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = false
                self.main_tempplay_Title.isHidden = true
            case RECORD_TYPE.Recording:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_stop"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = true
                self.main_tempplay_Title.isHidden = true
            case RECORD_TYPE.Recorded:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = true
                self.main_tempplay_Title.isHidden = false
            case RECORD_TYPE.RecordedPlaying:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay_touched"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = true
                self.main_tempplay_Title.isHidden = false
            }
        }else {
            switch status {
            case RECORD_TYPE.ON:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = false
                self.main_tempplay_Title.isHidden = false
            case RECORD_TYPE.OFF:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay_lock"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = false
                self.main_tempplay_Title.isHidden = true
            case RECORD_TYPE.Recording:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = false
                self.main_tempplay_Title.isHidden = true
            case RECORD_TYPE.Recorded:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = false
                self.main_tempplay_Title.isHidden = false
            case RECORD_TYPE.RecordedPlaying:
                self.main_tempplay_Btn.setImage(UIImage(named: "main_tempplay"), for: .normal)
                self.main_tempplay_Btn.isUserInteractionEnabled = false
                self.main_tempplay_Title.isHidden = false
            }
        }
        
    }
    
    // 設定鋼琴畫面
    func setPianoView() {
        keyboardView = Bundle.main.loadNibNamed("KeyboardView", owner: self, options: nil)?.first as? KeyboardView
        keyboardView.frame = self.view.frame
        self.view.insertSubview(keyboardView, belowSubview: playControllerView)
    }
    
    // 設定右下角滑出之功能列
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
    
    // 顯示alert
    func showAlertView(message: String) {
        alertView = Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)?.first as? AlertView
        alertView.frame = self.view.frame
        alertView.delegate = self
        alertView.initAlert(message: message)
        self.view.addSubview(alertView)
    }
    
    func showActionAlertView(_ status: ACTION_ALERT_TYPE) {
        actionAlertView = Bundle.main.loadNibNamed("ActionAlertView", owner: self, options: nil)?.first as? ActionAlertView
        actionAlertView.frame = self.view.frame
        actionAlertView.delegate = self
        actionAlertView.initAlert()
        self.alertType = status
        switch status {
        case .PLAY_FINISHED:
            actionAlertView.firstlabel.text = "太棒了！！"
            actionAlertView.secondlabel.text = "已完成一首曲子的练习！"
            actionAlertView.thirdlabel.text = "请再接再厉"
            actionAlertView.fourthlabel.text = " "
            actionAlertView.leftBtn.setTitle("储存成绩", for: .normal)
            actionAlertView.rightBtn.setTitle("不储存", for: .normal)
        case .PLAY_PAUSED:
            actionAlertView.firstlabel.text = "这首曲子"
            actionAlertView.secondlabel.text = "尚未练习完毕，你确定要退出吗？"
            actionAlertView.thirdlabel.text = " "
            actionAlertView.fourthlabel.text = "注意：直接退出将不会储存成绩记录"
            actionAlertView.leftBtn.setTitle("继续", for: .normal)
            actionAlertView.rightBtn.setTitle("退出", for: .normal)
        }
        self.view.addSubview(actionAlertView)
    }
    
    func resetScoreViewHeight(completionHandler: @escaping () -> Void) {
        if !pianoIsVisible {
            pianoIsVisible = true
            spaceView_1.isHidden = false
            spaceView_2.isHidden = false
            self.musicNoteView.frame.size.height -= self.keyboardView.getKeyboardHeight()
            self.musicNoteViewBottom.constant += self.keyboardView.getKeyboardHeight()
            UIView.animate(withDuration:  0.3, animations: {
                self.musicNoteView.layoutIfNeeded()
            }) { (_) in
                completionHandler()
            }
        }else {
            pianoIsVisible = false
            spaceView_1.isHidden = true
            spaceView_2.isHidden = true
            self.musicNoteView.layoutIfNeeded()
            self.musicNoteViewBottom.constant -= self.keyboardView.getKeyboardHeight()
            self.musicNoteView.frame.size.height += self.keyboardView.getKeyboardHeight()
            UIView.animate(withDuration:  0.3, animations: {
                self.musicNoteView.layoutIfNeeded()
            }) { (_) in
                completionHandler()
            }
        }
    }
}

