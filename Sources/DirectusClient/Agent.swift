//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 01/05/2023.
//

import SwiftUI
import Combine

public struct Agent {
    public func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder(), debugLevel: DebugLevel = .none) -> AnyPublisher<Response<T>, Error> {
            return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                if debugLevel == .verbose {
                    print("DirectusClient ==> ", result)
                    print("DirectusClient ==> data: \(String(describing: String(data: result.data, encoding: .utf8)))")
                }
                
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw DirectusError.other(NSError(domain: "Response cast error", code: 0, userInfo: nil))
                }
                
                if httpResponse.statusCode == 401 {
                    throw DirectusError.unauthorized
                }
                
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

public struct Response<T> {
    public let value: T
    public let response: URLResponse
}
