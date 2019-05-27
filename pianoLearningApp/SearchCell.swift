//
//  SearchCell.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2019/5/20.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var name: UILabel!
    
    var aSheet: Sheet?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
