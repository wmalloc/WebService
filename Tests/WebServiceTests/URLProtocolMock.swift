//
//  URLProtocolMock.swift
//  WebServiceTests
//
//  Created by Waqar Malik on 6/21/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

class URLProtocolMock: URLProtocol {
    static var testData: [URL: Data] = [:]
    static var response: URLResponse?
    static var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canInit(with task: URLSessionTask) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        if let url = request.url, let data = Self.testData[url] {
            self.client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = Self.response {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = Self.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
