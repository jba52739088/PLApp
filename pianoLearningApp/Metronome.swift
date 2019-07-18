//
//  Metronome.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 18/07/2019.
//  Copyright © 2019 ENYUHUANG. All rights reserved.
//

import Foundation
import AVFoundation

class Metronome {
    
    var timer: Timer!
    var audioPlayer = AVAudioPlayer()
    var isPlaying = false
    
    static private var _shared: Metronome?
    
    static var shared: Metronome! {
        if _shared == nil {
            _shared = Metronome()
            _shared?.getAudioFile()
        }
        return _shared
    }
    
    public func playBy(speed: Double) {
        if isPlaying{
            isPlaying = false
            timer.invalidate()
            timer = nil
        }else{
            isPlaying = true
            timer = Timer.scheduledTimer(timeInterval: 60/speed, target: self, selector: #selector(play), userInfo: nil, repeats: true)
        }
    }
    
    public func stop() {
        isPlaying = false
        timer.invalidate()
        timer = nil
    }
    
    private func getAudioFile() {
        let url:NSURL = Bundle.main.url(forResource: "001", withExtension: "mp3")! as NSURL
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url as URL, fileTypeHint: nil)
            
        }catch let error as NSError {
            print(error.description)
            
        }
    }
    
    @objc private func play() {
        audioPlayer.play()
    }
}
