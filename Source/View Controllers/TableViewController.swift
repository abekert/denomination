//
//  TableViewController.swift
//  Denomination
//
//  Created by Alexander Bekert on 17/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    @IBInspectable
    var topGradientColor: UIColor = UIColor.white
    @IBInspectable
    var bottomGradientColor: UIColor = UIColor.white
    
    @IBOutlet weak var usdCell: CurrencyCell!
    @IBOutlet weak var eurCell: CurrencyCell!
    @IBOutlet weak var rubCell: CurrencyCell!
    
    let firstCell = UITableViewCell()
    
    let oldMoneyFormatter = NumberFormatter()
    let newMoneyFormatter = NumberFormatter()
    let maxOldLength = 10

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        initMoneyFormatters()
        setTableViewBackgroundGradient(sender: self, topColor: topGradientColor, bottomColor: bottomGradientColor)
        initCurrenciesCells()
    }

    private func initMoneyFormatters() {
        oldMoneyFormatter.currencyCode = "BYR"
        oldMoneyFormatter.maximumFractionDigits = 0
        oldMoneyFormatter.minimumIntegerDigits = 1
        oldMoneyFormatter.usesGroupingSeparator = true
        oldMoneyFormatter.groupingSeparator = "\u{2008}"
        oldMoneyFormatter.groupingSize = 3
        
        newMoneyFormatter.currencyCode = "BYN"
        newMoneyFormatter.maximumFractionDigits = 2
        newMoneyFormatter.minimumIntegerDigits = 1
        newMoneyFormatter.usesGroupingSeparator = true
        newMoneyFormatter.groupingSeparator = "\u{2008}"
        newMoneyFormatter.groupingSize = 3
    }
    
    var gradientLayer: CAGradientLayer!
    func setTableViewBackgroundGradient(sender: UITableViewController, topColor: UIColor, bottomColor: UIColor) {
        let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations = [NSNumber(value: 0), NSNumber(value: 1.0)]
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = gradientLocations
        
        gradientLayer.frame = sender.tableView.bounds
        let backgroundView = UIView(frame: sender.tableView.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        sender.tableView.backgroundView = backgroundView
    }
    
    func initCurrenciesCells() {
        if usdCell != nil {
            usdCell.oldMoneyFormatter = oldMoneyFormatter
            let newFormatter = NumberFormatter ()
            newFormatter.minimumIntegerDigits = 1
            newFormatter.maximumFractionDigits = 4
            newFormatter.usesGroupingSeparator = true
            newFormatter.groupingSeparator = "\u{2008}"
            usdCell.newMoneyFormatter = newFormatter
        }
        
        if eurCell != nil {
            eurCell.oldMoneyFormatter = oldMoneyFormatter
            let newFormatter = NumberFormatter ()
            newFormatter.minimumIntegerDigits = 1
            newFormatter.maximumFractionDigits = 4
            newFormatter.usesGroupingSeparator = true
            newFormatter.groupingSeparator = "\u{2008}"
            eurCell.newMoneyFormatter = newFormatter
        }
        
        if rubCell != nil {
            let oldFormatter = NumberFormatter ()
            oldFormatter.minimumIntegerDigits = 1
            oldFormatter.maximumFractionDigits = 2
            oldFormatter.usesGroupingSeparator = true
            oldFormatter.groupingSeparator = "\u{2008}"
            rubCell.oldMoneyFormatter = oldFormatter
            
            let newFormatter = NumberFormatter ()
            newFormatter.minimumIntegerDigits = 1
            newFormatter.maximumFractionDigits = 6
            newFormatter.usesGroupingSeparator = true
            newFormatter.groupingSeparator = "\u{2008}"
            rubCell.newMoneyFormatter = newFormatter
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getCurrencies()
    }

    func getCurrencies() {
        if usdCell != nil {
            getUpdatesForCurrency(currency: .USD, cell: usdCell)
        }
        if eurCell != nil {
            getUpdatesForCurrency(currency: .EUR, cell: eurCell)
        }
        if rubCell != nil {
            getUpdatesForCurrency(currency: .RUB, cell: rubCell)
        }
    }
    
    func getUpdatesForCurrency(currency: Currencies, cell: CurrencyCell) {
        CurrenciesUpdater.getLastMonthCurrenciesRates(currency: currency) { (result) in
            switch result {
            case .Success(let rates):
                
                DispatchQueue.main.sync {
                    self.updateCurrencyCell(cell: cell, rates: rates)
                }

//            case let .Error(message):
//                self.presentError(message)
            default:
                break
            }
        }
    }
    
    func updateCurrencyCell(cell: CurrencyCell, rates: RatesHistory) {
        cell.currencyDescription.text = rates.currency.description
        guard let rate = rates.latestRate else {
            return
        }
//        cell.newMoneyFormatter = newMoneyFormatter
//        cell.oldMoneyFormatter = oldMoneyFormatter
        cell.setRatesNew(newRate: rate.rate, newGrowth: rate.growth)
    }
    
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Курсы валют НБРБ за " + Date().shortShortDescription
        }
        
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if firstCell.contentView.subviews.count == 0 {
                guard let moneyConverterView = MoneyConverterView.configuredView() else {
                    return firstCell
                }
                moneyConverterView.oldMoneyFormatter = oldMoneyFormatter
                moneyConverterView.newMoneyFormatter = newMoneyFormatter
                firstCell.contentView.addSubview(moneyConverterView)
                moneyConverterView.frame = firstCell.bounds
            }
            return firstCell
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        if let layer = gradientLayer {
//            print("layer frame")
//            layer.frame = tableView.bounds
//        }
//    }
    
}
