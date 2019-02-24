//
//  praticeRecordCell.swift
//  pianoLearningApp
//


import UIKit

protocol praticeRecordCellDelegate {
    func didTapRecordBtn(songName: String?)
    func didTapDeleteBtn(songName: String?)
}

class praticeRecordCell: UITableViewCell {
    
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var delegate: praticeRecordCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    @IBAction func tapRecordBtn(_ sender: UIButton) {
        self.delegate.didTapRecordBtn(songName: titleBtn.titleLabel?.text)
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        self.delegate.didTapDeleteBtn(songName: titleBtn.titleLabel?.text)
    }
}
