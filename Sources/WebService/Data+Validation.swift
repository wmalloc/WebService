//
//  Data+Validation.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

public extension Data {
    func ws_validate() throws -> Self {
        guard !isEmpty else {
            throw WebServiceError.invalidBody
        }
        return self
    }
    
    func ws_validate(_ response: URLResponse, acceptableStatusCodes: Range<Int> = 200 ..< 300) throws -> Self {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebServiceError.invalidResponse
        }
        
        guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
            throw WebServiceError.statusCode(httpResponse.statusCode)
        }
        
        return self
    }
    
    func ws_validate(_ response: URLResponse, acceptableContentTypes: [String]) throws -> Self {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebServiceError.invalidResponse
        }
        
        guard let contentType = httpResponse.allHeaderFields[Request.Header.contentType] as? String,
            acceptableContentTypes.contains(contentType) else {
            throw WebServiceError.invalidContentType
        }
        
        return self
    }
    
    internal static func ws_validate(_ data: Data, _ response: URLResponse) throws -> Self {
        return try data.ws_validate(response, acceptableStatusCodes: 200 ..< 300).ws_validate()
    }
}
