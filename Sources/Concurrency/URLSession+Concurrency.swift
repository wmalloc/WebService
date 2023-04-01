//
//  URLSession+Concurrency.swift
//
//  Created by Waqar Malik on 2/28/22.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

@available(swift 5.5)
@available(iOS, introduced: 13.0, deprecated: 15.0, message: "Use the built-in API instead")
@available(tvOS, introduced: 13.0, deprecated: 15.0, message: "Use the built-in API instead")
@available(watchOS, introduced: 6.0, deprecated: 8.0, message: "Use the built-in API instead")
@available(macCatalyst, introduced: 13.0, deprecated: 15.0, message: "Use the built-in API instead")
@available(macOS, introduced: 10.15, deprecated: 12.0, message: "Use the built-in API instead")
public extension URLSession {
	func data(from url: URL) async throws -> (Data, URLResponse) {
		try await data(for: URLRequest(url: url))
	}

	func data(for request: URLRequest) async throws -> (Data, URLResponse) {
		var dataTask: URLSessionDataTask?
		let onCancel = { dataTask?.cancel() }

		return try await withTaskCancellationHandler(operation: {
			try await withCheckedThrowingContinuation { continuation in
				dataTask = self.dataTask(with: request, completionHandler: { data, response, error in
					guard let data, let response else {
						let error = error ?? URLError(.badServerResponse)
						return continuation.resume(throwing: error)
					}
					continuation.resume(returning: (data, response))
				})

				dataTask?.resume()
			}
		}, onCancel: {
			onCancel()
		})
	}
}
