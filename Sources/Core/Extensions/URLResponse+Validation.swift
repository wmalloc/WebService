//
//  URLResponse+Validation.swift
//
//  Created by Waqar Malik on 3/3/22.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public extension URLResponse {
	@discardableResult
	func ws_validate(acceptableStatusCodes: Range<Int> = 200 ..< 300, acceptableContentTypes: Set<String>? = nil) throws -> Self {
		guard let httpResponse = self as? HTTPURLResponse else {
			throw URLError(.badServerResponse)
		}
		try httpResponse.ws_httpValidate(acceptableStatusCodes: acceptableStatusCodes, acceptableContentTypes: acceptableContentTypes)
		return self
	}
}
