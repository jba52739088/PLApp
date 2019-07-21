//
//  HHFloatingViewButton.swift
//  HHFloatingView
//
//  Created by Hemang Shah on 10/18/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

public final class HHFloatingViewButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override public var frame: CGRect {
        didSet {
            self.layer.cornerRadius = self.frame.size.width/2.0
            self.layer.masksToBounds = true
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
