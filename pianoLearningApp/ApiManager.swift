//
//  ApiManager.swift
//  pianoLearningApp
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
//                            completionHandler(false, nil)
                            completionHandler(false, JSON)
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
    func update(name: String, account: String, password: String, birth: String, mobile: String, address: String, id: Int, completionHandler: @escaping (_ status: Bool) -> Void){
        let parameters = ["cmd": "update", "account": account, "passwd": password, "name": name, "birth": birth, "mobile": mobile, "addr": address, "id": id] as [String : Any]
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
    
    /// 修改密码
    func changePwdBy(account: String, password: String, completionHandler: @escaping (_ status: Bool) -> Void){
        let parameters = ["cmd": "chPasswdByAccount", "account": account, "passwd": password] as [String : Any]
        Alamofire.request(URL_MEMBER, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            completionHandler(true)
                        }else {
                            print("API: chPasswdByAccount failed")
                            completionHandler(false)
                        }
                    }
                }else {
                    print("chPasswdByAccount: get JSON error")
                    completionHandler(false)
                }
        }
    }
    
    /// 修改密码
    func changePwdBy(id: String, password: String, completionHandler: @escaping (_ status: Bool) -> Void){
        let parameters = ["cmd": "chPasswdById", "id": id, "passwd": password] as [String : Any]
        Alamofire.request(URL_MEMBER, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            completionHandler(true)
                        }else {
                            print("API: chPasswdById failed")
                            completionHandler(false)
                        }
                    }
                }else {
                    print("chPasswdById: get JSON error")
                    completionHandler(false)
                }
        }
    }
    
    /// 上傳頭貼
    func uploadUserImage(id: String, icon: String, completionHandler: @escaping (_ status: Bool) -> Void){
        let parameters = ["cmd": "uploadIcon", "id": id, "icon": icon] as [String : Any]
        Alamofire.request(URL_MEMBER, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            completionHandler(true)
                        }else {
                            print("API: uploadUserImage failed")
                            completionHandler(false)
                        }
                    }
                }else {
                    print("uploadUserImage: get JSON error")
                    completionHandler(false)
                }
        }
    }
    
    /// 意见回馈
    func uploadUserfeedBack(content: String, completionHandler: @escaping (_ status: Bool) -> Void){
        guard  let my = My else { return }
        let parameters = ["cmd": "new", "id": my.id, "account": my.account, "content": content] as [String : Any]
        Alamofire.request(URL_FEEDBACK, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            completionHandler(true)
                        }else {
                            print("API: uploadUserfeedBack failed")
                            completionHandler(false)
                        }
                    }
                }else {
                    print("uploadUserfeedBack: get JSON error")
                    completionHandler(false)
                }
        }
    }
    
    func getSongDataOnline(completionHandler: @escaping (_ status: Bool, _ names: [String]?) -> Void) {
        Alamofire.request(URL_FETCHSONG, method: .post, parameters: nil, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            if let datas = JSON["data"] as? [[String : AnyObject]]{
                                var didSaveNames: [String] = []
                                for data in datas {
                                    if let id = data["id"] as? Int,
                                        let scoreid = data["scoreid"] as? Int,
                                        let songname = data["songname"] as? String,
                                        let songfile = data["songfile"] as? String,
                                        let scorefile = data["scorefile"] as? String{
                                        if self.saveBase64StringToPNG(fileName: "\(id)_\(scoreid)_\(songname).png", base64: scorefile)
                                            && self.saveStringToJSON(fileName: "\(id)_\(scoreid)_\(songname).json", text: songfile) {
                                            didSaveNames.append("\(id)_\(scoreid)_\(songname)")
                                        }
                                    }else {
                                        print("getSongDataOnline data error")
                                    }
                                }
                                completionHandler(true, didSaveNames)
                                return
                            }
                        }else {
                            print("API: getSongDataOnline error")
                        }
                    }
                }else {
                    print("getSongDataOnline: get JSON error")
                }
                completionHandler(false, nil)
        }
    }
    
    func saveBase64StringToPNG(fileName: String, base64: String) -> Bool {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataDecoded : Data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters)!
        if let decodedimage = UIImage(data: dataDecoded) {
            do {
                let fileURL = documentsURL.appendingPathComponent(fileName)
                if let pngImageData = UIImagePNGRepresentation(decodedimage) {
                    try pngImageData.write(to: fileURL, options: .atomic)
                    return true
                }
            } catch {
                print("sava image error")
            }
        }else {
            print("convert image to data error")
        }
        return false
    }
    
    func saveStringToJSON(fileName: String, text: String) -> Bool {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
                return true
            }
        } catch let error {
            print(error)
        }
        return false
    }
}
