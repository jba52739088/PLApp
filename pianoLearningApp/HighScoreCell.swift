//
//  HighScoreCell.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/21.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
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
