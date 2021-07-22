//
//  WebService+Convenience.swift
//  WebService
//
//  Created by Waqar Malik on 6/16/21.
//

import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, macCatalyst 13.0, watchOS 6.0, *)
public extension WebService {
    func data(request: Request) -> AnyPublisher<Data, Error> {
        session.servicePublisher(for: request)
            .tryMap { result -> Data in
                try result.data.ws_validate(result.response).ws_validateNotEmptyData()
            }
            .eraseToAnyPublisher()
    }

    func decodable<T: Decodable>(request: Request, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        data(request: request)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    func serializable(request: Request, options: JSONSerialization.ReadingOptions = .allowFragments) -> AnyPublisher<Any, Error> {
        data(request: request)
            .tryMap { data -> Any in
                try JSONSerialization.jsonObject(with: data, options: options)
            }
            .eraseToAnyPublisher()
    }
}
