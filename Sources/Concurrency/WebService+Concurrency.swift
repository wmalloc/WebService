//
//  WebService+Concurrency
//
//  Created by Waqar Malik on 6/25/21.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation
import os.log
import URLRequestable
import WebService

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension WebService {
	func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> URLDataResponse {
		let dataResponse: URLDataResponse
		if #available(macOS 12, iOS 15, tvOS 15, macCatalyst 15, watchOS 8, *) {
			dataResponse = try await session.data(from: url, delegate: delegate)
		} else {
			dataResponse = try await session.data(from: url)
		}
		return dataResponse
	}

	func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> URLDataResponse {
		let dataResponse: URLDataResponse
		if #available(macOS 12, iOS 15, tvOS 15, macCatalyst 15, watchOS 8, *) {
			dataResponse = try await session.data(for: request, delegate: delegate)
		} else {
			dataResponse = try await session.data(for: request)
		}
		return dataResponse
	}

	func data<ObjectType>(for request: URLRequest, transformer: Transformer<URLDataResponse, ObjectType>) async throws -> ObjectType {
		let result = try await data(for: request)
		return try transformer(result)
	}

	func decodable<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) async throws -> ObjectType {
		try await data(for: request, transformer: JSONDecoder.transformer(decoder: decoder))
	}

	func serializable(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
		try await data(for: request, transformer: JSONSerialization.transformer(options: options))
	}

	func upload<ObjectType>(for request: URLRequest, fromFile file: URL, transformer: Transformer<URLDataResponse, ObjectType>) async throws -> ObjectType {
		let result = try await session.upload(for: request, fromFile: file)
		return try transformer(result)
	}
}

@available(macOS 12, iOS 15, tvOS 15, macCatalyst 15, watchOS 8, *)
extension WebService: URLRequestAsyncTransferable {}
