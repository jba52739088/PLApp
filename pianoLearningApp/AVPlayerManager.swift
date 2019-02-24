////
////  AVPlayerManager.swift
////  pianoLearningApp
////

//
//import Foundation
//import AVFoundation
//
//class AVPlayerManager {
//    let session = AVAudioSession.sharedInstance()
//    var audioRecorder: AVAudioRecorder?
//    var audioPlayer: AVAudioPlayer?
//    let audioURL = URL(fileURLWithPath: NSTemporaryDirectory() + "audio.ima4")
//    var midiPlayer: AVMIDIPlayer?
//    
//    func startRecord(_ sender: Any) {
//        print("OK");
//        let audioSettings = [
//            AVFormatIDKey: NSNumber(value: kAudioFormatAppleIMA4),
//            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue),
//            AVEncoderBitRateKey: NSNumber(value: 16),
//            AVNumberOfChannelsKey: NSNumber(value: 2),
//            AVSampleRateKey: NSNumber(value: 44100)
//        ]
//        
//        do {
//            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
//            try session.setActive(true)
//            audioRecorder = try AVAudioRecorder(url: audioURL, settings: audioSettings)
//            
//            guard  audioRecorder != nil  else {
//                return
//            }
//            
//            if audioRecorder!.record() {
//                print("start...")
//            }else{
//                print("xx")
//            }
//            
//        }catch {
//            print(error)
//        }
//        
//    }
//    
//    @IBAction func stopRecord(_ sender: Any) {
//        print("OK2");
//        guard  audioRecorder != nil  else {
//            return
//        }
//        
//        audioRecorder!.stop()
//        
//    }
//    
//    
//    
//    @IBAction func playRecorder(_ sender: Any) {
//        if audioPlayer == nil {
//            do {
//                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
//            }catch {
//                print(error)
//                return
//            }
//        }
//        
//        if audioPlayer!.prepareToPlay(), audioPlayer!.play() {
//            print("play")
//        }
//        
//        
//    }
//}
