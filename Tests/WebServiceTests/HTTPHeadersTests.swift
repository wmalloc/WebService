//
//  HTTPHeadersTests.swift
//
//
//  Created by Waqar Malik on 1/15/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

@testable import WebService
import XCTest
import URLRequestable

final class HTTPHeadersTests: XCTestCase {
	func testBaseHeaders() throws {
		let headers = HTTPHeaders()
			.add(.defaultAcceptLanguage)
			.add(.defaultAcceptEncoding)
			.add(.defaultUserAgent)

		XCTAssertFalse(headers.isEmpty)
		XCTAssertEqual(headers.count, 3)
		XCTAssertTrue(headers.contains(.defaultUserAgent))
		XCTAssertFalse(headers.contains(.contentType(.json)))
	}

	func testURLSessionConfiguration() throws {
		let session = URLSessionConfiguration.default
		session.headers = HTTPHeaders.defaultHeaders
		XCTAssertEqual(session.httpAdditionalHeaders?.count, 3)

		let headers = session.headers
		XCTAssertEqual(headers?.count, 3)
	}

	func testURLRequestHeaders() throws {
		let request = URLRequest(url: URL(string: "https://api.github.com")!)
			.setMethod(.GET)
			.setUserAgent(String.url_userAgent)
			.setHttpHeaders(HTTPHeaders.defaultHeaders)
			.addHeader(HTTPHeader.accept(.json))

		let headers = request.headers
		XCTAssertNotNil(headers)
		XCTAssertEqual(headers?.count, 4)
		XCTAssertFalse(headers!.contains(.contentType(.xml)))
		XCTAssertTrue(headers!.contains(.defaultAcceptLanguage))
	}

	func testDictionary() throws {
		var headers = HTTPHeaders()
		headers.update(name: .contentType, value: .xml)
		XCTAssertEqual(headers.count, 1)
		XCTAssertEqual(headers.value(for: .contentType), .xml)
		headers.update(name: .contentType, value: .json)
		XCTAssertEqual(headers.count, 1)
		XCTAssertEqual(headers.value(for: .contentType), .json)
		headers = headers.add(HTTPHeader(name: .authorization, value: "Password"))
			.add(HTTPHeader(name: .contentLength, value: "\(0)"))
			.add(.authorization(token: "Token"))
		XCTAssertEqual(headers.count, 3)
		let dictionary = headers.dictionary
		XCTAssertEqual(dictionary.count, 3)
	}
}
