//
//  ASheetRecordCell.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2019/5/12.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import UIKit

protocol ASheetRecordCellDelegate {
    func didTapFollowBtn(sheet: Sheet)
    func didTapPraticeBtn(sheet: Sheet)
    func didTapRemoveBtn(sheet: Sheet)
}

class ASheetRecordCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var praticeBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    var thisSheet: Sheet!
    var delegate: ASheetRecordCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func clickFollowBtn(_ sender: Any) {
        self.delegate.didTapFollowBtn(sheet: thisSheet)
    }
    
    @IBAction func clickPraticeBtn(_ sender: Any) {
        self.delegate.didTapPraticeBtn(sheet: thisSheet)
    }
    
    @IBAction func clickRemoveBtn(_ sender: Any) {
        self.delegate.didTapRemoveBtn(sheet: thisSheet)
    }
}
