//
//  URLRequest+Builder.swift
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public extension URLRequest {
	@discardableResult
	func setCachePolicy(_ cachePolicy: URLRequest.CachePolicy) -> Self {
		var request = self
		request.cachePolicy = cachePolicy
		return request
	}

	@discardableResult
	func setHttpMethod(_ httpMethod: String?) -> Self {
		var request = self
		request.httpMethod = httpMethod
		return request
	}

	@discardableResult
	func setUrl(_ url: URL?) -> Self {
		var request = self
		request.url = url
		return request
	}

	@discardableResult
	func setMaindocumentURL(_ maindocumentURL: URL?) -> Self {
		var request = self
		request.mainDocumentURL = maindocumentURL
		return request
	}

	@discardableResult
	func setHttpBody(_ httpBody: Data?, contentType: String? = nil) -> Self {
		var request = self
		if let contentType = contentType {
			request.setValue(contentType, forHTTPHeaderField: URLRequest.Header.contentType)
		}
		request.httpBody = httpBody
		request.setValue("\(httpBody?.count ?? 0)", forHTTPHeaderField: URLRequest.Header.contentLength)
		return request
	}

	@discardableResult
	func setHttpBodyStream(_ httpBodyStream: InputStream?) -> Self {
		var request = self
		request.httpBodyStream = httpBodyStream
		return request
	}

	@discardableResult
	func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
		var request = self
		request.timeoutInterval = timeoutInterval
		return request
	}

	@discardableResult
	func setHttpHeader(_ value: String?, forName name: String) -> Self {
		var request = self
		request.setValue(value, forHTTPHeaderField: name)
		return request
	}

	@discardableResult
	func setHttpHeaders(_ httpHeaders: [String: String]) -> Self {
		var request = self
		request.allHTTPHeaderFields = httpHeaders
		return request
	}

	@discardableResult
	func addHttpHeader(_ value: String, forName name: String) -> Self {
		var request = self
		request.addValue(value, forHTTPHeaderField: name)
		return request
	}

	@discardableResult
	func setHttpShouldHandleCookies(_ httpShouldHandleCookies: Bool) -> Self {
		var request = self
		request.httpShouldHandleCookies = httpShouldHandleCookies
		return request
	}

	@available(macOS 10.15, iOS 13, *)
	@discardableResult
	func setHttpShouldUsePipelining(_ httpShouldUsePipelining: Bool) -> Self {
		var request = self
		request.httpShouldUsePipelining = httpShouldUsePipelining
		return request
	}

	@available(macOS 10.15, iOS 13, *)
	@discardableResult
	func setAllowsCellularAccess(_ allowsCellularAccess: Bool) -> Self {
		var request = self
		request.allowsCellularAccess = allowsCellularAccess
		return request
	}

	@discardableResult
	func setAllowsConstraintNetworkAccess(_ allowsConstraintNetworkAccess: Bool) -> Self {
		var request = self
		request.allowsConstrainedNetworkAccess = allowsConstraintNetworkAccess
		return request
	}

	@discardableResult
	func setAllowsExpensiveNetworkAccess(_ allowsExpensiveNetworkAccess: Bool) -> Self {
		var request = self
		request.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
		return request
	}

	@available(macOS 10.15, iOS 13, *)
	@discardableResult
	func setNetworkServiceType(_ networkServiceType: URLRequest.NetworkServiceType) -> Self {
		var request = self
		request.networkServiceType = networkServiceType
		return request
	}

	@available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *)
	@discardableResult
	func setAssumesHTTP3Capable(_ assumesHTTP3Capable: Bool) -> Self {
		var request = self
		request.assumesHTTP3Capable = assumesHTTP3Capable
		return request
	}
}

@available(iOS 15, tvOS 15, macOS 12, watchOS 8, macCatalyst 15, *)
public extension URLRequest {
	func setAttribution(_ attribution: URLRequest.Attribution) -> Self {
		var request = self
		request.attribution = attribution
		return request
	}
}

public extension URLRequest {
	@discardableResult
	func setContentType(_ contentType: String) -> Self {
		setHeader(.contentType(contentType))
	}

	@discardableResult
	func setUserAgent(_ userAgent: String) -> Self {
		setHeader(.userAgent(userAgent))
	}

	@discardableResult
	func setMethod(_ method: HTTPMethod?) -> Self {
		setHttpMethod(method?.rawValue)
	}

	@discardableResult
	func setHeader(_ header: HTTPHeader?) -> Self {
		guard let header else {
			return self
		}
		return setHttpHeader(header.value, forName: header.name)
	}

	@discardableResult
	func setHttpHeaders(_ httpHeaders: HTTPHeaders?) -> Self {
		var request = self
		request.headers = httpHeaders
		return request
	}

	@discardableResult
	func setHeaders(_ headers: [HTTPHeader]?) -> Self {
		guard let headers else {
			return setHttpHeaders(nil)
		}
		return setHttpHeaders(HTTPHeaders(headers))
	}

	@discardableResult
	func addHeader(_ header: HTTPHeader) -> Self {
		addHttpHeader(header.value, forName: header.name)
	}

	@discardableResult
	func addHeaders(_ headers: HTTPHeaders) -> Self {
		addHeaders(headers.headers)
	}

	@discardableResult
	func addHeaders(_ headers: [HTTPHeader]) -> Self {
		var request = self
		for header in headers {
			request.addValue(header.value, forHTTPHeaderField: header.name)
		}
		return request
	}
}
