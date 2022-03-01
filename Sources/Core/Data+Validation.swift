//
//  Data+Validation.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

public extension Data {
    func ws_validateNotEmptyData() throws -> Self {
        guard !isEmpty else {
            throw URLError(.zeroByteResource)
        }
        return self
    }

    func ws_validate(_ response: URLResponse, acceptableStatusCodes: Range<Int> = 200 ..< 300, acceptableContentTypes: Set<String>? = nil) throws -> Self {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
            let errorCode = URLError.Code(rawValue: httpResponse.statusCode)
            throw URLError(errorCode)
        }

        if let validContentType = acceptableContentTypes {
            if let contentType = httpResponse.allHeaderFields[Request.Header.contentType] as? String {
                if !validContentType.contains(contentType) {
                    throw URLError(.dataNotAllowed)
                }
            } else {
                throw URLError(.badServerResponse)
            }
        }

        return self
    }

    internal static func ws_validate(_ data: Data, _ response: URLResponse, acceptableContentTypes: Set<String>? = nil) throws -> Self {
        return try data.ws_validate(response, acceptableStatusCodes: 200 ..< 300, acceptableContentTypes: acceptableContentTypes).ws_validateNotEmptyData()
    }
}
