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
    static var response: URLResponse?
    static var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canInit(with task: URLSessionTask) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
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

        guard let data = URLProtocolMock.testData[url] else {
            XCTFail("No data for URL \(url.absoluteString)")
            client.urlProtocol(self, didFailWithError: URLError(.zeroByteResource))
            client.urlProtocolDidFinishLoading(self)
            return
        }

        client.urlProtocol(self, didLoad: data)
        if let response = Self.response {
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = Self.error {
            client.urlProtocol(self, didFailWithError: error)
        }

        client.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
