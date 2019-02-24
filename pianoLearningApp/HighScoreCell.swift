//
//  HighScoreCell.swift
//  pianoLearningApp
//


import UIKit

class HighScoreCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var progress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
