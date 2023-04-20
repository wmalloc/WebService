//
//  WebService+Convenience.swift
//
//  Created by Waqar Malik on 6/16/21.
//  Copyright © 2020 Waqar Malik All rights reserved.
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

	func dataPublisher<ObjectType>(for request: URLRequest, transform: @escaping Transformer<WebService.DataResponse, ObjectType>) -> AnyPublisher<ObjectType, Error> {
		session.dataTaskPublisher(for: request)
			.tryMap { result -> ObjectType in
				try result.data.ws_validate(result.response)
				return try transform(result)
			}
			.eraseToAnyPublisher()
	}

	func decodablePublisher<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<ObjectType, Error> {
		dataPublisher(for: request)
			.decode(type: ObjectType.self, decoder: decoder)
			.eraseToAnyPublisher()
	}

	func serializablePublisher(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) -> AnyPublisher<Any, Error> {
		dataPublisher(for: request, transform: Self.jsonSerializableTransformer(options: options))
	}

	func uploadPublisher<ObjectType>(for request: URLRequest, fromFile file: URL, transform: @escaping Transformer<WebService.DataResponse, ObjectType>) -> AnyPublisher<ObjectType, Error> {
		var sessionDataTask: URLSessionDataTask?
		let receiveCancel = { sessionDataTask?.cancel() }
		return Future { [weak self] promise in
			sessionDataTask = self?.upload(with: request, fromFile: file, transform: transform) { result in
				promise(result)
			}
		}
		.handleEvents(receiveCancel: {
			receiveCancel()
		})
		.eraseToAnyPublisher()
	}
}

public extension WebService {
	func decoded<Route: URLRequestable>(route: Route) -> AnyPublisher<Route.Response, Error> {
		guard let request = try? route.urlRequest() else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}

		return dataPublisher(for: request, transform: route.transformer)
	}
}
