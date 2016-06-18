//
//  TableViewController.swift
//  Denomination
//
//  Created by Alexander Bekert on 17/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    @IBOutlet weak var oldMoneyText: UITextField!
    @IBOutlet weak var newMoneyText: UITextField!
    
    @IBInspectable
    var topGradientColor: UIColor = UIColor.whiteColor()
    @IBInspectable
    var bottomGradientColor: UIColor = UIColor.whiteColor()
    
    let oldMoneyFormatter = NSNumberFormatter()
    let newMoneyFormatter = NSNumberFormatter()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        initMoneyFormatters()
        setTableViewBackgroundGradient(self, topGradientColor, bottomGradientColor)
    }

    func initMoneyFormatters() {
        oldMoneyFormatter.currencyCode = "BYR"
        oldMoneyFormatter.maximumFractionDigits = 0
        oldMoneyFormatter.minimumIntegerDigits = 1
        oldMoneyFormatter.usesGroupingSeparator = true
        oldMoneyFormatter.groupingSeparator = "\u{2008}"
        
        newMoneyFormatter.currencyCode = "BYN"
        newMoneyFormatter.maximumFractionDigits = 2
        newMoneyFormatter.minimumIntegerDigits = 1
        newMoneyFormatter.usesGroupingSeparator = true
        newMoneyFormatter.groupingSeparator = "\u{2008}"
    }
    
    var gradientLayer: CAGradientLayer!
    func setTableViewBackgroundGradient(sender: UITableViewController, _ topColor:UIColor, _ bottomColor:UIColor) {
        let gradientBackgroundColors = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations = [0.0,1.0]
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = gradientLocations
        
        gradientLayer.frame = sender.tableView.bounds
        let backgroundView = UIView(frame: sender.tableView.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
        sender.tableView.backgroundView = backgroundView
    }

    // MARK: - Actions
    
    @IBAction func oldMoneyChanged(sender: UITextField) {
        guard let text = sender.text else {
            self.newMoneyText.text = "0"
            return
        }
        
        let clearText = text.clearNumericString()

        if let value = oldMoneyFormatter.numberFromString(clearText)?.integerValue {
            oldMoneyText.text = oldMoneyFormatter.stringFromNumber(value)
            newMoneyText.text = newMoneyFormatter.stringFromNumber(Double(value) / 10000.0)
        }
    }
    
    @IBAction func newMoneyChanged(sender: UITextField) {
        guard let text = sender.text, separator = newMoneyFormatter.decimalSeparator?.characters.first, lastSymbol = text.characters.last else {
            self.oldMoneyText.text = "0"
            return
        }

        if  lastSymbol == separator && text.CountOccurrences("\(separator)") > 1 {
            // Second decimal separator
            newMoneyText.text = text.substringToIndex (text.endIndex.predecessor())
            return
        }

        let clearText = text.clearNumericString()
        
        if let value = newMoneyFormatter.numberFromString(clearText)?.doubleValue {
            oldMoneyText.text = oldMoneyFormatter.stringFromNumber(value * 10000)
            if lastSymbol != separator {
                newMoneyText.text = newMoneyFormatter.stringFromNumber(value)
            }
        }
    }
    
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Курсы валют за " + NSDate().description
        }
        
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    

//    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.backgroundColor = UIColor.clearColor()
//    }
    
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        if let layer = gradientLayer {
//            print("layer frame")
//            layer.frame = tableView.bounds
//        }
//    }
    
}
