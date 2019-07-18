//
//  accountVC.swift
//  pianoLearningApp
//


import UIKit

protocol AccountPageDelegat {
    func didModifyUserData(birth: String, phone: String, address: String, completionHandler:@escaping (Bool) -> Void)
    func didModifyPassword(password: String, completionHandler:@escaping (Bool) -> Void)
    func selectImageFromImagePicker()
    func sendFeedback(message: String, completionHandler:@escaping (Bool) -> Void)
    func doLogOut()
}

class AccountVC: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var buttonLabels: [UILabel]!

    var AddPhoto: AddPhoto?
    var FeedbackView: FeedbackView?
    var imagePicker: UIImagePickerController?
    var customviews: [UIView] = []
    var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomViews()
    }
    
    func setCustomViews() {
        let UserView: UserView = Bundle.main.loadNibNamed("UserView", owner: self, options: nil)?.first as! UserView
        UserView.frame = self.contentView.bounds
        UserView.delegate = self
        customviews.append(UserView)
        let ModifyPwdView: ModifyPwdView = Bundle.main.loadNibNamed("ModifyPwdView", owner: self, options: nil)?.first as! ModifyPwdView
        ModifyPwdView.frame = self.contentView.bounds
        ModifyPwdView.delegate = self
        customviews.append(ModifyPwdView)
        AddPhoto = Bundle.main.loadNibNamed("AddPhoto", owner: self, options: nil)?.first as! AddPhoto
        AddPhoto?.frame = self.contentView.bounds
        AddPhoto?.delegate = self
        customviews.append(AddPhoto ?? UIView())
        let QAView: QAView = Bundle.main.loadNibNamed("QAView", owner: self, options: nil)?.first as! QAView
        QAView.frame = self.contentView.bounds
        customviews.append(QAView)
        FeedbackView = Bundle.main.loadNibNamed("FeedbackView", owner: self, options: nil)?.first as! FeedbackView
        FeedbackView?.frame = self.contentView.bounds
        FeedbackView?.delegate = self
        customviews.append(FeedbackView ?? UIView())
        let LanguageView: LanguageView = Bundle.main.loadNibNamed("LanguageView", owner: self, options: nil)?.first as! LanguageView
        LanguageView.frame = self.contentView.bounds
        customviews.append(LanguageView)
        let VolumeView: VolumeView = Bundle.main.loadNibNamed("VolumeView", owner: self, options: nil)?.first as! VolumeView
        VolumeView.frame = self.contentView.bounds
        customviews.append(VolumeView)
        didTapTabBar(buttons[selectedIndex])
    }
    
    @IBAction func didTapTabBar(_ sender: UIButton) {
        for btn in self.buttons {
            btn.alpha = 0.3
        }
        for lbs in self.buttonLabels {
            lbs.alpha = 0.3
        }
        sender.alpha = 1
        self.buttonLabels[sender.tag].alpha = 1
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        let previousView = customviews[previousIndex]
        previousView.removeFromSuperview()
        let view = customviews[selectedIndex]
        view.frame = contentView.bounds
        contentView.addSubview(view)
    }
    
}

extension AccountVC: AccountPageDelegat {
    
    func doLogOut() {
        UserDefaults.standard.set("", forKey: PIANO_ACCOUNT)
        UserDefaults.standard.set("", forKey: PIANO_PASSWORD)
        UserDefaults.standard.synchronize()
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func sendFeedback(message: String, completionHandler: @escaping (Bool) -> Void) {
        APIManager.shared.uploadUserfeedBack(content: message) { (isSucceed) in
            if isSucceed {
                completionHandler(true)
            }
        }
    }
    
    func selectImageFromImagePicker() {
        self.imagePicker =  UIImagePickerController()
        self.imagePicker?.delegate = self
        self.imagePicker?.sourceType = .photoLibrary
        self.present(self.imagePicker!, animated: true, completion: nil)
    }
    
    func didModifyPassword(password: String, completionHandler: @escaping (Bool) -> Void) {
        guard let user = My else { return }
        APIManager.shared.changePwdBy(account: user.account, password: password) { (isSucceed) in
            if isSucceed {
                completionHandler(true)
            }else {
                completionHandler(false)
            }
        }
    }
    
    func didModifyUserData(birth: String, phone: String, address: String, completionHandler:@escaping (Bool) -> Void) {
        guard let user = My else { return }
        APIManager.shared.update(name: user.name, account: user.account, password: user.passwd, birth: birth, mobile: phone, address: address, id: user.id) { (isSucceed) in
            if isSucceed {
                My?.birth = birth
                My?.mobile = phone
                My?.addr = address
                completionHandler(true)
            }else {
                completionHandler(false)
            }
        }
    }

}

extension AccountVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        //        self.popWindowsDidRemove()
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage,
            let image = selectedImage.fixOrientation(){
            let imageData = image.jpegData(compressionQuality: 0.2)
            APIManager.shared.uploadUserImage(id: "\(My?.id ?? 0)", icon: imageData?.base64EncodedString() ?? "") { (isSucceed) in
                if isSucceed {
                    print("!!!!!!")
                    if self.saveImage(image: image) {
                        self.AddPhoto?.customImgView.image = image
                        self.AddPhoto?.buttons[0].setBackgroundImage(UIImage(named: "accounts_head_boy_unchosen"), for: .normal)
                        self.AddPhoto?.buttons[1].setBackgroundImage(UIImage(named: "accounts_head_girl_unchosen"), for: .normal)
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // 存user 照片
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("userCustomPhoto.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
