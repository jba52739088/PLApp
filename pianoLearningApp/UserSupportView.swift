//
//  QAView.swift
//  pianoLearningApp
//


import UIKit

class UserSupportView: UIView {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var backBtn: UIButton!
    
    @IBAction func doGoBack(sender: AnyObject) {
        self.removeFromSuperview()
    }
    
    func loadData() {
        webView.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        webView.layer.borderWidth = 1
        webView.layer.cornerRadius = 10
        webView.layer.masksToBounds = true
        webView.clipsToBounds = true
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        if let url = URL(string: "http://114.34.5.111:5880/docs/guide.txt") {
            webView.loadRequest(URLRequest(url: url))
        }
    }
}
