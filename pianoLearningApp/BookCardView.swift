//
//  BookCardView.swift
//  pianoLearningApp
//


import UIKit

@IBDesignable
class BookCardView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @IBInspectable var image: UIImage?
    @IBInspectable var name: String?
    
//    func initView(image: UIImage, title: String) {
//        self.imageView.image = image
//        self.title.text = title
//    }
//
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        title.text = name
    }

    let nibName = "BookCardView"
    var contentView: UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
}
