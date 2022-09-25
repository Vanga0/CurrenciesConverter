//
//  JsonWorker.swift
//  CurrenciesPract
//
//  Created by Vagan Albertyan on 05.05.2022.
//

import Foundation

typealias Currency = String
typealias Rate = Double
typealias RateList = [Currency: Rate]

class JsonWorker: Networking {
    
    let baseURL = "https://open.er-api.com/v6/latest/USD"
    
    static let shared = JsonWorker()
    
    func getCurrencies(success: (([Currency]) -> ())? = nil, fail: ((Error) -> ())? = nil) {
    
        // USD базовая валюта
        let baseCurrency = "USD"
        
        getRates(base: baseCurrency, success: { (rates) in
    
            // Если всё ок возвращаем ключи
            if let success = success {
                var currencies = Array(rates.keys)
                currencies.insert(baseCurrency, at: 0)
                success(currencies)
            }
            
        }, fail: fail)
    }
    
    func getRates(base: Currency, success: ((RateList) -> ())? = nil, fail: ((Error) -> ())? = nil) {
        
        let parameters = ["base": base]
        
        request(url: baseURL, parameters: parameters, method: .get) { (data, error) in
            
            // Если ошибка
            if let error = error, let fail = fail {
                fail(error)
            }
            
            // если всё ок
            if let data = data {
                // парсим json
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    let rates = json["rates"] as! RateList
                    

                    // возвращаем курсы
                    if let success = success {
                        success(rates)
                    }
                } catch {
                    print("JSON не вышел погулять")
                }
            }
        }
    }
}




//                    let sortedNames = rates.sorted (by:{ $0.Rate < $1.Rate })
//                    let sortedRates = rates.sorted()({ $0.Rate < $1.Rate -> Bool in
//                        return a > z})
//                    print(sortedRates)
