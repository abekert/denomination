//
//  CurrenciesUpdater.swift
//  Denomination
//
//  Created by Alexander Bekert on 18/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import Foundation

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
