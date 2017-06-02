//
//  TableViewController.swift
//  Denomination
//
//  Created by Alexander Bekert on 17/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet weak var usdCell: CurrencyCell!
    @IBOutlet weak var eurCell: CurrencyCell!
    @IBOutlet weak var rubCell: CurrencyCell!
    
    let firstCell = UITableViewCell()
    
    let oldMoneyFormatter = NumberFormatter()
    let newMoneyFormatter = NumberFormatter()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        initMoneyFormatters()
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
            rubCell.oldMoneyFormatter = oldMoneyFormatter
            
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
                firstCell.selectionStyle = .none
                moneyConverterView.oldMoneyFormatter = oldMoneyFormatter
                moneyConverterView.newMoneyFormatter = newMoneyFormatter
                firstCell.contentView.addSubview(moneyConverterView)
                moneyConverterView.frame = firstCell.bounds
            }
            return firstCell
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
}
