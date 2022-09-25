//
//  Networking.swift
//  Currencies
//
//  Created by Vagan Albertyan on 16.04.2022.
//

import Foundation

class Networking { 

    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    public func request(url: String, parameters: [String: Any]?, method: Method, completion: ((Data?, Error?) -> ())? = nil) {
        
        // Получаем URL
        let url = fullURL(baseURL: url, parameters: parameters)
        if let url = url {
            
            // Делаем запрос
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            
            // Запускаем запрос
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                // Возврат данных по завершению
                if let completion = completion {
                    completion(data, error)
                }
            })
            task.resume()
            
        } else {
            print("Networking: Не может создаться правильная ссылка")
        }
    }
    
    // MARK: Helpers
    
    private func fullURL(baseURL: String, parameters: [String: Any]?) -> URL? {
        var urlString = baseURL

        if let parameters = parameters {
            urlString += "?"
            for key in parameters.keys {
                urlString += "\(key)=\(String(describing: parameters[key]!))&"
            }
            urlString.remove(at: urlString.index(before: urlString.endIndex))
        }
        
        return URL(string: urlString)
    }
}
