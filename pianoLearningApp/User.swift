//
//  User.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/28.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
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
    
    init(id: Int, name: String, account: String, passwd: String, birth: String, mobile: String, addr: String) {
        self.id = id
        self.name = name
        self.account = account
        self.passwd = passwd
        self.birth = birth
        self.mobile = mobile
        self.addr = addr
    }
    
    func equals (compareTo:User) -> Bool {
        return (self.id == compareTo.id
            && self.name == compareTo.name
            && self.account == compareTo.account
            && self.passwd == compareTo.passwd
            && self.birth == compareTo.birth
            && self.mobile == compareTo.mobile
            && self.addr == compareTo.addr
        )
    }
}
