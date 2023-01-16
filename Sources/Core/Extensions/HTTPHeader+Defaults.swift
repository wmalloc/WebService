//
//  File.swift
//
//
//  Created by Waqar Malik on 1/15/23.
//

import Foundation

public extension HTTPHeader {
	static var defaultUserAgent: HTTPHeader = buildUserAgent()

	static var defaultAcceptLanguage: HTTPHeader {
		.acceptLanguage(Locale.preferredLanguages.prefix(6).ws_qualityEncoded())
	}

	static var defaultAcceptEncoding: HTTPHeader {
		.acceptEncoding(["br", "gzip", "deflate"].ws_qualityEncoded())
	}
}
