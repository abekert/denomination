//
//  StringExtensions.swift
//  Denomination
//
//  Created by Alexander Bekert on 18/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import Foundation

extension String {
    static let charset = CharacterSet(charactersIn: "1234567890.,-").inverted
    
    func clearNumericString() -> String {
        return self.components(separatedBy:(String.charset)).joined()
    }
    
    func CountOccurrences(ofWhat: String) -> Int {
        let tok = self.components(separatedBy: ofWhat)
        return tok.count - 1
    }
}
