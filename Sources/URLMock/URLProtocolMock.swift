//
//  URLProtocolMock.swift
//  WebServiceTests
//
//  Created by Waqar Malik on 6/21/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation
import XCTest

public class URLProtocolMock: URLProtocol {
	public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

	override public class func canInit(with _: URLRequest) -> Bool { true }
	override public class func canInit(with _: URLSessionTask) -> Bool { true }
	override public class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

	override public func startLoading() {
		guard let client = client else {
			fatalError("missing client")
		}

		guard let handler = Self.requestHandler else {
			fatalError("Handler is unavailable.")
		}

		let validCodes = Set(200 ..< 300)
		do {
			let (response, data) = try handler(request)
			if !validCodes.contains(response.statusCode) {
				throw URLError(URLError.Code(rawValue: response.statusCode))
			}

			client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

			if let data = data {
				client.urlProtocol(self, didLoad: data)
			}

			client.urlProtocolDidFinishLoading(self)
		} catch {
			client.urlProtocol(self, didFailWithError: error)
		}
	}

	override public func stopLoading() {}
}
