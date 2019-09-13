//
//  musicNotePlay+Keyboard.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 13/09/2019.
//  Copyright © 2019 ENYUHUANG. All rights reserved.
//

import Foundation
import AudioKit
import UIKit

extension musicNotePlayVC {
    
    // 開啟midi設備偵測
    func setMidiInput() {
        midi.openInput()
        let ends:[EndpointInfo] = midi.destinationInfos
        for endpoint in ends {
            print(endpoint.name + ":" + endpoint.displayName)
            midi.openOutput()
        }
        if midi.inputNames.count > 1 {
            self.showAlertView(message: "MIDI连接成功！！")
        }
    }
}

//MARK: - 監聽鍵盤點擊
extension musicNotePlayVC: AKMIDIListener {
    func receivedMIDISetupChange() {
        if isPlaying {
            self.onClick_main_playstart_Btn(self)
        }
        if (self.midi.inputNames.count > 0) {
            self.isMidi_on = true
            self.setMidiInput()
            if isPlaying {
                self.setMain_tempplay_Btn(.Recording)
            }else {
                self.setMain_tempplay_Btn(.ON)
            }
        }else {
            self.isMidi_on = false
            self.setMain_tempplay_Btn(.OFF)
        }
        
    }
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            if velocity != 0 {
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
            }else {
                self.receivedMIDINoteOff(noteNumber: noteNumber, velocity: velocity, channel: channel)
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
