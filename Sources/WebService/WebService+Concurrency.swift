//
//  WebService+Concurrency
//
//  Created by Waqar Malik on 6/25/21.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation
import os.log
import URLRequestable
import WebService

public extension WebService {
	func data(from url: URL, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Data, HTTPResponse) {
		let (data, response) = try await session.data(from: url, delegate: delegate)
		return try (data, response.httpResponse)
	}

	func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Data, HTTPResponse) {
		let (data, response) = try await session.data(for: request, delegate: delegate)
		return try (data, response.httpResponse)
	}

	func data<ObjectType>(for request: URLRequest, transformer: Transformer<Data, ObjectType>) async throws -> ObjectType {
		let (data, response) = try await data(for: request)
		return try transformer(data, response)
	}

	func decodable<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) async throws -> ObjectType {
		try await data(for: request, transformer: { data, _ in try decoder.decode(ObjectType.self, from: data) })
	}

	func serializable(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
		try await data(for: request, transformer: { data, _ in try JSONSerialization.jsonObject(with: data, options: options) })
	}

	func upload<ObjectType>(for request: URLRequest, fromFile file: URL, transformer: Transformer<Data, ObjectType>) async throws -> ObjectType {
		let (data, response) = try await session.upload(for: request, fromFile: file)
		let httpResponse = try response.httpResponse
		return try transformer(data, httpResponse)
	}
}
