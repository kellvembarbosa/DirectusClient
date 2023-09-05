//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 01/05/2023.
//

import SwiftUI
import Combine

public struct Agent {
    // 1
    public struct Response<T> {
        public let value: T
        public let response: URLResponse
    }
    
    // 2
    public func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request) // 3
            .tryMap { result -> Response<T> in
                print("DirectusClient ==> ", result)
                print("DirectusClient ==> data: \(String(data: result.data, encoding: .utf8))")
                let value = try decoder.decode(T.self, from: result.data) // 4
                // print("kellvem 2", value)
                return Response(value: value, response: result.response) // 5
            }
            .receive(on: DispatchQueue.main) // 6
            .eraseToAnyPublisher() // 7
    }
}
