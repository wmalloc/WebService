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

import MockURLProtocol
@testable import WebService
import XCTest

final class WebServiceTests: XCTestCase, @unchecked Sendable {
  private static let baseURLString = "http://localhost:8080"
  private static let baseURL = URL(string: "http://localhost:8080")!

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

  func testValidResponse() async throws {
    let request = URLRequest(url: Self.baseURL)
      .setMethod(.get)
    let requestURL = request.url
    XCTAssertNotNil(requestURL)
    try await MockURLProtocol.setRequestHandler({ request in
      guard let url = request.url, url == requestURL else {
        throw URLError(.badURL)
      }

      return (Data(), Response.valid)

    }, forIdentifier: request)

    let publisher = webService.dataPublisher(for: request)
    let validTest = evalValidResponseTest(publisher: publisher)
    await fulfillment(of: validTest.expectations, timeout: testTimeout, enforceOrder: true)
    validTest.cancellable?.cancel()
  }

  func testInvalidResponse() async throws {
    let request = URLRequest(url: Self.baseURL)
      .setMethod(.get)
    let requestURL = request.url
    XCTAssertNotNil(requestURL)
    try await MockURLProtocol.setRequestHandler({ request in
      guard let url = request.url, url == requestURL else {
        throw URLError(.badURL)
      }

      return (Data(), Response.invalid401)

    }, forIdentifier: request)
    let publisher = webService.dataPublisher(for: request)
    let invalidTest = evalInvalidResponseTest(publisher: publisher)
    await fulfillment(of: invalidTest.expectations, timeout: testTimeout, enforceOrder: true)
    invalidTest.cancellable?.cancel()
  }

  func testValidDataResponse() async throws {
    let request = URLRequest(url: Self.baseURL)
      .setMethod(.get)
    let requestURL = request.url
    XCTAssertNotNil(requestURL)
    try await MockURLProtocol.setRequestHandler({ request in
      guard let url = request.url, url == requestURL else {
        throw URLError(.badURL)
      }

      let data = Data("{}".utf8)
      return (data, Response.valid)
    }, forIdentifier: request)
    let publisher = webService.dataPublisher(for: request)
    let invalidTest = evalValidResponseTest(publisher: publisher)
    await fulfillment(of: invalidTest.expectations, timeout: testTimeout, enforceOrder: true)
    invalidTest.cancellable?.cancel()
  }

  func testNetworkFailure() async throws {
    let request = URLRequest(url: Self.baseURL)
      .setMethod(.get)

    let requestURL = request.url
    XCTAssertNotNil(requestURL)
    try await MockURLProtocol.setRequestHandler({ request in
      guard let url = request.url, url == requestURL else {
        throw URLError(.badURL)
      }

      let data = Data("{}".utf8)
      return (data, Response.invalid401)
    }, forIdentifier: request)
    let publisher = webService.dataPublisher(for: request)
    let invalidTest = evalValidResponseTest(publisher: publisher)
    await fulfillment(of: invalidTest.expectations, timeout: testTimeout, enforceOrder: true)
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
    try await MockURLProtocol.setRequestHandler({ request in
      guard let url = request.url, url == requestURL else {
        throw URLError(.badURL)
      }
      return (Data(), Response.valid)
    }, forIdentifier: request)

    let (data, _) = try await webService.session.data(for: request, delegate: nil)
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
    let request = URLRequest(url: Self.baseURL)
      .setMethod(.get)
    let requestURL = request.url
    XCTAssertNotNil(requestURL)
    try await MockURLProtocol.setRequestHandler({ request in
      guard let url = request.url, url == requestURL else {
        throw URLError(.badURL)
      }
      let responseData = try Bundle.module.data(forResource: "Response", withExtension: "json", subdirectory: "TestData")
      XCTAssertNotNil(responseData)
      return (responseData, Response.valid)
    }, forIdentifier: request)

    let (rawData, _) = try await webService.session.data(for: request, delegate: nil)
    let decoded: [String: String] = try JSONDecoder().decode([String: String].self, from: rawData)
    XCTAssertEqual(decoded.count, 2)
    XCTAssertEqual(decoded["key1"], "value1")
    XCTAssertEqual(decoded["key2"], "value2")
    XCTAssertEqual(decoded["key3"], nil)
  }
}
