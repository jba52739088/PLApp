//
//  ApiManager.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/25.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import Foundation
import Alamofire

class APIManager {
    
    static private var _shared: APIManager?
    
    static var shared: APIManager! {
        if _shared == nil {
            _shared = APIManager()
        }
        return _shared
    }
    
    init() {
    }
    
    /// 登入
    func login(account: String, password: String, completionHandler: @escaping (_ status: Bool, _ data: [String : AnyObject]?) -> Void){
        let parameters = ["cmd": "login", "account": account, "passwd": password] as [String : Any]
        Alamofire.request(URL_MEMBER, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            let data = JSON["data"] as? [String : AnyObject] ?? [:]
                            completionHandler(true, data)
                        }else {
                            print("API: login error")
                            completionHandler(false, nil)
                        }
                    }
                }else {
                    print("requestUserToken: get JSON error")
                    completionHandler(false, nil)
                }
        }
    }
    
    /// 注册
    func register(name: String, account: String, password: String, birth: String, mobile: String, address: String, completionHandler: @escaping (_ status: Bool) -> Void){
        let parameters = ["cmd": "new", "account": account, "passwd": password, "name": name, "birth": birth, "mobile": mobile, "addr": address] as [String : Any]
        Alamofire.request(URL_MEMBER, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            completionHandler(true)
                        }else {
                            print("API: register error")
                            completionHandler(false)
                        }
                    }
                }else {
                    print("register: get JSON error")
                    completionHandler(false)
                }
        }
    }
    
    /// 检查帐号是否存在
    func accountIsExist(account: String, completionHandler: @escaping (_ status: Bool, _ data: [String : AnyObject]?) -> Void){
        let parameters = ["cmd": "queryByAccount", "account": account] as [String : Any]
        Alamofire.request(URL_MEMBER, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            completionHandler(true, nil)
                        }else {
                            print("API: account is exist")
                            let data = JSON["data"] as? [String : AnyObject] ?? [:]
                            completionHandler(false, data)
                        }
                    }
                }else {
                    print("accountIsExist: get JSON error")
                    completionHandler(false, nil)
                }
        }
    }
    
    /// 更新会员资料
    func update(name: String, account: String, password: String?, birth: String, mobile: String, address: String, id: String, completionHandler: @escaping (_ status: Bool) -> Void){
        let parameters = ["cmd": "update", "account": account, "passwd": password ?? "", "name": name, "birth": birth, "mobile": mobile, "addr": address, "id": id] as [String : Any]
        Alamofire.request(URL_MEMBER, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            completionHandler(true)
                        }else {
                            print("API: update error")
                            completionHandler(false)
                        }
                    }
                }else {
                    print("update: get JSON error")
                    completionHandler(false)
                }
        }
    }
    
    /// 忘记帐号
    func forgetPwd(account: String, completionHandler: @escaping (_ status: Bool) -> Void){
        let parameters = ["cmd": "forgetPasswd", "account": account] as [String : Any]
        Alamofire.request(URL_MEMBER, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            completionHandler(true)
                        }else {
                            print("API: account is not exist")
                            completionHandler(false)
                        }
                    }
                }else {
                    print("forgetPwd: get JSON error")
                    completionHandler(false)
                }
        }
    }
    
}
