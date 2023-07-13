//
//  WebServiceTests.swift
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Combine
import Foundation
import os.log
@testable import WebService
@testable import WebServiceCombine
@testable import WebServiceConcurrency
@testable import WebServiceURLMock
import HTTPTypes

import XCTest

final class WebServiceTests: XCTestCase {
	static let baseURLString = "http://localhost:8080"
	static let baseURL = URL(string: "http://localhost:8080")!

	static var allTests = [("testDefaultRequest", testDefaultRequest), ("testQueryItems", testQueryItems),
	                       ("testDefaultRequestConfigurations", testDefaultRequestConfigurations), ("testValidResponse", testValidResponse),
	                       ("testInvalidResponse", testInvalidResponse), ("testValidDataResponse", testValidDataResponse), ("testNetworkFailure", testNetworkFailure),
	                       ("testAsync", testAsync), ("testAsyncDecodable", testAsyncDecodable), ("testAsyncSerializable", testAsyncSerializable)]
	let testTimeout: TimeInterval = 1
	var webService: WebService!

	enum Response {
		static let invalid = URLResponse(url: WebServiceTests.baseURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
		static let valid = HTTPURLResponse(url: WebServiceTests.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
		static let invalid300 = HTTPURLResponse(url: WebServiceTests.baseURL, statusCode: 300, httpVersion: nil, headerFields: nil)!
		static let invalid401 = HTTPURLResponse(url: WebServiceTests.baseURL, statusCode: 401, httpVersion: nil, headerFields: nil)!
	}

	let networkError = NSError(domain: "NSURLErrorDomain", code: -1004, /* kCFURLErrorCannotConnectToHost*/ userInfo: nil)
	override func setUpWithError() throws {
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [URLProtocolMock.self]

		// and create the URLSession from that
		let session = URLSession(configuration: config)
		webService = WebService(session: session)
	}

	override func tearDownWithError() throws {
		webService = nil
	}

	func testDefaultRequest() throws {
		let request = URLRequest(url: Self.baseURL)
		XCTAssertEqual(request.url?.absoluteString, Self.baseURLString)
		let contentType = request[header: .contentType]
		XCTAssertNil(contentType)
		let cacheControl = request[header: .cacheControl]
		XCTAssertNil(cacheControl)
		XCTAssertNil(request.allHTTPHeaderFields)
		XCTAssertNil(request.httpBody)
		XCTAssertTrue(request.httpShouldHandleCookies)
		XCTAssertEqual(request.cachePolicy, NSURLRequest.CachePolicy.useProtocolCachePolicy)
		XCTAssertEqual(request.timeoutInterval, 60.0)

		XCTAssertNil(request.contentType)
		XCTAssertNil(request.userAgent)
		XCTAssertEqual(request, URLRequest(url: Self.baseURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0))
	}

	func testQueryItems() throws {
		var components = URLComponents(string: Self.baseURLString)!
		components = components.setQueryItems([URLQueryItem(name: "test1", value: "test1"), URLQueryItem(name: "test2", value: "test2")])
		XCTAssertNotNil(components.queryItems)
		XCTAssertEqual(components.queryItems?.count ?? 0, 2)
		XCTAssertEqual(components.url?.absoluteString, "\(Self.baseURLString)?test1=test1&test2=test2")
		components = components.appendQueryItems([URLQueryItem(name: "test3", value: "test3")])
		XCTAssertEqual(components.queryItems?.count ?? 0, 3)
		XCTAssertEqual(components.url?.absoluteString, "\(Self.baseURLString)?test1=test1&test2=test2&test3=test3")
		components = components.setQueryItems([])
		XCTAssertEqual(components.queryItems?.count ?? 0, 0)
		let absoluteString = components.url?.absoluteString
		XCTAssertNotNil(absoluteString)
		XCTAssertEqual(absoluteString!, Self.baseURLString)
		components = components.setQueryItems([URLQueryItem(name: "test 3", value: "test 3")])
		XCTAssertEqual(components.queryItems?.count ?? 0, 1)
		XCTAssertEqual(components.url?.absoluteString, "\(Self.baseURLString)?test%203=test%203")
	}

	func testDefaultRequestConfigurations() throws {
		var request = URLRequest(url: Self.baseURL)
			.setCachePolicy(.reloadIgnoringLocalCacheData)
		XCTAssertEqual(request.cachePolicy, NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData)
		request = request
			.setContentType(.json)
		let first = request[header: .contentType]
		XCTAssertEqual(first, .json)
		XCTAssertEqual(request.allHTTPHeaderFields?.count, 1)
	}

	func testValidResponse() throws {
		let request = URLRequest(url: Self.baseURL)
			.setMethod(.get)
		let requestURL = request.url
		XCTAssertNotNil(requestURL)
		URLProtocolMock.requestHandlers[requestURL!] = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.valid, Data())
		}

		let publisher = webService.dataPublisher(for: request)
		let validTest = evalValidResponseTest(publisher: publisher)
		wait(for: validTest.expectations, timeout: testTimeout)
		validTest.cancellable?.cancel()
	}

	func testInvalidResponse() throws {
		let request = URLRequest(url: Self.baseURL)
			.setMethod(.get)
		let requestURL = request.url
		XCTAssertNotNil(requestURL)
		URLProtocolMock.requestHandlers[requestURL!] = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.invalid401, Data())
		}

		let publisher = webService.dataPublisher(for: request)
		let invalidTest = evalInvalidResponseTest(publisher: publisher)
		wait(for: invalidTest.expectations, timeout: testTimeout)
		invalidTest.cancellable?.cancel()
	}

	func testValidDataResponse() throws {
		let request = URLRequest(url: Self.baseURL)
			.setMethod(.get)
		let requestURL = request.url
		XCTAssertNotNil(requestURL)
		URLProtocolMock.requestHandlers[requestURL!] = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			let data = Data("{}".utf8)
			return (Response.valid, data)
		}

		let publisher = webService.dataPublisher(for: request)
		let invalidTest = evalValidResponseTest(publisher: publisher)
		wait(for: invalidTest.expectations, timeout: testTimeout)
		invalidTest.cancellable?.cancel()
	}

	func testNetworkFailure() throws {
		let request = URLRequest(url: Self.baseURL)
			.setMethod(.get)
		let requestURL = request.url
		XCTAssertNotNil(requestURL)
		URLProtocolMock.requestHandlers[requestURL!] = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			let data = Data("{}".utf8)
			return (Response.invalid401, data)
		}
		let publisher = webService.dataPublisher(for: request)
		let invalidTest = evalInvalidResponseTest(publisher: publisher)
		wait(for: invalidTest.expectations, timeout: testTimeout)
		invalidTest.cancellable?.cancel()
	}

	func evalValidResponseTest<P: Publisher>(publisher: P?) -> (expectations: [XCTestExpectation], cancellable: AnyCancellable?) {
		XCTAssertNotNil(publisher)

		let finished = expectation(description: "Finished")

		let cancellable = publisher?.sink(receiveCompletion: { completion in
			if case .failure(let error) = completion {
				os_log(.error, log: OSLog.tests, "TEST ERROR %@", error.localizedDescription)
			}
			finished.fulfill()
		}, receiveValue: { response in
			XCTAssertNotNil(response)
			os_log(.info, log: OSLog.tests, "%@", "\(response)")
		})
		return (expectations: [finished], cancellable: cancellable)
	}

	func evalInvalidResponseTest<P: Publisher>(publisher: P?) -> (expectations: [XCTestExpectation], cancellable: AnyCancellable?) {
		XCTAssertNotNil(publisher)

		let finished = expectation(description: "Finsihed")

		let cancellable = publisher?.sink(receiveCompletion: { completion in
			switch completion {
			case .failure(let error):
				os_log(.error, log: OSLog.tests, "TEST FULFILLED %@", error.localizedDescription)
			case .finished:
				XCTFail("Result should be error")
			}
			finished.fulfill()
		}, receiveValue: { response in
			XCTAssertNotNil(response)
			os_log(.info, log: OSLog.tests, "%@", "\(response)")
		})
		return (expectations: [finished], cancellable: cancellable)
	}
}

extension WebServiceTests {
	func testAsync() async throws {
		let request = URLRequest(url: Self.baseURL)
		let requestURL = request.url
		XCTAssertNotNil(requestURL)
		URLProtocolMock.requestHandlers[requestURL!] = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.valid, Data())
		}

		let (data, _) = try await webService.data(for: request)
		XCTAssertEqual(data, Data())
	}

	func testDecodableData() throws {
		let data = try Bundle.module.data(forResource: "Response", withExtension: "json", subdirectory: "TestData")
		XCTAssertNotNil(data)
		let decoded = try JSONDecoder().decode([String: String].self, from: data)
		XCTAssertEqual(decoded.count, 2)
		XCTAssertEqual(decoded["key1"], "value1")
		XCTAssertEqual(decoded["key2"], "value2")
		XCTAssertEqual(decoded["key3"], nil)
	}

	func testAsyncDecodable() async throws {
		let data = try Bundle.module.data(forResource: "Response", withExtension: "json", subdirectory: "TestData")
		XCTAssertNotNil(data)
		let request = URLRequest(url: Self.baseURL)
			.setMethod(.get)
		let requestURL = request.url
		XCTAssertNotNil(requestURL)
		URLProtocolMock.requestHandlers[requestURL!] = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.valid, data)
		}

		let decoded: [String: String] = try await webService.decodable(for: request)
		XCTAssertEqual(decoded.count, 2)
		XCTAssertEqual(decoded["key1"], "value1")
		XCTAssertEqual(decoded["key2"], "value2")
		XCTAssertEqual(decoded["key3"], nil)
	}

	func testAsyncSerializable() async throws {
		let data = try Bundle.module.data(forResource: "Response", withExtension: "json", subdirectory: "TestData")
		XCTAssertNotNil(data)
		let request = URLRequest(url: Self.baseURL)
			.setMethod(.get)
		let requestURL = request.url
		XCTAssertNotNil(requestURL)
		URLProtocolMock.requestHandlers[requestURL!] = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.valid, data)
		}

		let responseItem = try await webService.serializable(for: request)
		let decoded = responseItem as? [String: String]
		XCTAssertNotNil(decoded)
		XCTAssertEqual(decoded!.count, 2)
		XCTAssertEqual(decoded!["key1"], "value1")
		XCTAssertEqual(decoded!["key2"], "value2")
		XCTAssertEqual(decoded!["key3"], nil)
	}
}
