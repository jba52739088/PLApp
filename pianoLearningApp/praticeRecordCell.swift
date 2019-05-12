//
//  praticeRecordCell.swift
//  pianoLearningApp
//


import UIKit

protocol praticeRecordCellDelegate {
    func didTapTitleBtn(sheet: Sheet)
    func didTapRecordBtn(sheet: Sheet)
    func didTapDeleteBtn(sheet: Sheet, songName: String?)
}

class praticeRecordCell: UITableViewCell {
    
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    weak var thisSheet: Sheet!
    
    var delegate: praticeRecordCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func tapTitleBtn(_ sender: Any) {
        self.delegate.didTapTitleBtn(sheet: thisSheet)
    }
    
    @IBAction func tapRecordBtn(_ sender: UIButton) {
        self.delegate.didTapRecordBtn(sheet: thisSheet)
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        self.delegate.didTapDeleteBtn(sheet: thisSheet, songName: titleBtn.titleLabel?.text)
    }
}
