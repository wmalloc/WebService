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
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canInit(with task: URLSessionTask) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    static func loadTestData(name: String, withExtension: String) throws -> Data {
        let bundle = Bundle(for: URLProtocolMock.self)
        guard let url = bundle.url(forResource: name, withExtension: withExtension) else {
            throw URLError(.unsupportedURL)
        }
        let data = try Data(contentsOf: url, options: [])
        return data
    }

    override func startLoading() {
        guard let client = self.client else {
            fatalError("missing client")
        }

        guard let handler = Self.requestHandler else {
            fatalError("Handler is unavailable.")
        }

        let validCodes = Set(200..<300)
        do {
            let (response, data) = try handler(request)
            if !validCodes.contains(response.statusCode) {
                throw URLError(URLError.Code(rawValue: response.statusCode))
            }
            
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client.urlProtocol(self, didLoad: data)
            }
            
            client.urlProtocolDidFinishLoading(self)
        } catch {
            client.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {}
}
