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

@available(macOS 12, iOS 15, tvOS 15, macCatalyst 15, watchOS 8, *)
public extension WebService {
	func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> URLDataResponse {
    try await session.data(from: url, delegate: delegate)
	}

	func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> URLDataResponse {
    try await session.data(for: request, delegate: delegate)
  }

	func data<ObjectType>(for request: URLRequest, transformer: Transformer<URLDataResponse, ObjectType>) async throws -> ObjectType {
		let result = try await data(for: request)
		return try transformer(result)
	}

	func decodable<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) async throws -> ObjectType {
    try await data(for: request, transformer: { try decoder.decode(ObjectType.self, from: $0) })
	}

	func serializable(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
    try await data(for: request, transformer: { try JSONSerialization.jsonObject(with: $0, options: options) })
	}

	func upload<ObjectType>(for request: URLRequest, fromFile file: URL, transformer: Transformer<URLDataResponse, ObjectType>) async throws -> ObjectType {
		let result = try await session.upload(for: request, fromFile: file)
		return try transformer(result)
	}
}

@available(macOS 12, iOS 15, tvOS 15, macCatalyst 15, watchOS 8, *)
extension WebService: URLAsyncTransferable {}
