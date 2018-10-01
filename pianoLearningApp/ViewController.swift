//
//  ViewController.swift
//  MusicTest1
//
//  Created by 趙令文 on 2018/9/6.
//  Copyright © 2018年 趙令文. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scoreView: MusicScoreView!
    @IBOutlet weak var scoreView2: MusicScoreView!
    
    @IBAction func readScore1(_ sender: Any) {
        // 讀取 JSON 字串資料
        let url = Bundle.main.url(forResource: "score2", withExtension: "json")
        do {
            let data = try Data(contentsOf: url!)
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Array<Array<Array<Dictionary<String,String>>>>
            let allSegs = jsonArray.count
            
            scoreView.setConfig(in: 4, n2: 4, n3: 4, n4: 4)
            //scoreView.setScore(in: jsonArray)
            
            var n = scoreView.setScore(in: jsonArray, start:0)
            
            if n<allSegs-1 {
                scoreView.setNextScoreView(in: scoreView2)
                scoreView2.isHidden = false
                scoreView2.setConfig(in: 4, n2: 4, n3: 4, n4: 4)
                scoreView2.setScore(in: jsonArray, start:n+1)
            }
            
            
        }catch{
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func readScore2(_ sender: Any) {
        scoreView.startBar()
    }
    
    @IBAction func pauseScore(_ sender: Any) {
        scoreView.pauseBar()
        scoreView2.pauseBar()
    }
    
    // 即時收到目前 bar 的音符音階資料
    @objc func receiveNotification(
        _ notification: Notification){
        if let (tone,note) = notification.object as? (Int,Float) {
            print("Got it => \(tone) : \(note)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreView2.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveNotification(_:)),
            name: NSNotification.Name(rawValue: "nowNote"),
            object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

