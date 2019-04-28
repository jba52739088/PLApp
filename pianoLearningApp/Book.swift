//
//  Book.swift
//  pianoLearningApp
//
//  Created by Vincent_Huang on 2019/3/10.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import Foundation

class Book: NSObject {
    
    var name = ""
    var level = ""
    var isDownloaded = false
    var completion = 0
    var sheetCount = 0
    
    init(name: String, level: String, isDownloaded: Bool, completion: Int, sheetCount: Int) {
        self.name = name
        self.level = level
        self.isDownloaded = isDownloaded
        self.completion = completion
        self.sheetCount = sheetCount
    }
    
    func equals (compareTo:Book) -> Bool {
        return (self.name == compareTo.name
            && self.level == compareTo.level
            && self.isDownloaded == compareTo.isDownloaded
            && self.completion == compareTo.completion
            && self.sheetCount == compareTo.sheetCount)
    }
}
