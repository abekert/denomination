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
    var history = Dictionary<NSDate, Double> ()
    
    var latestRate: (date: NSDate, rate: Double, growth: Double)? {
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
    
    var sortedHistory: [(NSDate, Double)] {
        return history.sort { ($0.0).compare($1.0) == .OrderedDescending }
    }
    
    init(currency: Currencies) {
        self.currency = currency
    }
    
    var description: String {
        var description = "History of \(currency) rates\n"

        for (date, rate) in sortedHistory {
            description.appendContentsOf("\(date.shortShortDescription) - \(rate)\t")
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
        getLastMonthCurrenciesRates(.USD) { (rates) in
            print(rates)
        }
    }
    
    enum GetCurrenciesResult {
        case Success(ratesHistory: RatesHistory)
        case Error(String)
    }
    
    class func getLastMonthCurrenciesRates(currency: Currencies, completion: GetCurrenciesResult -> Void) {
        let from = NSDate.previousMonth()
        let to = NSDate()
        getCurrenciesRates(currency, from: from, to: to, completion: completion)
    }
    
    class func getCurrenciesRates(currency: Currencies, from: NSDate, to: NSDate, completion: GetCurrenciesResult -> Void) {
        
        let request = "http://www.nbrb.by/Services/XmlExRatesDyn.aspx?curId=\(currency.code)&fromDate=\(from.nbrbDescription())&toDate=\(to.nbrbDescription())"
        print (request)
        guard let url = NSURL(string: request) else {
            let message = "Can't create URL from string: \(request)"
            print(message)
            completion (GetCurrenciesResult.Error(message))
            return
        }
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            if let e = error {
                let message = "Error: \(e.localizedDescription)"
                print(message)
                completion (GetCurrenciesResult.Error(message))
                return
            }
            
            if let d = data {
                //                print(String (data: d, encoding: NSUTF8StringEncoding))
                let xml = SWXMLHash.parse(d)
                let rates = RatesHistory(currency: currency)
                for element in xml["Currency"]["Record"] {
                    guard let dateString = element.element?.attributes["Date"], rateString = element["Rate"].element?.text else {
                        continue
                    }
                    
                    guard let date = NSDate.fromNbrbString(dateString), rate = Double(rateString) else {
                        continue;
                    }
                    
                    rates.history[date] = rate;
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion (GetCurrenciesResult.Success(ratesHistory: rates))
                }
            }
        }).resume()
    }
}