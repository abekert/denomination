//
//  OutlinedLabel.swift
//  Denomination
//
//  Created by Alexander Bekert on 23/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import UIKit
import QuartzCore

class UIOutlinedLabel: UILabel {
    @IBInspectable
    var outlineWidth: CGFloat = 1
    @IBInspectable
    var outlineColor: UIColor = UIColor.white
    
    override func drawText(in rect: CGRect) {
//        self.layer.borderColor = outlineColor.CGColor
//        self.layer.borderWidth = outlineWidth
//        super.drawTextInRect(rect)
        
//        let strokeTextAttributes = [
//            NSStrokeColorAttributeName : outlineColor,
//            NSStrokeWidthAttributeName : -1 * outlineWidth,
//            ]
//        
//        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
//        super.drawTextInRect(rect)
        
//        self.layer.shadowColor = outlineColor.CGColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.layer.shadowOpacity = 1.0;
//        self.layer.shadowRadius = outlineWidth;
//        self.layer.shouldRasterize = true
//        self.layer.masksToBounds = false
//        super.drawTextInRect(rect)
    }
}
