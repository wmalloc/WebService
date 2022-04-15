//
//  WebServiceTests.swift
//  WebServiceTests
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Combine
import Foundation
import os.log
@testable import WebService
@testable import WebServiceCombine
@testable import WebServiceConcurrency
@testable import WebServiceURLMock

import XCTest

final class WebServiceTests: XCTestCase {
	static var allTests = [("testBaseURL", testBaseURL), ("testDefaultRequest", testDefaultRequest), ("testQueryItems", testQueryItems)]
	let testTimeout: TimeInterval = 1
	var webService: WebService!

	enum Response {
		static let invalid = URLResponse(url: URL(string: "http://localhost:8080")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
		static let valid = HTTPURLResponse(url: URL(string: "http://localhost:8080")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		static let invalid300 = HTTPURLResponse(url: URL(string: "http://localhost:8080")!, statusCode: 300, httpVersion: nil, headerFields: nil)!
		static let invalid401 = HTTPURLResponse(url: URL(string: "http://localhost:8080")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
	}

	let networkError = NSError(domain: "NSURLErrorDomain", code: -1004, /* kCFURLErrorCannotConnectToHost*/ userInfo: nil)
	override func setUpWithError() throws {
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [URLProtocolMock.self]

		// and create the URLSession from that
		let session = URLSession(configuration: config)
		webService = WebService(baseURLString: "https://localhost:8080", session: session)
	}

	override func tearDownWithError() throws {
		webService = nil
	}

	func testBaseURL() throws {
		let baseURLString = "https://localhost:8080"
		let baseURL = URL(string: baseURLString)
		XCTAssertEqual(webService.baseURLString, baseURLString)
		XCTAssertNotNil(webService.baseURL)
		XCTAssertEqual(webService.baseURL, baseURL)
	}

	func testDefaultRequest() throws {
		let baseURLString = webService.baseURLString
		let baseURL = webService.baseURL
		XCTAssertNotNil(baseURLString)
        let request = URLRequest(url: baseURL!)
        XCTAssertEqual(request.url?.absoluteString, baseURLString!)
        let contentType = request[header: URLRequest.Header.contentType]
		XCTAssertNil(contentType)
		let cacheControl = request[header: URLRequest.Header.cacheControl]
		XCTAssertNil(cacheControl)
        XCTAssertNil(request.allHTTPHeaderFields)
        XCTAssertNil(request.httpBody)
		XCTAssertTrue(request.httpShouldHandleCookies)
 		XCTAssertEqual(request.cachePolicy, NSURLRequest.CachePolicy.useProtocolCachePolicy)
		XCTAssertEqual(request.timeoutInterval, 60.0)

		XCTAssertNil(request.contentType)
		XCTAssertNil(request.userAgent)
		XCTAssertEqual(try request.urlRequest(), URLRequest(url: baseURL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0))
	}

	func testQueryItems() throws {
		let baseURLString = webService.baseURLString
		XCTAssertNotNil(baseURLString)
        var components = URLComponents(string: baseURLString!)!
		components = components.setQueryItems([URLQueryItem(name: "test1", value: "test1"), URLQueryItem(name: "test2", value: "test2")])
		XCTAssertNotNil(components.queryItems)
		XCTAssertEqual(components.queryItems?.count ?? 0, 2)
		XCTAssertEqual(components.url?.absoluteString, "https://localhost:8080?test1=test1&test2=test2")
		components = components.appendQueryItems([URLQueryItem(name: "test3", value: "test3")])
		XCTAssertEqual(components.queryItems?.count ?? 0, 3)
		XCTAssertEqual(components.url?.absoluteString, "https://localhost:8080?test1=test1&test2=test2&test3=test3")
		components = components.setQueryItems([])
		XCTAssertEqual(components.queryItems?.count ?? 0, 0)
        let absoluteString = components.url?.absoluteString
        XCTAssertNotNil(absoluteString)
		XCTAssertEqual(absoluteString!, "https://localhost:8080")
		components = components.setQueryItems([URLQueryItem(name: "test 3", value: "test 3")])
		XCTAssertEqual(components.queryItems?.count ?? 0, 1)
		XCTAssertEqual(components.url?.absoluteString, "https://localhost:8080?test%203=test%203")
	}

	func testDefaultRequestConfigurations() throws {
		let baseURLString = webService.baseURLString
		XCTAssertNotNil(baseURLString)
        var request = URLRequest(url: webService.baseURL!)
			.setCachePolicy(.reloadIgnoringLocalCacheData)
		XCTAssertEqual(request.cachePolicy, NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData)
		request = request
            .setContentType(URLRequest.ContentType.json)
        let first = request[header: URLRequest.Header.contentType]
		XCTAssertEqual(first, URLRequest.ContentType.json)
		XCTAssertEqual(request.allHTTPHeaderFields?.count, 1)
	}

	func testValidResponse() throws {
		XCTAssertNotNil(webService.baseURLString)
		let request = Request(.GET, urlString: webService.baseURLString!)
		let requestURL = try request.url()
		URLProtocolMock.requestHandler = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.valid, Data())
		}

		let publisher = webService.servicePublisher(request: request)
		let validTest = evalValidResponseTest(publisher: publisher)
		wait(for: validTest.expectations, timeout: testTimeout)
		validTest.cancellable?.cancel()
	}

	func testInvalidResponse() throws {
		XCTAssertNotNil(webService.baseURLString)
		let request = Request(.GET, urlString: webService.baseURLString!)
		let requestURL = try request.url()
		URLProtocolMock.requestHandler = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.invalid401, Data())
		}

		let publisher = webService.servicePublisher(request: request)
		let invalidTest = evalInvalidResponseTest(publisher: publisher)
		wait(for: invalidTest.expectations, timeout: testTimeout)
		invalidTest.cancellable?.cancel()
	}

	func testValidDataResponse() throws {
		XCTAssertNotNil(webService.baseURLString)
		let request = Request(.GET, urlString: webService.baseURLString!)
		let requestURL = try request.url()
		URLProtocolMock.requestHandler = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			let data = Data("{}".utf8)
			return (Response.valid, data)
		}

		let publisher = webService.servicePublisher(request: request)
		let invalidTest = evalValidResponseTest(publisher: publisher)
		wait(for: invalidTest.expectations, timeout: testTimeout)
		invalidTest.cancellable?.cancel()
	}

	func testNetworkFailure() throws {
		XCTAssertNotNil(webService.baseURLString)
		let request = Request(.GET, urlString: webService.baseURLString!)
		let requestURL = try request.url()
		URLProtocolMock.requestHandler = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			let data = Data("{}".utf8)
			return (Response.invalid401, data)
		}
		let publisher = webService.servicePublisher(request: request)
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
				XCTFail(error.localizedDescription)
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
		XCTAssertNotNil(webService.baseURLString)
        let request = URLRequest(url: webService.baseURL!)
		let requestURL = try request.url()
		URLProtocolMock.requestHandler = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.valid, Data())
		}

		let (data, _) = try await webService.data(request: request)
		XCTAssertEqual(data, Data())
	}

	func testDecodableData() throws {
		let data =
			"""
			{
			   "key1": "value1",
			   "key2": "value2"
			}
			""".data(using: .utf8)
		XCTAssertNotNil(data)
		let decoded = try JSONDecoder().decode([String: String].self, from: data!)
		XCTAssertEqual(decoded.count, 2)
		XCTAssertEqual(decoded["key1"], "value1")
		XCTAssertEqual(decoded["key2"], "value2")
		XCTAssertEqual(decoded["key3"], nil)
	}

	func testAsyncDecodable() async throws {
		let data =
			"""
			{
			   "key1": "value1",
			   "key2": "value2"
			}
			""".data(using: .utf8)
		XCTAssertNotNil(data)
		XCTAssertNotNil(webService.baseURLString)
		let request = Request(.GET, urlString: webService.baseURLString!)
		let requestURL = try request.url()
		URLProtocolMock.requestHandler = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.valid, data!)
		}

		let decoded: [String: String] = try await webService.decodable(request: request)
		XCTAssertEqual(decoded.count, 2)
		XCTAssertEqual(decoded["key1"], "value1")
		XCTAssertEqual(decoded["key2"], "value2")
		XCTAssertEqual(decoded["key3"], nil)
	}

	func testAsyncSerializable() async throws {
		let data =
			"""
			{
			   "key1": "value1",
			   "key2": "value2"
			}
			""".data(using: .utf8)
		XCTAssertNotNil(data)
		XCTAssertNotNil(webService.baseURLString)
		let request = Request(.GET, urlString: webService.baseURLString!)
		let requestURL = try request.url()
		URLProtocolMock.requestHandler = { request in
			guard let url = request.url, url == requestURL else {
				throw URLError(.badURL)
			}

			return (Response.valid, data!)
		}

		let responseItem = try await webService.serializable(request: request)
		let decoded = responseItem as? [String: String]
		XCTAssertNotNil(decoded)
		XCTAssertEqual(decoded!.count, 2)
		XCTAssertEqual(decoded!["key1"], "value1")
		XCTAssertEqual(decoded!["key2"], "value2")
		XCTAssertEqual(decoded!["key3"], nil)
	}
}
