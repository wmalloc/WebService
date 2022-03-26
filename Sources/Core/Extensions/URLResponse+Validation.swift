//
//  File.swift
//
//
//  Created by Waqar Malik on 3/3/22.
//

import Foundation

public extension URLResponse {
	func ws_validate(acceptableStatusCodes: Range<Int> = 200 ..< 300, acceptableContentTypes: Set<String>? = nil) throws -> Self {
		guard let httpResponse = self as? HTTPURLResponse else {
			throw URLError(.badServerResponse)
		}
		_ = try httpResponse.ws_httpValidate(acceptableStatusCodes: acceptableStatusCodes, acceptableContentTypes: acceptableContentTypes)
		return self
	}
}