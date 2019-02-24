//
//  PianoView.swift
//  pianoLearningApp
//


import UIKit
import PianoView

class CustomPianoView: UIView {
    
    var pianoView: PianoView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGray
        configPianoView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configPianoView(){
        pianoView = PianoView(frame: CGRect(x: 0, y: 8, width: self.frame.width, height: self.frame.height - 8))
        pianoView.startOctave = 2
        pianoView.keyCount = 52
        pianoView.whiteKeyBackgroundColor = UIColor.white
        pianoView.blackKeyBackgroundColor = UIColor.black
        pianoView.whiteKeySelectedColor = UIColor.orange
        pianoView.whiteKeyHighlightedColor = UIColor.green
        pianoView.blackKeySelectedColor = UIColor.orange
        pianoView.blackKeyHighlightedColor = UIColor.green
        pianoView.whiteKeyBorderColor = UIColor.darkGray
        pianoView.blackKeyBorderColor = UIColor.black
        pianoView.whiteKeyBorderWidth = 1
        pianoView.blackKeyBorderWidth = 1
        pianoView.drawNoteText = false
        pianoView.drawNoteOctave = false
//        pianoView.drawMask = false
        pianoView.drawGradient = false
        
        self.addSubview(pianoView)
    }
}
