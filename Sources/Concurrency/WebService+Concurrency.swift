//
//  WebService+Concurrency
//  WebService
//
//  Created by Waqar Malik on 6/25/21.
//

import Combine
import Foundation
import WebService

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension WebService {
	func data(request: Request) async throws -> Data {
		let urlRequest = try request.urlRequest()
		let dataResponse: (data: Data, response: URLResponse)
		if #available(macOS 12, iOS 15, tvOS 15, macCatalyst 15, watchOS 8, *) {
			dataResponse = try await session.data(for: urlRequest, delegate: nil)
		} else {
			dataResponse = try await session.data(for: urlRequest)
		}
		let validData = try dataResponse.data.ws_validate(dataResponse.response).ws_validateNotEmptyData()
		return validData
	}

	func decodable<ObjectType: Decodable>(request: Request, decoder: JSONDecoder = JSONDecoder()) async throws -> ObjectType {
		let data = try await data(request: request)
		return try decoder.decode(ObjectType.self, from: data)
	}

	func serializable(request: Request, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
		let data = try await data(request: request)
		return try JSONSerialization.jsonObject(with: data, options: options)
	}
}
