//
//  musicNotePlayVC_view.swift
//  pianoLearningApp
//
//  Created by Vincent_Huang on 2019/3/13.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import Foundation
import UIKit
//import LSFloatingActionMenu
//import HHFloatingView

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
        self.actionMenu = HHFloatingView(frame: CGRect(origin: CGPoint(x: self.musicNoteView.bounds.maxX - 25 - self.main_keyboard_Btn.frame.width, y: self.main_keyboard_Btn.frame.minY), size: self.main_keyboard_Btn.frame.size))
        self.actionMenu.delegate = self
        self.actionMenu.datasource = self
        self.musicNoteView.addSubview(self.actionMenu)
        self.constraintBottom = NSLayoutConstraint (item: self.actionMenu!,
                                                   attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.musicNoteView,
                                                   attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1,
                                                   constant: 0)
        self.musicNoteView.addConstraints([constraintBottom])
        self.musicNoteView.layoutIfNeeded()
        self.actionMenu.reload()
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
//        if !pianoIsVisible {
//            pianoIsVisible = true
//            spaceView_1.isHidden = false
//            spaceView_2.isHidden = false
//            self.musicNoteView.frame.size.height -= self.keyboardView.getKeyboardHeight()
//            self.musicNoteViewBottom.constant += self.keyboardView.getKeyboardHeight()
//            self.actionMenu.frame = CGRect(origin: CGPoint(x: self.actionMenu.frame.origin.x, y: self.main_keyboard_Btn.frame.origin.y), size: self.main_keyboard_Btn.frame.size)
//            UIView.animate(withDuration:  0.3, animations: {
//                self.actionMenu.center = CGPoint(x: self.actionMenu.center.x, y: self.actionMenu.center.y - self.keyboardView.getKeyboardHeight())
//                self.actionMenu.handlerButton?.center = CGPoint(x: self.actionMenu.center.x, y: self.actionMenu.center.y)
//                for option in self.actionMenu.options {
//                    option.center = CGPoint(x: option.center.x, y: self.actionMenu.center.y)
//                }
//                self.musicNoteView.layoutIfNeeded()
//            }) { (_) in
//                completionHandler()
//            }
//        }else {
//            pianoIsVisible = false
//            spaceView_1.isHidden = true
//            spaceView_2.isHidden = true
//            self.musicNoteView.layoutIfNeeded()
//            self.musicNoteViewBottom.constant -= self.keyboardView.getKeyboardHeight()
//            self.musicNoteView.frame.size.height += self.keyboardView.getKeyboardHeight()
//            UIView.animate(withDuration:  0.3, animations: {
//                self.actionMenu.center = CGPoint(x: self.actionMenu.center.x, y: self.actionMenu.center.y + self.keyboardView.getKeyboardHeight())
//                self.actionMenu.handlerButton?.center = CGPoint(x: self.actionMenu.center.x, y: self.actionMenu.center.y)
//                for option in self.actionMenu.options {
//                    option.center = CGPoint(x: option.center.x, y: self.actionMenu.center.y)
//                }
//                self.musicNoteView.layoutIfNeeded()
//            }) { (_) in
//                completionHandler()
//            }
//        }
    }
}

extension musicNotePlayVC: HHFloatingViewDatasource {
    func floatingViewConfiguration(floatingView: HHFloatingView) -> HHFloatingViewConfiguration {
        let configure = HHFloatingViewConfiguration.init()
        configure.animationTimerDuration = 0.1
        configure.optionsDisplayDirection = .left
        configure.numberOfOptions = 5
        configure.handlerSize = self.main_keyboard_Btn.frame.size
        configure.optionsSize = self.main_keyboard_Btn.frame.size
        configure.initialMargin = 12
        configure.internalMargin = 12
        configure.handlerImage = UIImage(named: "main_sub_nav_open")!
        configure.handlerCloseImage = UIImage(named: "main_sub_nav_close")!
        configure.handlerColor = UIColor.clear
        configure.optionImages = self.floatingViewOptionImgs()
        configure.optionColors = [UIColor.clear,
                                  UIColor.clear,
                                  UIColor.clear,
                                  UIColor.clear,
                                  UIColor.clear]
        configure.isDraggable = false
        return configure
    }
}

//MARK: HHFloatingViewDelegate
extension musicNotePlayVC: HHFloatingViewDelegate {
    
    func floatingViewOptionImgs() -> [UIImage] {
        var options: [UIImage] = []
        for i in 0 ..< self.floatBtnMode.count {
            if !floatBtnMode[i] {
                options.append(UIImage(named: self.floatBtnImgNames[i])!)
            }else {
                options.append(UIImage(named: self.floatBtnImgNames[i] + "_touched")!)
            }
        }
        return options
    }
    
    func floatingView(floatingView: HHFloatingView, didTapHandler isOpening: Bool) {
        if isOpening {
            floatingView.configurations?.optionImages = floatingViewOptionImgs()
        }
        muneIsOpen = isOpening
        floatingView.reload()
    }
    
    func floatingView(floatingView: HHFloatingView, didShowOption index: Int) {

    }
    
    func floatingView(floatingView: HHFloatingView, didSelectOption index: Int) {
        print("HHFloatingView: Button Selected: \(index)")
        self.floatBtnMode[index - 1] = !self.floatBtnMode[index - 1]
        if (index - 1 == 2) {
            if (self.floatBtnMode[index - 1]) {
                self.floatBtnMode[3] = false
            }
        }else if (index - 1 == 3) {
            if (self.floatBtnMode[index - 1]) {
                self.floatBtnMode[2] = false
            }
        }
        floatingView.configurations?.optionImages = floatingViewOptionImgs()
        floatingView.reload()
    }
}
