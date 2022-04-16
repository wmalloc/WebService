//
//  URLRequest+Header.swift
//
//
//  Created by Waqar Malik on 4/15/22.
//

import Foundation

public extension URLRequest {
    enum Header {
        public static let userAgent = "User-Agent"
        public static let contentType = "Content-Type"
        public static let contentLength = "Content-Length"
        public static let contentEncoding = "Content-Encoding"
        public static let accept = "Accept"
        public static let cacheControl = "Cache-Control"
        public static let authorization = "Authorization"
        public static let acceptEncoding = "Accept-Encoding"
        public static let acceptLanguage = "Accept-Language"
        public static let date = "Date"
        public static let xAPIKey = "x-api-key"
        public static let userAuthorization = "User-Authorization"
    }
}
