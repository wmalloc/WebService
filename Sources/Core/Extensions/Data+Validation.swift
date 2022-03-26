//
//  Data+Validation.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation
import os.log

public extension Data {
	func ws_validateNotEmptyData() throws -> Self {
		guard !isEmpty else {
			throw URLError(.zeroByteResource)
		}
		return self
	}

	func ws_validate(_ response: URLResponse, acceptableStatusCodes: Range<Int> = 200 ..< 300, acceptableContentTypes: Set<String>? = nil) throws -> Self {
        do {
            _ = try response.ws_validate(acceptableStatusCodes: acceptableStatusCodes, acceptableContentTypes: acceptableContentTypes)
        } catch {
            let errorResponse = String(data: self, encoding: .utf8)
            os_log("Error Response = %@", errorResponse ?? "")
            throw error
        }
		return self
	}

	internal static func ws_validate(_ data: Data, _ response: URLResponse, acceptableContentTypes: Set<String>? = nil) throws -> Self {
		try data.ws_validate(response, acceptableStatusCodes: 200 ..< 300, acceptableContentTypes: acceptableContentTypes).ws_validateNotEmptyData()
	}
}