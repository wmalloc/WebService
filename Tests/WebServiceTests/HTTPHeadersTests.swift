//
//  HTTPHeadersTests.swift
//
//
//  Created by Waqar Malik on 1/15/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

@testable import WebService
import XCTest

final class HTTPHeadersTests: XCTestCase {
	func testBaseHeaders() throws {
		let headers = HTTPHeaders()
			.add(.defaultAcceptLanguage)
			.add(.defaultAcceptEncoding)
			.add(.defaultUserAgent)

		XCTAssertFalse(headers.isEmpty)
		XCTAssertEqual(headers.count, 3)
		XCTAssertTrue(headers.contains(.defaultUserAgent))
		XCTAssertFalse(headers.contains(.contentType(URLRequest.ContentType.json)))
	}

	func testURLSessionConfiguration() throws {
		let session = URLSessionConfiguration.default
		session.headers = HTTPHeaders.defaultHeaders
		XCTAssertEqual(session.httpAdditionalHeaders?.count, 3)

		let headers = session.headers
		XCTAssertEqual(headers?.count, 3)
	}

	func testDefaultHeaders() throws {
		let acceptEncoding = HTTPHeader.defaultAcceptEncoding
		XCTAssertEqual(acceptEncoding.name, URLRequest.Header.acceptEncoding)
		XCTAssertEqual(acceptEncoding.value, "br;q=1.0, gzip;q=0.9, deflate;q=0.8")

		// "xctest/14.2 (com.apple.dt.xctest.tool; build:21501; macOS Version 13.1 (Build 22C65)) WebService"
		let userAgent = HTTPHeader.defaultUserAgent
		XCTAssertEqual(userAgent.name, URLRequest.Header.userAgent)
		XCTAssertTrue(userAgent.value.contains("com.apple.dt.xctest.tool"))
		XCTAssertTrue(userAgent.value.hasPrefix("xctest"))
		XCTAssertTrue(userAgent.value.hasSuffix("WebService"))
		XCTAssertEqual(userAgent.value, String.ws_userAgent)

		let acceptLanguage = HTTPHeader.defaultAcceptLanguage
		XCTAssertEqual(acceptLanguage.name, URLRequest.Header.acceptLanguage)
		let lanugages = Locale.preferredLanguages.prefix(6).ws_qualityEncoded()
		XCTAssertEqual(acceptLanguage.value, lanugages)
	}

	func testURLRequestHeaders() throws {
		let request = URLRequest(url: URL(string: "https://api.github.com")!)
			.setMethod(.GET)
			.setUserAgent(String.ws_userAgent)
			.setHttpHeaders(HTTPHeaders.defaultHeaders)
			.addHeader(HTTPHeader.accept(URLRequest.ContentType.json))

		let headers = request.headers
		XCTAssertNotNil(headers)
		XCTAssertEqual(headers?.count, 4)
		XCTAssertFalse(headers!.contains(.contentType(URLRequest.ContentType.xml)))
		XCTAssertTrue(headers!.contains(.defaultAcceptLanguage))
	}

	func testDictionary() throws {
		var headers = HTTPHeaders()
		headers.update(name: URLRequest.Header.contentType, value: URLRequest.ContentType.xml)
		XCTAssertEqual(headers.count, 1)
		XCTAssertEqual(headers.value(for: URLRequest.Header.contentType), URLRequest.ContentType.xml)
		headers.update(name: URLRequest.Header.contentType, value: URLRequest.ContentType.json)
		XCTAssertEqual(headers.count, 1)
		XCTAssertEqual(headers.value(for: URLRequest.Header.contentType), URLRequest.ContentType.json)
		headers = headers.add(HTTPHeader(name: URLRequest.Header.authorization, value: "Password"))
			.add(HTTPHeader(name: URLRequest.Header.contentLength, value: "\(0)"))
			.add(.authorization(token: "Token"))
		XCTAssertEqual(headers.count, 3)
		let dictionary = headers.dictionary
		XCTAssertEqual(dictionary.count, 3)
	}
}
