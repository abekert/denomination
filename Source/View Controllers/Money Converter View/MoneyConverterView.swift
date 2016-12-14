//
//  MoneyConverterView.swift
//  Denomination
//
//  Created by Alexander Bekert on 12/10/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import UIKit

class MoneyConverterView: UIView {
    
    @IBOutlet weak var oldMoneyText: UITextField!
    @IBOutlet weak var newMoneyText: UITextField!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var operationResult: UIBarButtonItem!

    var oldMoneyFormatter = NumberFormatter()
    var newMoneyFormatter = NumberFormatter()
    let maxOldLength = 10
    
    static func configuredView() -> MoneyConverterView? {
        let nibName = String(describing: self)
        guard let views = Bundle.main.loadNibNamed(nibName, owner: self, options: nil), let view = views.first as? MoneyConverterView else {
            return nil
        }
        if let toolbar = views.last as? UIToolbar {
            view.keyboardToolbar = toolbar
            view.operationResult = toolbar.items?.last
        }
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initTextFields()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.size.width, height: 216)
    }
    
    private func initTextFields() {
        operationResult.title = ""
        oldMoneyText.inputAccessoryView = keyboardToolbar
        newMoneyText.inputAccessoryView = keyboardToolbar
        
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            oldMoneyText.inputView = LNNumberpad.default()
            newMoneyText.inputView = LNNumberpad.default()
        }
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
        
        activeTextField?.text?.append(" + ")
        
        pendingOperation = {$0 + $1}
    }
    
    @IBAction func substractButtonPressed() {
        //change keyboard type to default
        print("Minus")
        
        if pendingOperation != nil {
            finishComplicatedOperation()
        }
        
        activeTextField?.text?.append(" – ")
        
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
        
        guard let textField = activeTextField, let inputText = textField.text else {
            print("Active text field was not set to put operation result")
            return
        }
        
        let formatter = textField === oldMoneyText ? oldMoneyFormatter : newMoneyFormatter
        
        pendingOperation = nil
        operationResult.title = ""
        
        let arguments = parseArguments(inputString: inputText)
        let first = arguments.firstArgument
        guard let second = arguments.secondArgument else {
            textField.text = formatter.string(from: NSNumber(value: first))
            return
        }
        
        let result = operation(first, second)
        textField.text = formatter.string(from: NSNumber(value: result))
    }
    

    // MARK: - Text Fields
    
    @IBAction func didBeganEditing(sender: UITextField) {
        activeTextField = sender
        let s = sender === oldMoneyText ? "old" : "new"
        print("didBeganEditing \(s)")
    }
    
    @IBAction func didFinishEditing(sender: UITextField) {
        let s = sender === oldMoneyText ? "old" : "new"
        print("didFinishEditing \(s)")
        
        if pendingOperation != nil {
            finishComplicatedOperation()
        }
        activeTextField = nil
    }
    
    @IBAction func oldMoneyChanged(sender: UITextField) {
        guard let text = sender.text else {
            self.newMoneyText.text = "0"
            return
        }
        
        let arguments = parseArguments(inputString: text)
        print("Arguments: \(arguments)")
        
        operationResult.title = ""
        guard let firstPart = oldMoneyFormatter.string(from: NSNumber(value: arguments.firstArgument)) else {
            print("Can't print first argument")
            return
        }
        
        if let operation = pendingOperation, let sign = arguments.operationSign {
            if arguments.wantsToRemoveOperation {
                finishComplicatedOperation()
                return
            }
            if let secondArgument = arguments.secondArgument {
                let result = operation(arguments.firstArgument, secondArgument)
                operationResult.title = "= \(oldMoneyFormatter.string(from: NSNumber(value: result)))"
                
                guard let secondPart = oldMoneyFormatter.string(from: NSNumber(value: secondArgument)) else {
                    print("Can't print second argument")
                    return
                }
                oldMoneyText.text = "\(firstPart) \(sign) \(secondPart)"
                newMoneyText.text = newMoneyFormatter.string(from: NSNumber(value: result / 10000.0))
                return
            }
            
            oldMoneyText.text = "\(firstPart) \(sign) "
            return
        }
        
        oldMoneyText.text = firstPart
        newMoneyText.text = newMoneyFormatter.string(from: NSNumber(value: arguments.firstArgument / 10000.0))
    }
    
    @IBAction func newMoneyChanged(sender: UITextField) {
        guard let text = sender.text, let separator = newMoneyFormatter.decimalSeparator?.characters.first, let lastSymbol = text.characters.last else {
            self.oldMoneyText.text = "0"
            return
        }
        
        let arguments = parseArguments(inputString: text)
        print("Arguments: \(arguments)")
        
        if lastSymbol == separator {
            if text.characters.count == 1 {
                newMoneyText.text = "0\(separator)"
                return
            }
            let separatorsCount = text.countOccurrences(of: "\(separator)")
            let maxAvailableSeparators = arguments.operationSign != nil ? arguments.firstArgument.hasDecimalPart() ? 2 : 1 : 1
            
            if separatorsCount > maxAvailableSeparators {
                // Extra decimal separator
                newMoneyText.text = text.substring(to: text.index(before: text.endIndex))
                return
            }
            
            updateOldMoneyTextFromNewArguments(arguments: arguments)
            return
        }
        
        let currentArgument = arguments.secondArgument != nil ? arguments.secondArgument! : arguments.firstArgument
        let decimalPartLength = currentArgument.decimalPartLength()
        
        if decimalPartLength > newMoneyFormatter.maximumFractionDigits {
            // Extra decimal value
            newMoneyText.text = text.substring(to: text.index(before: text.endIndex))
            return
        }
        
        if lastSymbol == "0" {
            if text.characters.count < 2 {
                return
            }
            
            let preLast = text.characters[text.index(text.endIndex, offsetBy: -2)]
            if preLast == separator {
                updateOldMoneyTextFromNewArguments(arguments: arguments)
                return
            }
            
            if text.characters.count == 2 && preLast == "0" {
                newMoneyText.text = text.substring(to: text.index(before: text.endIndex))
                updateOldMoneyTextFromNewArguments(arguments: arguments)
                return
            }
            
            if text.characters.count >= 3 {
                let prePreLast = text.characters[text.index(text.endIndex, offsetBy: -3)]
                if prePreLast == separator && preLast != "0" {
                    newMoneyText.text = text.substring(to: text.index(before: text.endIndex))
                    updateOldMoneyTextFromNewArguments(arguments: arguments)
                    return
                }
            }
        }
        
        operationResult.title = ""
        guard let firstPart = newMoneyFormatter.string(from: NSNumber(value: arguments.firstArgument)) else {
            print("Can't print first argument")
            return
        }
        
        if let operation = pendingOperation, let sign = arguments.operationSign {
            if arguments.wantsToRemoveOperation {
                finishComplicatedOperation()
                return
            }
            if let secondArgument = arguments.secondArgument {
                let result = operation(arguments.firstArgument, secondArgument)
                operationResult.title = "= \(newMoneyFormatter.string(from: NSNumber(value:  result))!)"
                
                guard let secondPart = newMoneyFormatter.string(from: NSNumber(value: secondArgument)) else {
                    print("Can't print second argument")
                    return
                }
                newMoneyText.text = "\(firstPart) \(sign) \(secondPart)"
                oldMoneyText.text = oldMoneyFormatter.string(from: NSNumber(value: result * 10000.0))
                return
            }
            
            newMoneyText.text = "\(firstPart) \(sign) "
            return
        }
        
        if lastSymbol != separator {
            newMoneyText.text = firstPart
        }
        oldMoneyText.text = oldMoneyFormatter.string(from: NSNumber(value: arguments.firstArgument * 10000))
    }
    
    private func updateOldMoneyTextFromNewArguments(arguments: ParseResult) {
        if let operation = pendingOperation, let secondArgument = arguments.secondArgument {
            let result = operation(arguments.firstArgument, secondArgument)
            operationResult.title = "= \(newMoneyFormatter.string(from: NSNumber(value: result)))"
            oldMoneyText.text = oldMoneyFormatter.string(from: NSNumber(value: result * 10000.0))
            return
        }
        oldMoneyText.text = oldMoneyFormatter.string(from: NSNumber(value: arguments.firstArgument * 10000))
    }
    
    class ParseResult: CustomStringConvertible {
        let firstArgument: Double
        let secondArgument: Double?
        let operationSign: Character?
        let wantsToRemoveOperation: Bool
        
        init(firstArgument: Double) {
            self.firstArgument = firstArgument
            secondArgument = nil
            operationSign = nil
            wantsToRemoveOperation = false
        }
        
        init(firstArgument: Double, secondArgument: Double?, operationSign: Character, wantsToRemoveOperation: Bool = false) {
            self.firstArgument = firstArgument
            self.secondArgument = secondArgument
            self.operationSign = operationSign
            self.wantsToRemoveOperation = wantsToRemoveOperation
        }
        
        var description: String {
            return "first: \(firstArgument) '\(operationSign)' second: \(secondArgument). wantsToRemoveOperation: \(wantsToRemoveOperation)"
        }
    }
    
    private func parseArguments(inputString: String) -> ParseResult {
        let operations = CharacterSet(charactersIn:"+–")
        guard let range = inputString.rangeOfCharacter(from:operations) else {
            print("Can't find operation symbol")
            return ParseResult(firstArgument:parseSingleArgument(inputString: inputString))
        }
        
        let operationSign = inputString[range.lowerBound]
        //        let firstArgument = parseSingleArgument(inputString.substringToIndex(range.startIndex.predecessor()))
        
        let firstArgumentEndIndex = inputString.index(before: range.lowerBound)
        let firstArgument = parseSingleArgument(inputString: inputString.substring(to:firstArgumentEndIndex))
        let distanceToEnd = inputString.distance(from: range.lowerBound, to: inputString.endIndex)
        if distanceToEnd < 3 {
            return ParseResult(firstArgument: firstArgument, secondArgument: nil, operationSign: operationSign, wantsToRemoveOperation: distanceToEnd < 2)
        }
        
        let secondArgumentBeginIndex = inputString.index(after: range.lowerBound)
        let secondArgument = parseSingleArgument(inputString: inputString.substring(from: secondArgumentBeginIndex))
        return ParseResult(firstArgument: firstArgument, secondArgument: secondArgument, operationSign: operationSign, wantsToRemoveOperation: false)
    }
    
    private func parseSingleArgument(inputString: String) -> Double {
        let formatter = NumberFormatter()
        if let parsed = formatter.number(from:inputString.clearNumericString)?.doubleValue {
            return parsed
        }
        
        return 0
    }
    

    
}
