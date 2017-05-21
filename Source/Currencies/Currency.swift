enum Currencies: CustomStringConvertible {
    case USD, EUR, RUB
    
    var code: Int {
        switch self {
        case .USD: return 145
        case .EUR: return 292
        case .RUB: return 298
        }
    }
    
    var description: String {
        switch self {
        case .USD: return "USD"
        case .EUR: return "EUR"
        case .RUB: return "RUB"
        }
    }
}
