//
//  WebService+Convenience.swift
//  WebService
//
//  Created by Waqar Malik on 6/16/21.
//

import Combine
import Foundation
import WebService

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension WebService {
	func dataPublisher(for url: URL) -> AnyPublisher<Data, Error> {
		session.dataTaskPublisher(for: url)
			.tryMap { result in
				try result.response.ws_validate()
				return try result.data.ws_validateNotEmptyData()
			}.eraseToAnyPublisher()
	}

	func dataPublisher(for request: URLRequest) -> AnyPublisher<Data, Error> {
		session.dataTaskPublisher(for: request)
			.tryMap { result -> Data in
				try result.response.ws_validate()
				return try result.data.ws_validate(result.response)
			}
			.eraseToAnyPublisher()
	}

	func dataPublisher<ObjectType>(for request: URLRequest, transform: @escaping DataMapper<(data: Data, response: URLResponse), ObjectType>) -> AnyPublisher<ObjectType, Error> {
		session.dataTaskPublisher(for: request)
			.tryMap { result -> ObjectType in
				try transform(result)
			}
			.eraseToAnyPublisher()
	}

	func decodablePublisher<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<ObjectType, Error> {
		dataPublisher(for: request)
			.decode(type: ObjectType.self, decoder: decoder)
			.eraseToAnyPublisher()
	}

	func serializablePublisher(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) -> AnyPublisher<Any, Error> {
		dataPublisher(for: request)
			.tryMap { data -> Any in
				try JSONSerialization.jsonObject(with: data, options: options)
			}
			.eraseToAnyPublisher()
	}
}
