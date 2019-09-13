//
//  LoginVC.swift
//  pianoLearningApp
//


import UIKit

let btnAttributes : [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
    NSAttributedString.Key.foregroundColor : UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1),
    NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]

class LoginVC: UIViewController {
    
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgetPwdBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    var loadingView: LoadingView!
    var pwdAlertView: PwdAlertView!
    var alertView: AlertView!
    var AutoLoginTime : Timer?
    var loginSucceed = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        accountField.text = "test2"
//        passwordField.text = "test1"
        
        initView()
        showLoadingView()
    }


    @IBAction func tapLogin(_ sender: Any) {
//        if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as? TabBarVC {
//            self.present(mainVC, animated: true, completion: nil)
//        }
        if let acc = accountField.text, let pwd = passwordField.text {
            if acc == "" || pwd == "" {
                self.textFieldBackground.backgroundColor = UIColor.red
                textFieldBackground.layer.borderColor = UIColor.red.cgColor
            }
            APIManager.shared.loginWithReTry(account: acc, password: pwd) { [weak self] (status, data) in
                if status {
                    // 成功登入
                    UserDefaults.standard.set(acc, forKey: PIANO_ACCOUNT)
                    UserDefaults.standard.set(pwd, forKey: PIANO_PASSWORD)
                    UserDefaults.standard.synchronize()
                    self?.configMyUser(data: data!)
                    if let mainVC = self?.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as? TabBarVC {
                        self?.present(mainVC, animated: true, completion: nil)
                    }
                }else {
                    print("acc || pwd is error")
                    self?.textFieldBackground.backgroundColor = UIColor.red
                    self?.textFieldBackground.layer.borderColor = UIColor.red.cgColor
                    if data != nil {
                        self?.showMessageAlert(title: "", message: "\(data)")
                    }
                }
            }
        }else {
            self.textFieldBackground.backgroundColor = UIColor.red
            textFieldBackground.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    func showMessageAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapForgetBtn(_ sender: Any) {
        pwdAlertView = Bundle.main.loadNibNamed("PwdAlertView", owner: self, options: nil)?.first as? PwdAlertView
        pwdAlertView.frame = self.view.frame
        pwdAlertView.delegate = self
        pwdAlertView.initAlert()
        self.view.addSubview(pwdAlertView)
    }
    
    @IBAction func tapRegisterBtn(_ sender: Any) {
        
    }
    
    func showLoadingView() {
        loadingView = Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)?.first as? LoadingView
        loadingView.frame = self.view.frame
        self.view.addSubview(loadingView)
        if AutoLoginTime == nil {
            if UserDefaultsKeys.ACCOUNT != ""{
                APIManager.shared.loginWithReTry(account: UserDefaultsKeys.ACCOUNT, password: UserDefaultsKeys.PASSWORD) {  [weak self] (status, data)  in
                    if status {
                        self?.loginSucceed = true
                        self?.configMyUser(data: data!)
                    }
                }
            }
            AutoLoginTime =  Timer.scheduledTimer(timeInterval: TimeInterval(3), target: self, selector: #selector(removeLoadingView), userInfo: nil, repeats: true)
        }
    }
    
    func initView() {
        accountField.setLeftPaddingPoints(15)
        passwordField.setLeftPaddingPoints(15)
        textFieldBackground.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        textFieldBackground.layer.borderWidth = 1
        textFieldBackground.layer.cornerRadius = 5
        textFieldBackground.layer.masksToBounds = true
        textFieldBackground.clipsToBounds = true
        loginBtn.layer.cornerRadius = 5
        loginBtn.layer.masksToBounds = true
        loginBtn.clipsToBounds = true
        registerBtn.layer.cornerRadius = 5
        registerBtn.layer.masksToBounds = true
        registerBtn.clipsToBounds = true
        let attributeString = NSMutableAttributedString(string: "忘记密码了吗？",
                                                        attributes: btnAttributes)
        forgetPwdBtn.setAttributedTitle(attributeString, for: .normal)
    }
    
    func showAlertView(message: String) {
        alertView = Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)?.first as? AlertView
        alertView.frame = self.view.frame
        alertView.delegate = self
        alertView.initAlert(message: message)
        self.view.addSubview(alertView)
    }
    
    @objc func removeLoadingView() {
        if self.loadingView != nil {
            self.loadingView.removeFromSuperview()
            self.loadingView = nil
        }
        if AutoLoginTime != nil {
            AutoLoginTime?.invalidate()
            AutoLoginTime = nil
        }
        if loginSucceed {
            if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as? TabBarVC {
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    func configMyUser(data: [String : AnyObject]) {
        if let id = data["id"] as? Int ?? 0 as? Int,
            let name = data["name"] as? String ?? "" as? String,
            let account = data["account"] as? String ?? "" as? String,
            let passwd = data["passwd"] as? String ?? "" as? String,
            let birth = data["birth"] as? String ?? "" as? String,
            let mobile = data["mobile"] as? String ?? "" as? String,
            let addr = data["addr"] as? String ?? "" as? String{
            My = User(id: id, name: name, account: account, passwd: passwd, birth: birth, mobile: mobile, addr: addr, image64: data["icon"] as? String ?? "")
            print("config My data succeed")
        }else {
            print("user data error")
        }
    }
}

extension LoginVC: pwdAlertViewDelegate {
    
    func didTapCancelButton() {
        if self.pwdAlertView != nil {
            self.pwdAlertView.removeFromSuperview()
        }
    }
    
    func didTapSendButton() {
        if let account = self.pwdAlertView.textField.text, account != "" {
            APIManager.shared.forgetPwd(account: account) { (isSucceed) in
                if isSucceed {
                    self.showAlertView(message: "已将新密码寄送至您的\n邮箱地址，请前往查看，\n谢谢!!!")
                    self.didTapCancelButton()
                }else {
                    self.showAlertView(message: "资料错误，请填写正确资料")
                }
            }
        }
    }
}

extension LoginVC: alertViewDelegate {
    func didTapButton() {
        if self.alertView != nil {
            self.alertView.removeFromSuperview()
        }
    }
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
