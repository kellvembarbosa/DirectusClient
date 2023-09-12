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

public extension AnyPublisher where Output == Data {
    /// Verifica se a resposta é vazia e retorna um `Data` padrão se for.
    func handleEmptyResponse() -> AnyPublisher<Data, Error> {
        return self.tryMap { data in
            if data.isEmpty {
                throw DirectusError.emptyResponse
            }
            return data
        }
        .catch { error -> AnyPublisher<Data, Error> in
            if case DirectusError.emptyResponse = error {
                return Just(Data()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            return Fail(error: error).eraseToAnyPublisher()
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
