//
//  File.swift
//  pianoLearningApp
//
//  Created by Vincent_Huang on 2019/3/10.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import Foundation

class Sheet: NSObject {
    
    var name = ""
    var level = ""
    var book = ""
    var isDownloaded = false
    var completion = 0
    var recorded = 0
    var hasRecord = false
    
    init(name: String, level: String, book: String, isDownloaded: Bool, completion: Int, recorded: Int) {
        self.name = name
        self.level = level
        self.book = book
        self.isDownloaded = isDownloaded
        self.completion = completion
        self.recorded = recorded
        self.hasRecord = (recorded != 0)
    }
    
    func equals (compareTo:Sheet) -> Bool {
        return (self.name == compareTo.name
            && self.level == compareTo.level
            && self.book == compareTo.book
            && self.isDownloaded == compareTo.isDownloaded
            && self.completion == compareTo.completion
            && self.recorded == compareTo.recorded)
    }
}
