//
//  UserDefaultsKey.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/27.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation

let PIANO_ACCOUNT = "###BBCall_ACCOUNT"
let PIANO_PASSWORD = "###BBCall_PASSWORD"


class UserDefaultsKeys: NSObject {
    
    static var ACCOUNT:String{
        get{
            return UserDefaults.standard.string(forKey: PIANO_ACCOUNT) ?? ""
        }
    }
    
    static var PASSWORD:String{
        get{
            return UserDefaults.standard.string(forKey: PIANO_PASSWORD) ?? ""
        }
    }
 
}
