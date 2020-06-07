//
//  Request.swift
//  TestTask
//
//  Created by Anton Efimenko on 07.06.2020.
//  Copyright © 2020 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

public enum AppRequestError: Error {
    case urlRequestError(response: URLResponse, data: Data?)
    case urlRequestLocalError(Error)
    case unknown(Error)
    case unexpectedResponseType
}

extension URLRequest {
    static func getNews(searchBy: String?) -> URLRequest {
        var components = URLComponents(string: "https://newsapi.org/v2/top-headlines")!
        components.queryItems = [
            URLQueryItem(name: "q", value: searchBy),
            URLQueryItem(name: "apiKey", value: "8de4379da25c4dfab9ba3b70f0e2cfbe")
        ]
        let request = URLRequest(url: components.url!)
        return request
    }
}

func dataRequest(_ request: URLRequest, in session: URLSession) -> Single<Data> {
    return Single.create { single in
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                single(.error(AppRequestError.urlRequestLocalError(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                single(.error(AppRequestError.unexpectedResponseType))
                return
            }
            
            if !(200...299 ~= response.statusCode) {
                #if DEBUG
                if let data = data, let responseString = String.init(data: data, encoding: .utf8) {
                    print("Response string: \(responseString)")
                }
                #endif
                
                single(.error(AppRequestError.urlRequestError(response: response, data: data)))
                return
            }
            
            single(.success(data ?? Data()))
        }
        
        #if DEBUG
        print("URL \(task.originalRequest!.url!.absoluteString)")
        #endif
        
        task.resume()
        
        return Disposables.create { task.cancel() }
    }
}

extension Single where Element == Data {
    func decoded<T: Decodable>() -> Single<T> {
        return self
            .asObservable()
            .map { try JSONDecoder().decode(T.self, from: $0) }
            .asSingle()
    }
}
