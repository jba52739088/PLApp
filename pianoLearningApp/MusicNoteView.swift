//
//  MusicNoteView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/9/16.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class MusicNoteView: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    var view_1: MusicScoreView!
    var view_2: MusicScoreView!
    var jsonArray: Array<Array<Array<Dictionary<String,String>>>> = []
    var allSegs = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        readJSON()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        readJSON()
    }
    
    func setStackView(count: Int, start: Int) {
//        if count == 1{
//            view_1 = MusicScoreView(frame: CGRect.zero)
//            view_1.setConfig(in: 4, n2: 4, n3: 4, n4: 4)
//            let n = view_1.setScore(in: jsonArray, start: 0)
//            self.stackView.addArrangedSubview(view_1)
//            stackView.translatesAutoresizingMaskIntoConstraints = false
//        }else{
//            view_1 = MusicScoreView(frame: CGRect.zero)
//            view_2 = MusicScoreView(frame: CGRect.zero)
//            view_1.setConfig(in: 4, n2: 4, n3: 4, n4: 4)
//            view_2.setConfig(in: 4, n2: 4, n3: 4, n4: 4)
//            let n = view_1.setScore(in: jsonArray, start: 0)
//            view_2.setScore(in: jsonArray, start:n+1)
//            self.stackView.addArrangedSubview(view_1)
//            self.stackView.addArrangedSubview(view_2)
//            stackView.translatesAutoresizingMaskIntoConstraints = false
//        }
        
        
        
    }
    
    func readJSON() {
        // 讀取 JSON 字串資料
        let url = Bundle.main.url(forResource: "score2", withExtension: "json")
        do {
            let data = try Data(contentsOf: url!)
            jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Array<Array<Array<Dictionary<String,String>>>>
            allSegs = jsonArray.count
        }catch{
            print(error.localizedDescription)
        }
    }
}
