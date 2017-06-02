extension Double {
    func hasDecimalPart() -> Bool {
        return self.truncatingRemainder(dividingBy:1) != 0
    }
    
    func decimalPartLength() -> Int {
        let str = String(self)
        if str.characters.last == "0" {
            return 0
        }
        
        return str.decimalPartLength()
    }
    
    func floor(to places: UInt) -> Double {
        let divisor = Double(10.pow(power: places))
        return Double(Int(self * divisor)) / divisor
    }
}

extension Int {
    func pow(power:UInt) -> Int {
        var answer : Int = 1
        for _ in 1...power { answer *= self }
        return answer
    }
}

extension String {
    func decimalPartLength() -> Int {
        let separators = CharacterSet(charactersIn: ",.")
        guard let range = self.rangeOfCharacter(from: separators) else {
            return 0
        }
        return self.distance(from: range.lowerBound, to: self.endIndex) - 1
    }
}
