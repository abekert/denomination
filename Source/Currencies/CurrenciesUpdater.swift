//
//  CurrenciesUpdater.swift
//  Denomination
//
//  Created by Alexander Bekert on 18/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import Foundation
import SWXMLHash

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

class CurrenciesUpdater {
    class func performTest() {
        getLastMonthCurrenciesRates(currency: .USD) { (rates) in
            print(rates)
        }
    }
    
    enum GetCurrenciesResult {
        case Success(ratesHistory: RatesHistory)
        case Error(String)
    }
    
    class func getLastMonthCurrenciesRates(currency: Currencies, completion: @escaping (GetCurrenciesResult) -> Void) {
        let from = Date.previousMonth()
        let to = Date.tomorrow()
        getCurrenciesRates(currency: currency, from: from, to: to, completion: completion)
    }
    
    class func getCurrenciesRates(currency: Currencies, from: Date, to: Date, completion: @escaping (GetCurrenciesResult) -> Void) {
        
        let request = "http://www.nbrb.by/API/ExRates/Rates/Dynamics/\(currency.code)?startDate=\(from.nbrbDescription())&endDate=\(to.nbrbDescription())"
        print (request)
        guard let url = URL(string: request) else {
            let message = "Can't create URL from string: \(request)"
            print(message)
            completion (GetCurrenciesResult.Error(message))
            return
        }
        
        let session = URLSession.shared
        let urlRequest = URLRequest(url: url)
        session.dataTask(with: urlRequest) { (data, response, error) -> Void in
            if let e = error {
                let message = "Error: \(e.localizedDescription)"
                print(message)
                completion(GetCurrenciesResult.Error(message))
                return
            }
            
            let rates = RatesHistory(currency: currency)

            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [Dictionary<String, Any>]
                
                for day in parsedData {
                    guard let rate = day["Cur_OfficialRate"] as? Double, let dateString = day["Date"] as? String else {
                        continue;
                    }
                    
                    if let date = Date.from(nbrbString: dateString) {
                        print("Rate: \(rate), date: \(date.shortDescription)")
                        rates.history[date] = rate;
                    }
                }
            } catch let error as NSError {
                print(error)
            }
            
            completion(GetCurrenciesResult.Success(ratesHistory: rates))

        }.resume()
    }
}
