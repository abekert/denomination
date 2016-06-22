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
    var topGradientColor: UIColor = UIColor.whiteColor()
    @IBInspectable
    var bottomGradientColor: UIColor = UIColor.whiteColor()

    @IBOutlet weak var oldMoneyText: UITextField!
    @IBOutlet weak var newMoneyText: UITextField!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var operationResult: UIBarButtonItem!
    
    @IBOutlet weak var usdCell: CurrencyCell!
    @IBOutlet weak var eurCell: CurrencyCell!
    @IBOutlet weak var rubCell: CurrencyCell!
    
    let oldMoneyFormatter = NSNumberFormatter()
    let newMoneyFormatter = NSNumberFormatter()
    let maxOldLength = 10

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        initMoneyFormatters()
        setTableViewBackgroundGradient(self, topGradientColor, bottomGradientColor)
        initCurrenciesCells ()
        
        oldMoneyText.inputAccessoryView = keyboardToolbar
        newMoneyText.inputAccessoryView = keyboardToolbar
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
    
    func initCurrenciesCells() {
        if usdCell != nil {
            usdCell.oldMoneyFormatter = oldMoneyFormatter
        }
        
        if eurCell != nil {
            eurCell.oldMoneyFormatter = oldMoneyFormatter
        }
        
        if rubCell != nil {
            let oldFormatter = NSNumberFormatter ()
            oldFormatter.minimumIntegerDigits = 1
            oldFormatter.maximumFractionDigits = 2
            oldFormatter.usesGroupingSeparator = true
            oldFormatter.groupingSeparator = "\u{2008}"
            rubCell.oldMoneyFormatter = oldFormatter
            
            let newFormatter = NSNumberFormatter ()
            newFormatter.minimumIntegerDigits = 1
            newFormatter.maximumFractionDigits = 6
            newFormatter.usesGroupingSeparator = true
            newFormatter.groupingSeparator = "\u{2008}"
            rubCell.newMoneyFormatter = newFormatter
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getCurrencies()
    }

    func getCurrencies() {
        if usdCell != nil {
            getUpdatesForCurrency(.USD, cell: usdCell)
        }
        if eurCell != nil {
            getUpdatesForCurrency(.EUR, cell: eurCell)
        }
        if rubCell != nil {
            getUpdatesForCurrency(.RUB, cell: rubCell)
        }
    }
    
    func getUpdatesForCurrency(currency: Currencies, cell: CurrencyCell) {
        CurrenciesUpdater.getLastMonthCurrenciesRates(currency) { (result) in
            switch result {
            case .Success(let rates):
                self.updateCurrencyCell(cell, rates: rates)
                
            case let .Error(message):
                self.presentError(message)
            }
        }
    }
    
    func updateCurrencyCell(cell: CurrencyCell, rates: RatesHistory) {
        cell.currencyDescription.text = rates.currency.description
        guard let rate = rates.latestRate else {
            return
        }
        cell.setRatesOld(rate.rate, oldGrowth: rate.growth)
    }
    
    // MARK: - Keyboard
    
    var activeTextField: UITextField? = nil
    var pendingOperation: ((Double, Double) -> Double)? = nil
    
    @IBAction func addButtonPressed() {
        //change keyboard type to number
        print("Add")
        
        if pendingOperation != nil {
            finishComplicatedOperation()
        }

        activeTextField?.text?.appendContentsOf(" + ")
        
        pendingOperation = {$0 + $1}
    }
    
    @IBAction func substractButtonPressed() {
        //change keyboard type to default
        print("Minus")
        
        if pendingOperation != nil {
            finishComplicatedOperation()
        }
        
        activeTextField?.text?.appendContentsOf(" – ")
        
        pendingOperation = {$0 - $1}
    }
    
    @IBAction func equalsButtonPressed() {
        //change keyboard type to default
        print("Equals")
        if pendingOperation != nil {
            finishComplicatedOperation()
        }
    }
    
    private func finishComplicatedOperation() {
        guard let operation = pendingOperation else {
            print("Pending operation was not assigned")
            return
        }
        
        guard let inputText = activeTextField?.text else {
            print("Can't parse arguments")
            return
        }
        
        let arguments = parseArguments(inputText)
        let first = arguments.firstArgument
        guard let second = arguments.secondArgument else {
            return
        }
        
        let result = operation(first, second)
        pendingOperation = nil
        operationResult.title = ""
        
        guard let textField = activeTextField else {
            print("Active text field was not set to put operation result")
            return
        }
        let formatter = textField === oldMoneyText ? oldMoneyFormatter : newMoneyFormatter
        textField.text = formatter.stringFromNumber(result)
    }

    // MARK: - Text Fields
    
    @IBAction func didBeganEditing(sender: UITextField) {
        activeTextField = sender
        let s = sender === oldMoneyText ? "old" : "new"
        print("didBeganEditing \(s)")
    }
    
    @IBAction func didFinishEditing(sender: UITextField) {
        activeTextField = nil
        let s = sender === oldMoneyText ? "old" : "new"
        print("didFinishEditing \(s)")
        
        if pendingOperation != nil {
            finishComplicatedOperation()
        }
    }
    
    @IBAction func oldMoneyChanged(sender: UITextField) {
        guard let text = sender.text else {
            self.newMoneyText.text = "0"
            return
        }
        
        let arguments = parseArguments(text)
        print("Arguments: \(arguments)")
        
        operationResult.title = ""
        guard let firstPart = oldMoneyFormatter.stringFromNumber(arguments.firstArgument) else {
            print("Can't print first argument")
            return
        }

        if let operation = pendingOperation, sign = arguments.operationSign {
            if let secondArgument = arguments.secondArgument {
                let result = operation(arguments.firstArgument, secondArgument)
                operationResult.title = "= \(oldMoneyFormatter.stringFromNumber(result)!)"
                
                guard let secondPart = oldMoneyFormatter.stringFromNumber(secondArgument) else {
                    print("Can't print second argument")
                    return
                }
                oldMoneyText.text = "\(firstPart) \(sign) \(secondPart)"
                newMoneyText.text = newMoneyFormatter.stringFromNumber(result / 10000.0)
                return
            }
            
            oldMoneyText.text = "\(firstPart) \(sign)"
            return
        }

        oldMoneyText.text = firstPart
        newMoneyText.text = newMoneyFormatter.stringFromNumber(arguments.firstArgument / 10000.0)
    }
    
    @IBAction func newMoneyChanged(sender: UITextField) {
        guard let text = sender.text, separator = newMoneyFormatter.decimalSeparator?.characters.first, lastSymbol = text.characters.last else {
            self.oldMoneyText.text = "0"
            return
        }
        
        let separatorsCount = text.CountOccurrences("\(separator)")
        let maxAvailableSeparators = pendingOperation != nil ? 2 : 1
        if  lastSymbol == separator {
            if separatorsCount > maxAvailableSeparators {
                // Second decimal separator
                newMoneyText.text = text.substringToIndex (text.endIndex.predecessor())
            }
            return
        }
        
        let arguments = parseArguments(text)
        print("Arguments: \(arguments)")
        
        operationResult.title = ""
        guard let firstPart = newMoneyFormatter.stringFromNumber(arguments.firstArgument) else {
            print("Can't print first argument")
            return
        }
        
        if let operation = pendingOperation, sign = arguments.operationSign {
            if let secondArgument = arguments.secondArgument {
                let result = operation(arguments.firstArgument, secondArgument)
                operationResult.title = "= \(newMoneyFormatter.stringFromNumber(result)!)"
                
                guard let secondPart = newMoneyFormatter.stringFromNumber(secondArgument) else {
                    print("Can't print second argument")
                    return
                }
                newMoneyText.text = "\(firstPart) \(sign) \(secondPart)"
                oldMoneyText.text = oldMoneyFormatter.stringFromNumber(result * 10000.0)
                return
            }
            
            newMoneyText.text = "\(firstPart) \(sign)"
            return
        }

        if lastSymbol != separator {
            newMoneyText.text = firstPart
        }
        oldMoneyText.text = oldMoneyFormatter.stringFromNumber(arguments.firstArgument * 10000)
    }
    
    private func parseArguments(inputString: String) -> (firstArgument: Double, secondArgument: Double?, operationSign: Character?) {
        let operations = NSCharacterSet(charactersInString:"+–")
        guard let range = inputString.rangeOfCharacterFromSet(operations) else {
            print("Can't find operation symbol")
            return (parseSingleArgument(inputString), nil, nil)
        }
        
        let operationSign = inputString[range.startIndex]
        let firstArgument = parseSingleArgument(inputString.substringToIndex(range.startIndex.predecessor()))
        if range.startIndex.distanceTo(inputString.endIndex) < 2 {
            return (firstArgument, nil, operationSign)
        }
        let secondArgument = parseSingleArgument(inputString.substringFromIndex(range.startIndex.successor()))
        return (firstArgument, secondArgument, operationSign)
    }
    
    private func parseSingleArgument(inputString: String) -> Double {
        if let parsed = Double(inputString.clearNumericString()) {
            return parsed
        }
        return 0
    }

    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Курсы валют за " + NSDate().shortShortDescription
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
