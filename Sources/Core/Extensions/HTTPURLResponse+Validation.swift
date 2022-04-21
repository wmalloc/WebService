//
//  HTTPURLResponse+Validation.swift
//
//
//  Created by Waqar Malik on 3/3/22.
//

import Foundation

public extension HTTPURLResponse {
	@discardableResult
	func ws_httpValidate(acceptableStatusCodes: Range<Int> = 200 ..< 300, acceptableContentTypes: Set<String>? = nil) throws -> Self {
		guard acceptableStatusCodes.contains(statusCode) else {
			let errorCode = URLError.Code(rawValue: statusCode)
			throw URLError(errorCode)
		}

		if let validContentType = acceptableContentTypes {
			if let contentType = allHeaderFields[URLRequest.Header.contentType] as? String {
				if !validContentType.contains(contentType) {
					throw URLError(.dataNotAllowed)
				}
			} else {
				throw URLError(.badServerResponse)
			}
		}

		return self
	}
}
