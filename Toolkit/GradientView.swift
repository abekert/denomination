//
//  GradientView.swift
//  Denomination
//
//  Created by Alexander Bekert on 5/28/17.
//  Copyright © 2017 Alexander Bekert. All rights reserved.
//

import UIKit

class GradientView: UIView {

    override init(frame: CGRect) {
        gradientColors = []
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        gradientColors = []
        super.init(coder: aDecoder)
    }
    
    init(colors: Array<UIColor>) {
        gradientColors = colors
        self.init()
    }

    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }

    var gLayer: CAGradientLayer {
        return layer as! CAGradientLayer;
    }
    
    var gradientColors: Array<UIColor> {
        didSet {
            if self.gradientColors.count == 0 {
                gLayer.colors = nil
                return
            }
            if self.gradientColors.count == 1 {
                gLayer.colors = nil
                self.backgroundColor = gradientColors.first
                return
            }
            self.backgroundColor = UIColor.clear
            gLayer.colors = gradientColors.map {$0.cgColor}
//            gLayer.colors = [UIColor.white.cgColor, UIColor.brown.cgColor]
            let locationStep = 1.0 / Double(gradientColors.count - 1);
            gLayer.locations = Array(0...gradientColors.count).map {NSNumber(value: Double($0) * locationStep)}
//            gLayer.locations = [NSNumber(value: 0), NSNumber(value: 1)]
        }
    }
    
}
