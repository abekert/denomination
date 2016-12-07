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
        case .EUR: return 19
        case .RUB: return 190
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
        let to = Date()
        getCurrenciesRates(currency: currency, from: from, to: to, completion: completion)
    }
    
    class func getCurrenciesRates(currency: Currencies, from: Date, to: Date, completion: @escaping (GetCurrenciesResult) -> Void) {
        
        let request = "http://www.nbrb.by/Services/XmlExRatesDyn.aspx?curId=\(currency.code)&fromDate=\(from.nbrbDescription())&toDate=\(to.nbrbDescription())"
        print (request)
        guard let url = URL(string: request) else {
            let message = "Can't create URL from string: \(request)"
            print(message)
            completion (GetCurrenciesResult.Error(message))
            return
        }
        
        let session = URLSession.shared
        let urlRequest = URLRequest(url: url)
//        session.dataTask(with: url, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)
        session.dataTask(with: urlRequest) { (data, response, error) -> Void in
            if let e = error {
                let message = "Error: \(e.localizedDescription)"
                print(message)
                completion(GetCurrenciesResult.Error(message))
                return
            }
            
            if let d = data {
                //                print(String (data: d, encoding: NSUTF8StringEncoding))
                let xml = SWXMLHash.parse(d)
                let rates = RatesHistory(currency: currency)
                for element in xml["Currency"]["Record"] {
                    guard let dateString = element.element?.attribute(by: "Date")?.text, let rateString = element["Rate"].element?.text else {
                        continue
                    }
                    
                    guard let date = Date.fromNbrbString(date: dateString), let rate = Double(rateString) else {
                        continue;
                    }
                    
                    rates.history[date] = rate;
                }
                
                DispatchQueue.main.async {
                    completion(GetCurrenciesResult.Success(ratesHistory: rates))
                }
            }
        }.resume()
    }
}
