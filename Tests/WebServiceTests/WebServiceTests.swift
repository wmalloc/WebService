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
        XCTAssertEqual(try request.urlRequest(), URLRequest(url: baseURL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0))
    }

    func testQueryItems() throws {
        let baseURLString = webService.baseURLString
        var request = Request(.GET, urlString: baseURLString)
        request = request.setQueryItems([URLQueryItem(name: "test1", value: "test1"), URLQueryItem(name: "test2", value: "test2")])
        XCTAssertNotNil(request.queryItems)
        XCTAssertEqual(request.queryItems?.count ?? 0, 2)
        XCTAssertEqual(try request.urlRequest().url?.absoluteString, "https://localhost:8080?test1=test1&test2=test2")
        request = request.appendQueryItems([URLQueryItem(name: "test3", value: "test3")])
        XCTAssertEqual(request.queryItems?.count ?? 0, 3)
        XCTAssertEqual(try request.urlRequest().url?.absoluteString, "https://localhost:8080?test1=test1&test2=test2&test3=test3")
        request = request.setQueryItems([])
        XCTAssertEqual(request.queryItems?.count ?? 0, 0)
        XCTAssertEqual(try request.urlRequest().url?.absoluteString, "https://localhost:8080")
        request = request.setQueryItems([URLQueryItem(name: "test 3", value: "test 3")])
        XCTAssertEqual(request.queryItems?.count ?? 0, 1)
        XCTAssertEqual(try request.urlRequest().url?.absoluteString, "https://localhost:8080?test%203=test%203")
    }

    func testDefaultRequestConfigurations() throws {
        let baseURLString = webService.baseURLString
        var request = Request(.GET, urlString: baseURLString)
        request.setCachePolicy(.reloadIgnoringLocalCacheData)
        XCTAssertEqual(request.cachePolicy, NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData)
        request.setContentType(Request.ContentType.json)
        XCTAssertEqual(request.headers[Request.Header.contentType], Request.ContentType.json)
        XCTAssertEqual(request.headers.count, 1)
    }
    
    func testExample() throws {
        // XCTAssertEqual(WebService().text, "Hello, World!")
    }

    func testValidResponse() throws {
        let request = Request(.GET, urlString: webService.baseURLString)
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
        let request = Request(.GET, urlString: webService.baseURLString)
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
        let request = Request(.GET, urlString: webService.baseURLString)
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
        let request = Request(.GET, urlString: webService.baseURLString)
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
                break
            }
            finished.fulfill()
        }, receiveValue: { response in
            XCTAssertNotNil(response)
            os_log(.info, log: OSLog.tests, "%@", "\(response)")
        })
        return (expectations: [finished], cancellable: cancellable)
    }
}
