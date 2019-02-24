//
//  UserDefaultsKey.swift
//  pianoLearningApp
//


import Foundation

let PIANO_ACCOUNT = "###PIANO_ACCOUNT"
let PIANO_PASSWORD = "###PIANO_PASSWORD"
let PIANO_LAST_NOTE_NAME = "###PIANO_LAST_NOTE_NAME"
let PIANO_USER_PHOTO_TAG = "###PIANO_USER_PHOTO_TAG"


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
    
    static var LAST_NOTE_NAME:String{
        get{
            return UserDefaults.standard.string(forKey: PIANO_LAST_NOTE_NAME) ?? ""
        }
    }
    
    static var USER_PHOTO_TAG:Int{
        get{
            return UserDefaults.standard.integer(forKey: PIANO_USER_PHOTO_TAG)
        }
    }
 
}
