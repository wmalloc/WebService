//
//  URLProtocolMock.swift
//  WebServiceTests
//
//  Created by Waqar Malik on 6/21/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation
import XCTest

class URLProtocolMock: URLProtocol {
    static var testData: [URL: Data] = [:]
    static var responses: [URL: URLResponse] = [:]
    static var error: Error?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canInit(with task: URLSessionTask) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    static func loadTestData(name: String, withExtension: String) throws {
        let bundle = Bundle(for: URLProtocolMock.self)
        guard let url = bundle.url(forResource: name, withExtension: withExtension) else {
            throw URLError(.unsupportedURL)
        }
        let data = try Data(contentsOf: url, options: [])
        testData[url] = data
    }

    override func startLoading() {
        guard let client = self.client else {
            XCTFail("missing client")
            return
        }

        guard let url = request.url else {
            XCTFail("Request URL missing")
            client.urlProtocol(self, didFailWithError: URLError(.badURL))
            client.urlProtocolDidFinishLoading(self)
            return
        }
        
        if let data = URLProtocolMock.testData[url] {
            client.urlProtocol(self, didLoad: data)
        } else if let response = Self.responses[url] {
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        } else {
            XCTFail("No data for URL \(url.absoluteString)")
            client.urlProtocol(self, didFailWithError: URLError(.zeroByteResource))
            client.urlProtocolDidFinishLoading(self)
            return
        }

        

        if let error = Self.error {
            client.urlProtocol(self, didFailWithError: error)
        }

        client.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
