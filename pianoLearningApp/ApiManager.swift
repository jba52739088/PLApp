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
    
    /// 常見問題
    func getFAQ(completionHandler: @escaping (_ resault: String) -> Void){
        let parameters = ["cmd": "all"] as [String : Any]
        Alamofire.request(URL_FAQ, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            if let data = JSON["data"] as? String{
                                completionHandler(data)
                            }
                        }else {
                            print("API: getFAQ failed")
                            completionHandler("")
                        }
                    }
                }else {
                    print("getFAQ: get JSON error")
                    completionHandler("")
                }
        }
    }
    
    // 取得所有譜
    func getSongDataOnline() -> Bool {
        Alamofire.request(URL_FETCHSONG, method: .post, parameters: nil, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            if let datas = JSON["data"] as? [[String : AnyObject]]{
                                for data in datas {
                                    if let id = data["id"] as? Int,                                         // 學階
                                        let name = data["name"] as? String,                                 // 學階名稱
                                        let description = data["description"] as? String,                   // 學階敘述
                                        let books = data["book"] as? [[String : AnyObject]] {
                                        var bookNo = 0
                                        for book in books {
                                            bookNo += 1
                                            if  let sid = book["sid"] as? Int,                              // 學階id
                                                let bid = book["id"] as? Int,                               // 書id
                                                let bname = book["bname"] as? String,                       // 書名
                                                let img = book["img"] as? String,                           // 書圖片
                                                let songs = book["song"] as? [[String : AnyObject]]         // 譜s
                                            {
                                                for song in songs {
                                                    if let sname = song["sname"] as? String,                // 譜名
                                                        // let smp3 = song["smp3"] as? String, // mp3
                                                        let sjson = song["sjson"] as? String                // 譜json
                                                    {
                                                        let sheetDownload = self.saveStringToJSON(fileName: "\(sid)_\(bookNo)_\(sname).json", text: sjson)
                                                        let aSheet = Sheet(name: sname, level: "\(id)", book: "\(bookNo)", isDownloaded: sheetDownload, completion: 0, recorded: "")
                                                        if !SQLiteManager.shared.insertSheetInfo(aSheet) {
                                                            print("insert sheet '\(sname)' to db error")
                                                        }
                                                        
                                                    }
                                                }
                                                let imgDownloaded = self.saveBase64StringToPNG(fileName: "\(bname).png", base64: img)
                                                let aBook = Book(name: bname, level: id, bookLevel: bookNo, bid: bid, isImgDownloaded: imgDownloaded, completion: 0, sheetCount: songs.count)
                                                if !SQLiteManager.shared.insertBookInfo(aBook) {
                                                    print("insert book '\(bname)' to db error")
                                                }
                                            }else {
                                                print("getSongDataOnline book songs data error")
                                            }
                                        }
                                    }else {
                                        print("getSongDataOnline book data error")
                                    }
                                }
                            }else {
                                print("getSongDataOnline data error")
                            }
                        }
                    }
                }else {
                    print("getSongDataOnline: get JSON error")
                }
        }
        return true
    }
    
    // 取得書圖片
    func getBookImage(level: Int, bookName: String) -> Bool {
        let parameters = ["level": level, "bname": bookName] as [String : Any]
        Alamofire.request(URL_FETCH_BOOK_IMG, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    if let result = JSON["result"] as? String{
                        if result == "0" {
                            if let books = JSON["data"] as? [[String : AnyObject]]{
                                for book in books {
                                    if  let sid = book["sid"] as? Int,                              // 學階id
                                        let bid = book["id"] as? Int,                               // 書id
                                        let bname = book["bname"] as? String,                       // 書名
                                        let img = book["img"] as? String{
                                        let imgDownloaded = self.saveBase64StringToPNG(fileName: "\(bname).png", base64: img)
                                        let aBook = Book(name: bname, level: sid, bookLevel: -1, bid: bid, isImgDownloaded: imgDownloaded, completion: 0, sheetCount: -1)
                                        if !SQLiteManager.shared.updateBookInfo(aBook) {
                                            print("update book '\(bname)' to db error")
                                        }
                                    }else {
                                        print("getSongDataOnline book data error")
                                    }
                                }
                            }else {
                                print("getSongDataOnline data error")
                            }
                        }
                    }
                }else {
                    print("getSongDataOnline: get JSON error")
                }
        }
        return true
    }
    
    func saveBase64StringToPNG(fileName: String, base64: String) -> Bool {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let dataDecoded : Data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else { print("convert data to image error"); return false }
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
