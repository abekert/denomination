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
        
        guard let textField = activeTextField, inputText = textField.text else {
            print("Active text field was not set to put operation result")
            return
        }

        let formatter = textField === oldMoneyText ? oldMoneyFormatter : newMoneyFormatter
        
        pendingOperation = nil
        operationResult.title = ""

        let arguments = parseArguments(inputText)
        let first = arguments.firstArgument
        guard let second = arguments.secondArgument else {
            textField.text = formatter.stringFromNumber(first)
            return
        }
        
        let result = operation(first, second)
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
            
            oldMoneyText.text = "\(firstPart) \(sign) "
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
        
        let arguments = parseArguments(text)
        print("Arguments: \(arguments)")

        if  lastSymbol == separator {
            if text.characters.count == 1 {
                newMoneyText.text = "0\(separator)"
                return
            }
            let separatorsCount = text.CountOccurrences("\(separator)")
            let maxAvailableSeparators = arguments.operationSign != nil ? arguments.firstArgument.hasDecimalPart() ? 2 : 1 : 1

            if separatorsCount > maxAvailableSeparators {
                // Extra decimal separator
                newMoneyText.text = text.substringToIndex (text.endIndex.predecessor())
            }
            return
        }
        
        let currentArgument = arguments.secondArgument != nil ? arguments.secondArgument! : arguments.firstArgument
        let decimalPartLength = currentArgument.decimalPartLength()
        print(decimalPartLength)
        if decimalPartLength > newMoneyFormatter.maximumFractionDigits {
            // Extra decimal value
            newMoneyText.text = text.substringToIndex (text.endIndex.predecessor())
            return
        }
        
        if lastSymbol == "0" {
            if text.characters.count < 2 {
                return
            }
            let preLast = text.characters[text.endIndex.advancedBy(-2)]
            if preLast == separator {
                return
            }
            
            if text.characters.count == 2 && preLast == "0" {
                newMoneyText.text = text.substringToIndex (text.endIndex.predecessor())
                return
            }

            if text.characters.count >= 3 {
                let prePreLast = text.characters[text.endIndex.advancedBy(-3)]
                if prePreLast == separator && preLast != "0" {
                    newMoneyText.text = text.substringToIndex (text.endIndex.predecessor())
                    return
                }
            }
        }
        
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
            
            newMoneyText.text = "\(firstPart) \(sign) "
            return
        }

        if lastSymbol != separator {
            newMoneyText.text = firstPart
        }
        oldMoneyText.text = oldMoneyFormatter.stringFromNumber(arguments.firstArgument * 10000)
    }
    
    private func inputIsValid(input: String) -> Bool {
        return true
    }
    
    private func parseArguments(inputString: String) -> (firstArgument: Double, secondArgument: Double?, operationSign: Character?) {
        let operations = NSCharacterSet(charactersInString:"+–")
        guard let range = inputString.rangeOfCharacterFromSet(operations) else {
            print("Can't find operation symbol")
            return (parseSingleArgument(inputString), nil, nil)
        }
        
        let operationSign = inputString[range.startIndex]
        let firstArgument = parseSingleArgument(inputString.substringToIndex(range.startIndex.predecessor()))
        if range.startIndex.distanceTo(inputString.endIndex) < 3 {
            return (firstArgument, nil, operationSign)
        }
        let secondArgument = parseSingleArgument(inputString.substringFromIndex(range.startIndex.successor()))
        return (firstArgument, secondArgument, operationSign)
    }
    
    private func parseSingleArgument(inputString: String) -> Double {
        let formatter = NSNumberFormatter()
        if let parsed = formatter.numberFromString(inputString.clearNumericString())?.doubleValue {
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

extension Double {
    func hasDecimalPart() -> Bool {
        return self % 1 != 0
    }
    
    func decimalPartLength() -> Int {
        let str = String(self)
        if str.characters.last == "0" {
            return 0
        }
        let separators = NSCharacterSet(charactersInString:",.")
        guard let range = str.rangeOfCharacterFromSet(separators) else {
            return 0
        }
        return range.startIndex.distanceTo(str.endIndex) - 1
    }
}
