//
//  AddPhoto.swift
//  pianoLearningApp
//


import UIKit

class AddPhoto: UIView {
    
    @IBOutlet weak var customImgView: UIImageView!
    @IBOutlet var buttons: [UIButton]!
     var delegate: AccountPageDelegat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initView()
    }
    
    @IBAction func didSelectImage(_ sender: UIButton) {
        changeDefaultImage(tag: sender.tag)
        UserDefaults.standard.set(sender.tag, forKey: PIANO_USER_PHOTO_TAG)
        UserDefaults.standard.synchronize()
        if sender.tag == 2 {
            self.delegate?.selectImageFromImagePicker()
        }
    }
    
    func initView() {
        if  let  imageData = Data(base64Encoded: My?.image64 ?? ""),
            let image = UIImage(data: imageData) {
            self.customImgView.image = image
            self.buttons[0].setBackgroundImage(UIImage(named: "accounts_head_boy_unchosen"), for: .normal)
            self.buttons[1].setBackgroundImage(UIImage(named: "accounts_head_girl_unchosen"), for: .normal)
        }else {
            if let image = self.getSavedImage(named: "userCustomPhoto.png") {
                self.customImgView.image = image
            }else {
                self.customImgView.image = UIImage(named: "accounts_head_custom_add")
            }
            self.buttons[0].setBackgroundImage(UIImage(named: "accounts_info_boy"), for: .normal)
            self.buttons[1].setBackgroundImage(UIImage(named: "accounts_head_girl_unchosen"), for: .normal)
            
        }
        self.customImgView.contentMode = .scaleToFill
        self.customImgView.clipsToBounds = true
        self.customImgView.layer.cornerRadius = 71
        self.customImgView.layer.masksToBounds = true
        self.changeDefaultImage(tag: UserDefaultsKeys.USER_PHOTO_TAG)
        
    }
    
    func changeDefaultImage(tag: Int) {
        switch tag {
        case 0:
            print("0")
            self.buttons[0].setBackgroundImage(UIImage(named: "accounts_info_boy"), for: .normal)
            self.buttons[1].setBackgroundImage(UIImage(named: "accounts_head_girl_unchosen"), for: .normal)
            self.buttons[2].setBackgroundImage(UIImage(named: "accounts_head_custom_untouched"), for: .normal)
            self.customImgView.alpha = 0.5
        case 1:
            print("1")
            self.buttons[0].setBackgroundImage(UIImage(named: "accounts_head_boy_unchosen"), for: .normal)
            self.buttons[1].setBackgroundImage(UIImage(named: "accounts_head_girl"), for: .normal)
            self.buttons[2].setBackgroundImage(UIImage(named: "accounts_head_custom_untouched"), for: .normal)
            self.customImgView.alpha = 0.5
        case 2:
            print("2")
            self.buttons[0].setBackgroundImage(UIImage(named: "accounts_head_boy_unchosen"), for: .normal)
            self.buttons[1].setBackgroundImage(UIImage(named: "accounts_head_girl_unchosen"), for: .normal)
            self.buttons[2].setBackgroundImage(UIImage(named: "accounts_head_custom"), for: .normal)
            self.customImgView.alpha = 1
        default:
            print("didSelectImage error")
        }
    }
    
    // 取 user照片
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }


}

extension UIImage {
    
    // 修正上傳圖片若太大會轉向
    
    func fixOrientation() -> UIImage? {
        
        if (imageOrientation == .up) { return self }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.rotated(by: .pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0.0, y: size.height)
            transform = transform.rotated(by: -.pi / 2.0)
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        default:
            break
        }
        
        guard let cgImg = cgImage else { return nil }
        
        if let context = CGContext(data: nil,
                                   width: Int(size.width), height: Int(size.height),
                                   bitsPerComponent: cgImg.bitsPerComponent,
                                   bytesPerRow: 0, space: cgImg.colorSpace!,
                                   bitmapInfo: cgImg.bitmapInfo.rawValue) {
            
            context.concatenate(transform)
            
            if imageOrientation == .left || imageOrientation == .leftMirrored ||
                imageOrientation == .right || imageOrientation == .rightMirrored {
                context.draw(cgImg, in: CGRect(x: 0.0, y: 0.0, width: size.height, height: size.width))
            } else {
                context.draw(cgImg, in: CGRect(x: 0.0 , y: 0.0, width: size.width, height: size.height))
            }
            
            if let contextImage = context.makeImage() {
                return UIImage(cgImage: contextImage)
            }
            
        }
        
        return nil
    }
    
    // 縮小圖片至1KB
    func resizedTo1KB() -> UIImage? {
        guard let imageData = UIImagePNGRepresentation(self) else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1024.0
        
        while imageSizeKB > 100.0 {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = UIImagePNGRepresentation(resizedImage)
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1024.0
        }
        
        return resizingImage
    }
    
    // 縮圖
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}
