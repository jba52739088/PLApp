//
//  User.swift
//  pianoLearningApp
//


import Foundation
import UIKit

var My: User?

class User: NSObject {
    
    var id: Int
    var name: String
    var account: String
    var passwd: String
    var birth: String
    var mobile: String
    var addr: String
    var image64: String
    
    init(id: Int, name: String, account: String, passwd: String, birth: String, mobile: String, addr: String, image64: String) {
        self.id = id
        self.name = name
        self.account = account
        self.passwd = passwd
        self.birth = birth
        self.mobile = mobile
        self.addr = addr
        self.image64 = image64
    }
    
    func equals (compareTo:User) -> Bool {
        return (self.id == compareTo.id
            && self.name == compareTo.name
            && self.account == compareTo.account
            && self.passwd == compareTo.passwd
            && self.birth == compareTo.birth
            && self.mobile == compareTo.mobile
            && self.addr == compareTo.addr
            && self.image64 == compareTo.image64
        )
    }
}
