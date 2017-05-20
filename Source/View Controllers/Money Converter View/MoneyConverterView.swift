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
    
    @IBAction func addButtonPressed() {
        //change keyboard type to number
        print("Add")
        
        finishComplicatedOperation()
        activeTextField?.text?.append(" + ")
    }
    
    @IBAction func substractButtonPressed() {
        //change keyboard type to default
        print("Minus")
        
        finishComplicatedOperation()
        activeTextField?.text?.append(" – ")
    }
    
    @IBAction func equalsButtonPressed() {
        //change keyboard type to default
        print("Equals")
        finishComplicatedOperation()
    }
    
    private func finishComplicatedOperation() {
        guard let textField = activeTextField, let inputText = textField.text else {
            print("Active text field was not set to put operation result")
            return
        }
        
        let formatter = textField === oldMoneyText ? oldMoneyFormatter : newMoneyFormatter
        
        operationResult.title = ""
        
        let arguments = ParseResult(inputString: inputText)
        let result = arguments.calculate()
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
        
        finishComplicatedOperation()
        activeTextField = nil
    }
    
    @IBAction func oldMoneyChanged(sender: UITextField) {
        guard let text = sender.text else {
            self.newMoneyText.text = "0"
            return
        }
        
        let firstParse = ParseResult(inputString: text)
        let finalText = firstParse.formattedString(formatter: oldMoneyFormatter)
        let finalParse = ParseResult(inputString: finalText)
        print("Arguments: \(finalParse)")
        
        self.oldMoneyText.text = finalText;

        let result = finalParse.calculate()
        setNewMoney(value: result / 10000.0)
        if finalParse.hasOperation, let resultString = oldMoneyFormatter.string(from: NSNumber(value: result)) {
            operationResult.title = "= \(resultString)"
        } else {
            operationResult.title = nil
        }
    }
    
    @IBAction func newMoneyChanged(sender: UITextField) {
        guard let text = sender.text else {
            self.oldMoneyText.text = "0"
            return
        }

        let firstParse = ParseResult(inputString: text)
        let finalText = firstParse.formattedString(formatter: newMoneyFormatter)
        let finalParse = ParseResult(inputString: finalText)
        print("Arguments: \(finalParse)")
        
        self.newMoneyText.text = finalText;

        let result = finalParse.calculate()
        setOldMoney(value: result * 10000)
        if finalParse.hasOperation, let resultString = newMoneyFormatter.string(from: NSNumber(value: result)) {
            operationResult.title = "= \(resultString)"
        } else {
            operationResult.title = nil
        }
    }
    
    @discardableResult
    private func setOldMoney(value: Double) -> Bool {
        if let stringValue = oldMoneyFormatter.string(from: NSNumber(value: value)) {
            oldMoneyText.text = stringValue
            return true
        }
        return false
    }
    
    @discardableResult
    private func setNewMoney(value: Double) -> Bool {
        if let stringValue = newMoneyFormatter.string(from: NSNumber(value: value)) {
            newMoneyText.text = stringValue
            return true
        }
        return false
    }
}
