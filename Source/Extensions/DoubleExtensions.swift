extension Double {
    func hasDecimalPart() -> Bool {
        return self.truncatingRemainder(dividingBy:1) != 0
    }
    
    func decimalPartLength() -> Int {
        let str = String(self)
        if str.characters.last == "0" {
            return 0
        }
        let separators = CharacterSet(charactersIn: ",.")
        guard let range = str.rangeOfCharacter(from: separators) else {
            return 0
        }
        return str.distance(from: range.lowerBound, to: str.endIndex) - 1
    }
}
