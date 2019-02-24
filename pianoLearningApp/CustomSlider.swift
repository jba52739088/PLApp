//
//  CustomSlider.swift
//  pianoLearningApp
//


import UIKit

class CustomMainSlider: UISlider {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let image = UIImage(named: "controlpanel_slider_volume_dot") {
            self.setThumbImage(self.imageWithImage(image: image, scaledToSize: CGSize(width: 20, height: 20)), for: .normal)
        }
        self.minimumTrackTintColor = UIColor.white
        self.maximumTrackTintColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1)
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 5
        return newBounds
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
        
    }
}


class CustomSubSlider: UISlider {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let image = UIImage(named: "main_tempo_bar_dot") {
            self.setThumbImage(self.imageWithImage(image: image, scaledToSize: CGSize(width: 15, height: 15)), for: .normal)
        }
        self.minimumTrackTintColor = UIColor(red: 233/255, green: 231/255, blue: 216/255, alpha: 1)
        self.maximumTrackTintColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 3
        return newBounds
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
        
    }
}


class CustomvVolumeSlider: UISlider {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let image = UIImage(named: "controlpanel_slider_volume_dot") {
            self.setThumbImage(self.imageWithImage(image: image, scaledToSize: CGSize(width: 20, height: 20)), for: .normal)
        }
        self.minimumTrackTintColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1)
        self.maximumTrackTintColor = UIColor.white
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 5
        return newBounds
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
}
