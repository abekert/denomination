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
