//
//  WebService+Concurrency
//  WebService
//
//  Created by Waqar Malik on 6/25/21.
//

import Foundation
import WebService
import WebServiceCombine

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension WebService {
    func data(from url: URL) async throws -> (data: Data, response: URLResponse) {
        let dataResponse: (data: Data, response: URLResponse)
        if #available(macOS 12, iOS 15, tvOS 15, macCatalyst 15, watchOS 8, *) {
            dataResponse = try await session.data(from: url, delegate: nil)
        } else {
            dataResponse = try await session.data(from: url)
        }
        return dataResponse
    }

    func data(for request: URLRequest) async throws -> (data: Data, response: URLResponse) {
        let dataResponse: (data: Data, response: URLResponse)
        if #available(macOS 12, iOS 15, tvOS 15, macCatalyst 15, watchOS 8, *) {
            dataResponse = try await session.data(for: request, delegate: nil)
        } else {
            dataResponse = try await session.data(for: request)
        }
        return dataResponse
    }

	func data<ObjectType>(for request: URLRequest, transform: DataMapper<(data: Data, response: URLResponse), ObjectType>) async throws -> ObjectType {
		let result = try await data(for: request)
		return try transform(result)
	}

		try await data(for: request) { result in
            let data = try result.data.ws_validateNotEmptyData()
            return try decoder.decode(ObjectType.self, from: data)
		}
	}

	func serializable(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
		try await data(for: request) { result in
            let data = try result.data.ws_validateNotEmptyData()
            return try JSONSerialization.jsonObject(with: data, options: options)
		}
	}
}
