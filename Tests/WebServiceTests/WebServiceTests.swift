//
//  WebServiceTests.swift
//
//  Created by Waqar Malik on 4/28/20
//

import Combine
import Foundation
import HTTPRequestable
import HTTPTypes
import OSLog

@testable import WebService
import XCTest
import MockURLProtocol

final class WebServiceTests: XCTestCase {
  private static let baseURLString = "http://localhost:8080"
  private static let baseURL = URL(string: "http://localhost:8080")!

  static let allTests: [Any] = {
    var tests: [Any] = [("testInvalidResponse", testInvalidResponse), ("testValidDataResponse", testValidDataResponse),
                        ("testNetworkFailure", testNetworkFailure)]

    if #available(iOS 15, *) {
      tests.append(contentsOf: [("testAsync", testAsync), ("testAsyncDecodable", testAsyncDecodable),
                                ("testAsyncSerializable", testAsyncSerializable)])
    }
    return tests
  }()

  private let testTimeout: TimeInterval = 1
  private var webService: WebService!

  private enum Response {
    static let invalid = URLResponse(url: WebServiceTests.baseURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    static let valid = HTTPURLResponse(url: WebServiceTests.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    static let invalid300 = HTTPURLResponse(url: WebServiceTests.baseURL, statusCode: 300, httpVersion: nil, headerFields: nil)!
    static let invalid401 = HTTPURLResponse(url: WebServiceTests.baseURL, statusCode: 401, httpVersion: nil, headerFields: nil)!
  }

  private let networkError = NSError(domain: "NSURLErrorDomain", code: -1004, /* kCFURLErrorCannotConnectToHost*/ userInfo: nil)

  override func setUpWithError() throws {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]

    // and create the URLSession from that
    let session = URLSession(configuration: config)
    webService = WebService(session: session)
  }

  override func tearDownWithError() throws {
    webService = nil
  }

  func testValidResponse() throws {
    let request = URLRequest(url: Self.baseURL)
      .setMethod(.get)
    let requestURL = request.url
    XCTAssertNotNil(requestURL)
    MockURLProtocol.requestHandlers[requestURL!] = { request in
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
    MockURLProtocol.requestHandlers[requestURL!] = { request in
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
    MockURLProtocol.requestHandlers[requestURL!] = { request in
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
    MockURLProtocol.requestHandlers[requestURL!] = { request in
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

  private func evalValidResponseTest(publisher: (some Publisher)?) -> (expectations: [XCTestExpectation], cancellable: AnyCancellable?) {
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

  private func evalInvalidResponseTest(publisher: (some Publisher)?) -> (expectations: [XCTestExpectation], cancellable: AnyCancellable?) {
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
  @available(iOS 15, *)
  func testAsync() async throws {
    let request = URLRequest(url: Self.baseURL)
    let requestURL = request.url
    XCTAssertNotNil(requestURL)
    MockURLProtocol.requestHandlers[requestURL!] = { request in
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

  @available(iOS 15, *)
  func testAsyncDecodable() async throws {
    let data = try Bundle.module.data(forResource: "Response", withExtension: "json", subdirectory: "TestData")
    XCTAssertNotNil(data)
    let request = URLRequest(url: Self.baseURL)
      .setMethod(.get)
    let requestURL = request.url
    XCTAssertNotNil(requestURL)
    MockURLProtocol.requestHandlers[requestURL!] = { request in
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

  @available(iOS 15, *)
  func testAsyncSerializable() async throws {
    let data = try Bundle.module.data(forResource: "Response", withExtension: "json", subdirectory: "TestData")
    XCTAssertNotNil(data)
    let request = URLRequest(url: Self.baseURL)
      .setMethod(.get)
    let requestURL = request.url
    XCTAssertNotNil(requestURL)
    MockURLProtocol.requestHandlers[requestURL!] = { request in
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
