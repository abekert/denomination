//
//  Parser.swift
//  Denomination
//
//  Created by Alexander Bekert on 12/24/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import UIKit

struct ParseResult: CustomStringConvertible {
    let firstArgument: Double
    let secondArgument: Double?
    let operationSign: Character?
    let wantsToRemoveOperation: Bool
    
    let originalFirst: String?
    let originalSecond: String?
    
    init(firstArgument: Double, originalFirst: String? = nil) {
        self.firstArgument = firstArgument
        self.originalFirst = originalFirst
        secondArgument = nil
        originalSecond = nil
        operationSign = nil
        wantsToRemoveOperation = false
    }
    
    init(firstArgument: Double, secondArgument: Double?, operationSign: Character, wantsToRemoveOperation: Bool = false, originalFirst: String? = nil, originalSecond: String? = nil) {
        self.firstArgument = firstArgument
        self.secondArgument = secondArgument
        self.operationSign = operationSign
        self.wantsToRemoveOperation = wantsToRemoveOperation
        self.originalFirst = originalFirst
        self.originalSecond = originalSecond
    }

    
    var description: String {
        return "first: \(firstArgument) '\(String(describing:operationSign))' second: \(String(describing:secondArgument)). wantsToRemoveOperation: \(wantsToRemoveOperation)"
    }
}

// Parser
extension ParseResult {
    init(inputString: String) {
        let operations = CharacterSet(charactersIn:"+–")
        guard let range = inputString.rangeOfCharacter(from:operations) else {
            print("Can't find operation symbol")
            let firstArgument = ParseResult.parseSingleArgument(inputString: inputString)
            self.init(firstArgument: firstArgument, originalFirst: inputString)
            return
        }
        
        let operationSign = inputString[range.lowerBound]
        //        let firstArgument = parseSingleArgument(inputString.substringToIndex(range.startIndex.predecessor()))
        
        let firstArgumentEndIndex = inputString.index(before: range.lowerBound)
        let originalFirst = inputString.substring(to:firstArgumentEndIndex)
        let firstArgument = ParseResult.parseSingleArgument(inputString: originalFirst)
        let distanceToEnd = inputString.distance(from: range.lowerBound, to: inputString.endIndex)
        if distanceToEnd < 3 {
            self.init(firstArgument: firstArgument, secondArgument: nil, operationSign: operationSign, wantsToRemoveOperation: distanceToEnd < 2, originalFirst: originalFirst)
            return
        }
        
        let secondArgumentBeginIndex = inputString.index(after: range.upperBound)
        let originalSecond = inputString.substring(from: secondArgumentBeginIndex)
        let secondArgument = ParseResult.parseSingleArgument(inputString: originalSecond)
        self.init(firstArgument: firstArgument, secondArgument: secondArgument, operationSign: operationSign, wantsToRemoveOperation: false, originalFirst: originalFirst, originalSecond: originalSecond)
    }

    private static func parseSingleArgument(inputString: String) -> Double {
        let formatter = NumberFormatter()
        if let parsed = formatter.number(from:inputString.clearNumericString)?.doubleValue {
            return parsed
        }
        
        return 0
    }
}

// Calculator
extension ParseResult {
    func calculate() -> Double {
        guard let second = secondArgument else {
            return firstArgument
        }
        
        guard let operation = self.operation else {
            return firstArgument
        }
        
        return operation(firstArgument, second)
    }
    
    private var operation: ((Double, Double) -> Double)? {
        guard let sign = operationSign else {
            return nil
        }
        
        if sign == "+" { return {$0 + $1} }
        if sign == "-" || sign == "–" || sign == "—" { return {$0 - $1} }
        if sign == "/" { return {$0 / $1} }
        if sign == "*" { return {$0 * $1} }
        
        return nil
    }
}

// To String
extension ParseResult {
    func formattedString(formatter: NumberFormatter) -> String {
        guard let firstString = originalFirst else {
            return ""
        }
        
        if wantsToRemoveOperation {
            return formatCurrentArgument(string: originalFirst!, parsedValue: firstArgument, formatter: formatter)
        }
        
        guard let operation = operationSign else {
            return formatCurrentArgument(string: originalFirst!, parsedValue: firstArgument, formatter: formatter)
        }
        
        guard let formattedFirst = formatter.string(from: NSNumber(value: firstArgument)) else {
            return "\(firstString) \(operation) "
        }
        
        if let secondString = originalSecond, let sa = secondArgument {
            let formattedSecond = formatCurrentArgument(string: secondString, parsedValue: sa, formatter: formatter)
            return "\(formattedFirst) \(operation) \(formattedSecond)"
        }
        
        return "\(formattedFirst) \(operation) "
    }
    
    private func formatCurrentArgument(string: String, parsedValue: Double, formatter: NumberFormatter) -> String {
        guard let lastSymbol = string.characters.last else {
            return ""
        }
        
        let decimalPartLength = string.decimalPartLength()
        
        if decimalPartLength > formatter.maximumFractionDigits {
            return string.substring(to: string.index(before: string.endIndex))
        }
        
        if lastSymbol == "0" {
            if string.characters.count < 2 {
                return string
            }
            if let separator = formatter.decimalSeparator?.characters.first {
                let preLast = string.characters[string.index(string.endIndex, offsetBy: -2)]
                if preLast == separator || decimalPartLength > 0 {
                    return string
                }
            }
        }
        
        guard let result = formatter.string(from: NSNumber(value: parsedValue)) else {
            return string
        }
        
        if let separator = formatter.decimalSeparator?.characters.first, lastSymbol == separator {
            if decimalPartLength == 0 {
                return "\(result)\(separator)"
            }
        }
        
        return result
    }
}
