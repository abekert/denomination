//
//  CurrencyCell.swift
//  Denomination
//
//  Created by Alexander Bekert on 18/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var currencyDescription: UILabel!
    
    @IBOutlet weak var newRate: UILabel!
    @IBOutlet weak var newGrowth: UILabel!
    @IBOutlet weak var newGrowthIcon: UIImageView!

    @IBOutlet weak var oldRate: UILabel!
    @IBOutlet weak var oldGrowth: UILabel!
    @IBOutlet weak var oldGrowthIcon: UIImageView!
    
    var oldMoneyFormatter: NSNumberFormatter?
    var newMoneyFormatter: NSNumberFormatter?
    
    func setRatesOld(oldRate: Double, oldGrowth: Double) {
        if let formatter = oldMoneyFormatter {
            self.oldRate.text = formatter.stringFromNumber(oldRate)
            self.oldGrowth.text = formatter.stringFromNumber(oldGrowth)
        } else {
            self.oldRate.text = oldRate.description
            self.oldGrowth.text = oldGrowth.description
        }
        
        if let formatter = newMoneyFormatter {
            self.newRate.text = formatter.stringFromNumber(oldRate / 10000.0)
            self.newGrowth.text = formatter.stringFromNumber(oldGrowth / 10000.0)
        } else {
            self.newRate.text = String(oldRate / 10000.0)
            self.newGrowth.text = String(oldGrowth / 10000.0)
        }
    }
}

