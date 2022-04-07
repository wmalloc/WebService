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
	func data(request: Request) -> AnyPublisher<Data, Error> {
		session.servicePublisher(for: request)
			.tryMap { result -> Data in
				try result.data.ws_validate(result.response)
			}
			.eraseToAnyPublisher()
	}

	func decodable<ObjectType: Decodable>(request: Request, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<ObjectType, Error> {
		data(request: request)
			.decode(type: ObjectType.self, decoder: decoder)
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
