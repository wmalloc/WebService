//
//  WebService+Convenience.swift
//
//  Created by Waqar Malik on 6/16/21.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Combine
import Foundation
import URLRequestable
import WebService

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension WebService {
	func dataPublisher(for url: URL) -> AnyPublisher<Data, Error> {
		dataPublisher(for: URLRequest(url: url), transformer: { $0.data })
	}

	func dataPublisher(for request: URLRequest) -> AnyPublisher<Data, Error> {
		dataPublisher(for: request, transformer: { $0.data })
	}

	func decodablePublisher<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<ObjectType, Error> {
		dataPublisher(for: request)
			.decode(type: ObjectType.self, decoder: decoder)
			.eraseToAnyPublisher()
	}

	func serializablePublisher(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) -> AnyPublisher<Any, Error> {
		dataPublisher(for: request, transformer: JSONSerialization.transformer(options: options))
	}

	func uploadPublisher<ObjectType>(for request: URLRequest, fromFile file: URL, transform: @escaping Transformer<URLDataResponse, ObjectType>) -> AnyPublisher<ObjectType, Error> {
		var sessionDataTask: URLSessionDataTask?
		let receiveCancel = { sessionDataTask?.cancel() }
		return Future { [weak self] promise in
			sessionDataTask = self?.upload(with: request, fromFile: file, transformer: transform) { result in
				promise(result)
			}
		}
		.handleEvents(receiveCancel: {
			receiveCancel()
		})
		.eraseToAnyPublisher()
	}
}
