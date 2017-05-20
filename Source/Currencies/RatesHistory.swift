class RatesHistory: CustomStringConvertible {
    let currency: Currencies
    var history = Dictionary<Date, Double> ()
    
    var latestRate: (date: Date, rate: Double, growth: Double)? {
        let history = sortedHistory
        guard let (date, rate) = history.first else {
            return nil
        }
        
        if history.count < 2 {
            return (date: date, rate: rate, growth: 0)
        }
        
        let previousRate = history[1].1
        return (date: date, rate: rate, growth: rate - previousRate)
    }
    
    var sortedHistory: [(Date, Double)] {
        return history.sorted { ($0.0).compare($1.0) == .orderedDescending }
    }
    
    init(currency: Currencies) {
        self.currency = currency
    }
    
    var description: String {
        var description = "History of \(currency) rates\n"
        
        for (date, rate) in sortedHistory {
            description.append("\(date.shortShortDescription) - \(rate)\t")
        }
        return description
    }
}
