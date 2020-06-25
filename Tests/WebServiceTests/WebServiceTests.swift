//
//  WebServiceTests.swift
//  WebServiceTests
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Combine
import os.log
@testable import WebService
import XCTest

final class WebServiceTests: XCTestCase {
    static var allTests = [("testExample", testExample)]
    let testTimeout: TimeInterval = 1
    var webService: WebService!
    
    enum Response {
        static let invalid = URLResponse(url: URL(string: "http://localhost:8080")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        static let valid = HTTPURLResponse(url: URL(string: "http://localhost:8080")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        static let invalid300 = HTTPURLResponse(url: URL(string: "http://localhost:8080")!, statusCode: 300, httpVersion: nil, headerFields: nil)
        static let invalid401 = HTTPURLResponse(url: URL(string: "http://localhost:8080")!, statusCode: 401, httpVersion: nil, headerFields: nil)
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
        URLProtocolMock.error = nil
        URLProtocolMock.response = nil
        URLProtocolMock.testData = [:]
        webService = nil
    }
    
    func testBaseURL() {
        let baseURLString = "https://localhost:8080"
        let baseURL = URL(string: baseURLString)
        XCTAssertEqual(webService.baseURLString, baseURLString)
        XCTAssertNotNil(webService.baseURL)
        XCTAssertEqual(webService.baseURL, baseURL)
    }

    func testDefaultRequest() {
        let baseURLString = webService.baseURLString
        let baseURL = webService.baseURL
        let request = Request(.GET, urlString: baseURLString)
        XCTAssertEqual(request.urlString, baseURLString)
        XCTAssertEqual(request.requestURL, baseURL)
        XCTAssertNil(request.headers[Request.Header.contentType])
        XCTAssertNil(request.headers[Request.Header.cacheControl])
        XCTAssertEqual(request.headers.count, 0)
        XCTAssertNil(request.body)
        XCTAssertTrue(request.shouldHandleCookies)
        XCTAssertEqual(request.parameters.count, 0)
        XCTAssertNil(request.queryParameters)
        XCTAssertNil(request.queryItems)
        XCTAssertNil(request.formParameters)
        XCTAssertNil(request.formParametersAllowedCharacters)
        XCTAssertEqual(request.cachePolicy, NSURLRequest.CachePolicy.useProtocolCachePolicy)
        XCTAssertEqual(request.parameterEncoding, Request.ParameterEncoding.percent)
        XCTAssertEqual(request.timeoutInterval, 10.0)
    
        XCTAssertNil(request.contentType)
        XCTAssertNil(request.userAgent)
        XCTAssertEqual(request.urlRequest, URLRequest(url: baseURL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0))
    }
    
    func testDefaultRequestConfigurations() {
        let baseURLString = webService.baseURLString
        var request = Request(.GET, urlString: baseURLString)
        request.setCachePolicy(.reloadIgnoringLocalCacheData)
        XCTAssertEqual(request.cachePolicy, NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData)
        request.setContentType(Request.ContentType.json)
        XCTAssertEqual(request.headers[Request.Header.contentType], Request.ContentType.json)
        XCTAssertEqual(request.headers.count, 1)
    }
    
    func testExample() {
        // XCTAssertEqual(WebService().text, "Hello, World!")
     }

    func testValidResponse() {
        URLProtocolMock.response = Response.valid
        let publisher = webService.servicePublisher(request: Request(.GET, urlString: webService.baseURLString))
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: testTimeout)
        validTest.cancellable?.cancel()
    }
    
    func testInvalidResponse() {
        URLProtocolMock.response = Response.invalid
        let publisher = webService.servicePublisher(request: Request(.GET, urlString: webService.baseURLString))
        let invalidTest = evalInvalidResponseTest(publisher: publisher)
        wait(for: invalidTest.expectations, timeout: testTimeout)
        invalidTest.cancellable?.cancel()
    }
    
    func testValidDataResponse() {
        let testURL = webService.baseURL!
        URLProtocolMock.testData[testURL] = Data("{{}".utf8)
        URLProtocolMock.response = Response.valid
        
        let publisher = webService.servicePublisher(request: Request(.GET, urlString: webService.baseURLString))
        let invalidTest = evalInvalidResponseTest(publisher: publisher)
        wait(for: invalidTest.expectations, timeout: testTimeout)
        invalidTest.cancellable?.cancel()
    }
    
    func testNetworkFailure() {
        URLProtocolMock.response = Response.valid
        URLProtocolMock.error = networkError
        
        let publisher = webService.servicePublisher(request: Request(.GET, urlString: webService.baseURLString))
        let invalidTest = evalInvalidResponseTest(publisher: publisher)
        wait(for: invalidTest.expectations, timeout: testTimeout)
        invalidTest.cancellable?.cancel()
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func evalValidResponseTest<P: Publisher>(publisher: P?) -> (expectations: [XCTestExpectation], cancellable: AnyCancellable?) {
        XCTAssertNotNil(publisher)
        
        let expectationFinished = expectation(description: "finished")
        let expectationReceive = expectation(description: "receiveValue")
        let expectationFailure = expectation(description: "failure")
        expectationFailure.isInverted = true
        
        let cancellable = publisher?.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                os_log(.error, log: OSLog.tests, "TEST ERROR %@", error.localizedDescription)
                expectationFailure.fulfill()
            case .finished:
                expectationFinished.fulfill()
            }
        }, receiveValue: { response in
            XCTAssertNotNil(response)
            os_log(.info, log: OSLog.tests, "%@", "\(response)")
            expectationReceive.fulfill()
        })
        return (expectations: [expectationFinished, expectationReceive, expectationFailure], cancellable: cancellable)
    }
    
    func evalInvalidResponseTest<P: Publisher>(publisher: P?) -> (expectations: [XCTestExpectation], cancellable: AnyCancellable?) {
        XCTAssertNotNil(publisher)
        
        let expectationFinished = expectation(description: "Invalid.finished")
        expectationFinished.isInverted = true
        let expectationReceive = expectation(description: "Invalid.receiveValue")
        expectationReceive.isInverted = true
        let expectationFailure = expectation(description: "Invalid.failure")
        
        let cancellable = publisher?.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                os_log(.error, log: OSLog.tests, "TEST FULFILLED %@", error.localizedDescription)
                expectationFailure.fulfill()
            case .finished:
                expectationFinished.fulfill()
            }
        }, receiveValue: { response in
            XCTAssertNotNil(response)
            os_log(.info, log: OSLog.tests, "%@", "\(response)")
            expectationReceive.fulfill()
        })
        return (expectations: [expectationFinished, expectationReceive, expectationFailure], cancellable: cancellable)
    }
}
