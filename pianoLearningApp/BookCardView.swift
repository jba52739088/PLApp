//
//  BookCardView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/22.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

@IBDesignable
class BookCardView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @IBInspectable var image: UIImage?
    @IBInspectable var name: String?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        title.text = name
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,
                                 UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        
    }
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
}
