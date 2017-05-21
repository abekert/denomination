//
//  CurrencyCell.swift
//  Denomination
//
//  Created by Alexander Bekert on 18/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import UIKit

extension UIColor {
    /// Init with color #. Example: 0x949494
    convenience init(rgbValue: UInt) {
        self.init(red: (CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0),
                  green: (CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0),
                  blue: (CGFloat(rgbValue & 0x0000FF) / 255.0),
                  alpha: (CGFloat(1.0))
        )
    }
}

class CurrencyCell: UITableViewCell {
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var currencyDescription: UILabel!
    
    @IBOutlet weak var newRate: UILabel!
    @IBOutlet weak var newGrowth: UILabel!
//    @IBOutlet weak var newGrowthIcon: UIImageView!

    @IBOutlet weak var oldRate: UILabel!
    @IBOutlet weak var oldGrowth: UILabel!
//    @IBOutlet weak var oldGrowthIcon: UIImageView!
    
//    static private let growthImageName = "arrow-up"
//    static private let growthImage: UIImage? = UIImage(named: growthImageName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    
    static private let greenColor = UIColor(rgbValue: 0x66ff99)
    static private let redColor = UIColor(rgbValue: 0xffcc99)
    
    static private let upArrow = "\u{2191}"
    static private let downArrow = "\u{2193}"
    
    var oldMoneyFormatter: NumberFormatter?
    var newMoneyFormatter: NumberFormatter?
    
    func setRatesOld(oldRate: Double, oldGrowth: Double) {
        setRates(rateLabel: self.oldRate, rate: oldRate, growthLabel: self.oldGrowth, growth: oldGrowth, numberFormatter: oldMoneyFormatter)
        setRates(rateLabel: newRate, rate: oldRate / 10000.0, growthLabel: newGrowth, growth: oldGrowth / 10000.0, numberFormatter: newMoneyFormatter)
    }
    
    func setRatesNew(newRate: Double, newGrowth: Double) {
        setRates(rateLabel: self.oldRate, rate: newRate * 10000, growthLabel: self.oldGrowth, growth: newGrowth * 10000, numberFormatter: oldMoneyFormatter)
        setRates(rateLabel: self.newRate, rate: newRate, growthLabel: self.newGrowth, growth: newGrowth, numberFormatter: newMoneyFormatter)
    }

    
    private func setRates(rateLabel: UILabel, rate: Double, growthLabel: UILabel, growth: Double, numberFormatter: NumberFormatter?) {
        if let formatter = numberFormatter {
            rateLabel.text = formatter.string(from: NSNumber(value: rate))
        } else {
            rateLabel.text = rate.description
            growthLabel.text = growth.description
        }
        
        setupGrowthLabelStyle(label: growthLabel, value: growth, numberFormatter: numberFormatter)
        
//        if growthIcon != nil {
//            setupGrowthIconStyle(growthIcon, value: growth)
//        }

    }
    
    private func setupGrowthLabelStyle (label: UILabel, value: Double, numberFormatter: NumberFormatter?) {
        if value == 0 {
            label.isHidden = true
            return
        }
        label.isHidden = false

        let arrow: String
        if value > 0 {
            label.textColor = CurrencyCell.greenColor
            arrow = CurrencyCell.upArrow
        } else {
            label.textColor = CurrencyCell.redColor
            arrow = CurrencyCell.downArrow
        }

        let absValue = abs(value)
        if let formatter = numberFormatter {
            label.text = formatter.string(from: NSNumber(value: absValue))
        } else {
            label.text = absValue.description
        }
        
        label.text = "\(arrow)\(label.text!)"
    }
    
//    private func setupGrowthIconStyle(icon: UIImageView, value: Double) {
//        guard let image = CurrencyCell.growthImage else {
//            icon.hidden = true
//            return
//        }
//        
//        if value == 0 {
//            icon.hidden = true
//            return
//        }
//        icon.hidden = false
//
//        icon.image = image
//
//        if value > 0 {
//            icon.tintColor = CurrencyCell.greenColor
//        } else {
//            icon.transform = CGAffineTransformMakeRotation(CGFloat(M_PI));
//            icon.tintColor = CurrencyCell.redColor
//        }
//    }
}

