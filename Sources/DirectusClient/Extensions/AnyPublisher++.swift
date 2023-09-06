//
//  SwiftUIView.swift
//  
//
//  Created by Kellvem Barbosa on 06/09/2023.
//
import Combine
import Foundation

public extension AnyPublisher where Output == URLRequest, Failure == Error {
    func execute(with agent: Agent) -> AnyPublisher<Data, Error> {
        return self.flatMap { request in
            agent.run(request)
                .map(\.value)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == URLRequest, Failure == Error {
    func execute(with agent: Agent) -> AnyPublisher<Data, Error> {
        return self.flatMap { request in
            agent.run(request)
                .map(\.value)
        }
        .eraseToAnyPublisher()
    }
}
