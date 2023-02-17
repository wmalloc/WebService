//
//  HTTPHeader+Standard.swift
//
//  Created by Waqar Malik on 1/14/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public extension HTTPHeader {
	static func accept(_ value: String) -> Self {
		HTTPHeader(name: URLRequest.Header.accept, value: value)
	}

	static func acceptCharset(_ value: String) -> Self {
		HTTPHeader(name: URLRequest.Header.acceptCharset, value: value)
	}

	static func acceptLanguage(_ value: String) -> Self {
		HTTPHeader(name: URLRequest.Header.acceptLanguage, value: value)
	}

	static func acceptEncoding(_ value: String) -> Self {
		HTTPHeader(name: URLRequest.Header.acceptEncoding, value: value)
	}

	static func authorization(_ value: String) -> Self {
		HTTPHeader(name: URLRequest.Header.authorization, value: value)
	}

	static func authorization(token: String) -> Self {
		authorization("Bearer \(token)")
	}

	static func contentType(_ value: String) -> Self {
		HTTPHeader(name: URLRequest.Header.contentType, value: value)
	}

	static func userAgent(_ value: String) -> Self {
		HTTPHeader(name: URLRequest.Header.userAgent, value: value)
	}

	static func contentDisposition(_ value: String) -> HTTPHeader {
		HTTPHeader(name: URLRequest.Header.contentDisposition, value: value)
	}
}
