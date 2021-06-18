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
            throw URLError(.zeroByteResource)
        }
        return self
    }
    
    func ws_validate(_ response: URLResponse, acceptableStatusCodes: Range<Int> = 200 ..< 300) throws -> Self {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
            let errorCode = URLError.Code(rawValue: httpResponse.statusCode)
            throw URLError(errorCode)
        }
        
        return self
    }
    
    func ws_validate(_ response: URLResponse, acceptableContentTypes: [String]) throws -> Self {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard let contentType = httpResponse.allHeaderFields[Request.Header.contentType] as? String, acceptableContentTypes.contains(contentType) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return self
    }
    
    internal static func ws_validate(_ data: Data, _ response: URLResponse) throws -> Self {
        return try data.ws_validate(response, acceptableStatusCodes: 200 ..< 300).ws_validate()
    }
}
