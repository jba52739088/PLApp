//
//  KeyboardView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2019/6/25.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import UIKit

class KeyboardView: UIView {

    @IBOutlet weak var nodeKeyboard: UIView!
    @IBOutlet var nodeKeys: [UIView]!
    
    private var shouldPlayArray: [Int] = []
    private var didPlayArray: [Int] = []
    
    func getKeyboardHeight() -> CGFloat{
        return self.nodeKeyboard.frame.height
    }
    
    // 譜彈到的音符
    func userShouldPlay(note: Int) {
        self.addLayer(note, fromUser: false)
        self.shouldPlayArray.append(note)
    }
    
    // 譜彈完的音符
    func removeUserShouldPlay(note: Int) {
        if let view = nodeKeys.first(where: {$0.tag == note}) {
            guard let subLayers = view.layer.sublayers else { return }
            for layer in subLayers {
                if layer.name == "false" {
                    layer.removeFromSuperlayer()
                    if let index = shouldPlayArray.index(of: note) {
                        shouldPlayArray.remove(at: index)
                    }
                }
            }
        }
    }

    
    // 使用者彈下的音符
    func userDidPlay(note: Int) {
        self.addLayer(note, fromUser: true)
        self.didPlayArray.append(note)
    }
    
    // 使用者彈完的音符
    func userDidFinishPlay(note: Int) {
        if let view = nodeKeys.first(where: {$0.tag == note}) {
            guard let subLayers = view.layer.sublayers else { return }
            for layer in subLayers {
                if layer.name == "true" {
                    layer.removeFromSuperlayer()
                    if let index = didPlayArray.firstIndex(of: note) {
                        didPlayArray.remove(at: index)
                    }
                }
            }
        }
    }
    
    // 恢復所有音符
    func deselectAll() {
        let array = shouldPlayArray
        for item in array {
            if let view = nodeKeys.first(where: {$0.tag == item}) {
                guard let subLayers = view.layer.sublayers else { return }
                for layer in subLayers {
                    if layer.name == "false" {
                        layer.removeFromSuperlayer()
                        if let index = shouldPlayArray.firstIndex(of: item) {
                            shouldPlayArray.remove(at: index)
                        }
                    }
                }
            }
        }
    }
    
    private func addLayer(_ Tag: Int, fromUser: Bool) {
        if let view = nodeKeys.first(where: {$0.tag == Tag}) {
            let gradient : CAGradientLayer = CAGradientLayer()
            gradient.frame = view.bounds
            var cor1 = UIColor.green.cgColor
            var cor2 = UIColor.green.withAlphaComponent(0.3).cgColor
            if fromUser {
                cor1 = UIColor.orange.cgColor
                cor2 = UIColor.orange.withAlphaComponent(0.6).cgColor
            }
            let arrayColors = [cor1, cor2]
            gradient.colors = arrayColors
            gradient.name = "\(fromUser)"
            view.layer.insertSublayer(gradient, at: fromUser ? 1 : 0)
        }
    }
    
}
