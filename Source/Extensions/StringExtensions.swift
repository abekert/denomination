//
//  StringExtensions.swift
//  Denomination
//
//  Created by Alexander Bekert on 18/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import Foundation

extension String {
    static let charset = NSCharacterSet(charactersInString: "1234567890.,-").invertedSet
    
    func clearNumericString() -> String {
        return self.componentsSeparatedByCharactersInSet(String.charset).joinWithSeparator("")
    }
    
    func CountOccurrences(ofWhat: String) -> Int {
        let tok = self.componentsSeparatedByString(ofWhat)
        return tok.count - 1
    }
}
