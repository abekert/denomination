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
    
    func setRatesOld(oldRate: Double, oldGrowth: Double) {
        self.oldRate.text = oldMoneyFormatter.stringFromNumber(oldRate)
        self.oldGrowth.text = oldMoneyFormatter.stringFromNumber(oldGrowth)
        
        self.newRate.text = newMoneyFormatter.stringFromNumber(oldRate / 10000.0)
        self.newGrowth.text = newMoneyFormatter.stringFromNumber(oldGrowth / 10000.0)
    }
}

