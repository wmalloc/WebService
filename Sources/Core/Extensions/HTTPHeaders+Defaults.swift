//
//  File.swift
//
//
//  Created by Waqar Malik on 1/15/23.
//

import Foundation

public extension HTTPHeaders {
	static var defaultHeaders: HTTPHeaders {
		HTTPHeaders(arrayLiteral: .defaultUserAgent, .defaultAcceptEncoding, .defaultAcceptLanguage)
	}
}
