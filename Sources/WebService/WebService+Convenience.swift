//
//  WebService+Convenience.swift
//
//
//  Created by Waqar Malik on 6/16/21.
//

import Combine
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension WebService {
    func data(request: Request) -> AnyPublisher<Data, Error> {
        session.servicePublisher(for: request)
            .tryMap { result -> Data in
                try result.data.ws_validate(result.response)
            }
            .eraseToAnyPublisher()
    }

    func decodable<T: Decodable>(request: Request, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        session.servicePublisher(for: request)
            .tryMap { result -> Data in
                let data = try result.data.ws_validate(result.response).ws_validate()
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    func serializable(request: Request, options: JSONSerialization.ReadingOptions = .allowFragments) -> AnyPublisher<Any, Error> {
        session.servicePublisher(for: request)
            .tryMap { result -> Data in
                let data = try result.data.ws_validate(result.response).ws_validate()
                return data
            }
            .tryMap { data -> Any in
                try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            }
            .eraseToAnyPublisher()
    }
}

@available(swift 5.5)
@available(OSX 12, iOS 15, tvOS 15, watchOS 8, *)
public extension WebService {
    func data(request: Request) async throws -> Data {
        let (data, response) = try await session.data(for: request.urlRequest, delegate: nil)
        let validData = try data.ws_validate(response).ws_validate()
        return validData
    }

    func decodable<T: Decodable>(request: Request, decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        let data = try await data(request: request)
        return try decoder.decode(T.self, from: data)
    }

    func serializable(request: Request, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
        let data = try await data(request: request)
        return try JSONSerialization.jsonObject(with: data, options: options)
    }
}
