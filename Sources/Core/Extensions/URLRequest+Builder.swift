//
//  URLRequest+Builder.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

public extension URLRequest {
    @discardableResult
    func setContentType(_ contentType: String) -> Self {
        var request = self
        request.contentType = contentType
        return request
    }
    
    @discardableResult
    func setUserAgent(_ userAgent: String) -> Self {
        var request = self
        request.userAgent = userAgent
        return request
    }
    
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
	func setHttpBody(_ httpBody: Data?) -> Self {
		var request = self
		request.httpBody = httpBody
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
	func setHttpHeaders(_ httpHeaders: [String: String]) -> Self {
		var request = self
		request.allHTTPHeaderFields = httpHeaders
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
    func setHttpHeaders(_ httpHeaders: Set<HTTPHeader>) -> Self {
		let mapped: [String: String] = httpHeaders.reduce([:]) { partialResult, header in
			var result = partialResult
			result[header.name] = header.value
			return result
		}
		return setHttpHeaders(mapped)
	}

	@discardableResult
	func setHttpMethod(_ method: HTTPMethod) -> Self {
		var request = self
		request.httpMethod = method.rawValue
		return request
	}
}
