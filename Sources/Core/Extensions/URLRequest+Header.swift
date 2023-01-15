//
//  URLRequest+Header.swift
//
//  Created by Waqar Malik on 4/15/22.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public extension URLRequest {
	enum Header {
		public static let accept = "Accept"
		public static let authorization = "Authorization"
		public static let acceptCharset = "Accept-Charset"
		public static let acceptEncoding = "Accept-Encoding"
		public static let acceptLanguage = "Accept-Language"
		public static let cacheControl = "Cache-Control"
		public static let contentDisposition = "Content-Disposition"
		public static let contentEncoding = "Content-Encoding"
		public static let contentLength = "Content-Length"
		public static let contentType = "Content-Type"
		public static let date = "Date"
		public static let userAgent = "User-Agent"
		public static let userAuthorization = "User-Authorization"
		public static let xAPIKey = "x-api-key"
	}
}
