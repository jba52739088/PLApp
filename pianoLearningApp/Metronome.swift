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
    
    var audioPlayerNode:AVAudioPlayerNode
    var audioFile:AVAudioFile
    var audioEngine:AVAudioEngine
    
    static private var _shared: Metronome?
    
    static var shared: Metronome! {
        if _shared == nil {
            let url = Bundle.main.url(forResource: "click", withExtension: "wav")!
            _shared = Metronome(fileURL: url)
        }
        return _shared
    }
    
    init (fileURL: URL) {
        
        audioFile = try! AVAudioFile(forReading: fileURL)
        
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine = AVAudioEngine()
        audioEngine.attach(self.audioPlayerNode)
        
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        try! audioEngine.start()
        
    }
    
    func generateBuffer(forBpm bpm: Int) -> AVAudioPCMBuffer {
        audioFile.framePosition = 0
        let periodLength = AVAudioFrameCount(audioFile.processingFormat.sampleRate * 60 / Double(bpm))
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: periodLength)
        try! audioFile.read(into: buffer!)
        buffer?.frameLength = periodLength
        return buffer!
    }
    
    func play(bpm: Int, completionHandler: (() -> Void)?) {
        
        let buffer = generateBuffer(forBpm: bpm)
        
        self.audioPlayerNode.play()
        
        self.audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        
    }
    
    func stop() {
        audioPlayerNode.stop()
        
    }
    
}
