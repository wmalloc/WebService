//
//  Request.swift
//  Webservice
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation
import os.log

public protocol URLRequestable {
	func url() throws -> URL
	func urlRequest() throws -> URLRequest
}

public typealias QueryParameterEncoder = (_ url: URL?, _ parameters: [String: Any]) -> URL?

public struct Request {
	public enum ParameterEncoding: CustomStringConvertible, CustomDebugStringConvertible, CaseIterable, Hashable {
		case percent
		case json

		public func encodeURL(_ url: URL, parameters: [String: Any]) -> URL? {
			switch self {
			case .percent:
				return url.ws_URLByAppendingQueryItems(parameters.ws_queryItems)
			case .json:
				assertionFailure("Cannot encode URL parameters using JSON encoding")
				return nil
			}
		}

		public func encodeBody(_ parameters: [String: Any], allowedCharacters: CharacterSet? = nil) -> Data? {
			switch self {
			case .percent:
				return parameters.ws_percentEncodedQueryString(with: allowedCharacters)?.data(using: .utf8, allowLossyConversion: false)
			case .json:
				return try? JSONSerialization.data(withJSONObject: parameters, options: [])
			}
		}

		public var description: String {
			switch self {
			case .json:
				return "JSON"
			case .percent:
				return "PERCENT"
			}
		}

		public var debugDescription: String {
			description
		}
	}
    
	public let method: HTTPMethod
	public let requestURL: URL
	public var urlString: String {
		requestURL.absoluteString
	}

	public var body: Data?
	public var shouldHandleCookies: Bool = true
	public var parameters: [String: Any] = [:]
	public var queryParameters: [String: Any]?
	public var queryItems: [URLQueryItem]?
	public var formParameters: [String: Any]? {
		didSet {
			if let formData = formParameters?.ws_percentEncodedData(with: formParametersAllowedCharacters) {
				body = formData
                contentType = URLRequest.ContentType.formEncoded
			}
		}
	}

	public var queryParameterEncoder: QueryParameterEncoder = { url, parameters -> URL? in
		url?.ws_URLByAppendingQueryItems(parameters.ws_queryItems)
	}

	public var formParametersAllowedCharacters: CharacterSet?
	public var headers: Set<HTTPHeader> = []
	public var cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
	public var timeoutInterval: TimeInterval = 10.0
	public var parameterEncoding = ParameterEncoding.percent {
		didSet {
			if parameterEncoding == .json {
                contentType = URLRequest.ContentType.json
			}
		}
	}

	public var contentType: String? {
		get {
			let header = headers.first { header in
                header.name == URLRequest.Header.contentType
			}
			return header?.value
		}
		set {
			guard let contentType = newValue else {
				if let existing = headers.first(where: { header in
                    header.name == URLRequest.Header.contentType
				}) {
					headers.remove(existing)
				}
				return
			}
            let header = HTTPHeader(name: URLRequest.Header.contentType, value: contentType)
			headers.insert(header)
		}
	}

	var userAgent: String? {
		get {
			let header = headers.first { header in
                header.name == URLRequest.Header.userAgent
			}
			return header?.value
		}
		set {
			guard let userAgent = newValue else {
				if let existing = headers.first(where: { header in
                    header.name == URLRequest.Header.userAgent
				}) {
					headers.remove(existing)
				}
				return
			}

            let header = HTTPHeader(name: URLRequest.Header.userAgent, value: userAgent)
			headers.insert(header)
		}
	}

	public init(_ method: HTTPMethod, url: URL) {
		self.method = method
		self.requestURL = url
	}

	public init(_ method: HTTPMethod, urlString: String) {
		let aURL = URL(string: urlString)!
		self.init(method, url: aURL)
	}
}

extension Request: URLRequestable {
	public func url() throws -> URL {
		guard var urlComponents = URLComponents(string: urlString) else {
			throw URLError(.badURL)
		}

		urlComponents = urlComponents.appendQueryItems(queryItems ?? [])
		guard let url = urlComponents.url else {
			throw URLError(.badURL)
		}
		return url
	}

	public func urlRequest() throws -> URLRequest {
		let requestURL = try url()
		var urlRequest = URLRequest(url: requestURL)
			.setHttpMethod(method)
			.setCachePolicy(cachePolicy)
			.setTimeoutInterval(timeoutInterval)
			.setHttpShouldHandleCookies(shouldHandleCookies)
			.setHttpHeaders(headers)

		if !parameters.isEmpty {
			if method.shouldEncodeParametersInURL {
				if let encodedURL = queryParameterEncoder(urlRequest.url, parameters) {
					urlRequest.url = encodedURL
				}
			} else {
				if let data = parameterEncoding.encodeBody(parameters) {
					urlRequest.httpBody = data

                    if urlRequest.value(forHTTPHeaderField: URLRequest.Header.contentType) == nil {
                        urlRequest.setValue(URLRequest.ContentType.formEncoded, forHTTPHeaderField: URLRequest.Header.contentType)
					}
				}
			}
		}

		if let body = body {
			urlRequest.httpBody = body
		}

		if let queryParameters = queryParameters, let encodedURL = queryParameterEncoder(urlRequest.url, queryParameters) {
			urlRequest.url = encodedURL
		}

		return urlRequest
	}
}

extension Request: CustomStringConvertible {
	public var description: String {
		"{" +
			"\nurl = " + urlString +
			"\nmethod = " + method.rawValue +
			"\nheaders = \(headers)" +
			"\nparameters = \(parameters)" +
			"\ntimeoutInterval = \(timeoutInterval)" +
			"\nqueryParameters = \(String(describing: queryParameters))" +
			"\nqueryItems = \(String(describing: queryItems))" +
			"\nformParameters = \(String(describing: formParameters))" +
			"\nuserAgent = \(String(describing: userAgent))" +
			"\n}"
	}
}

extension Request: CustomDebugStringConvertible {
	public var debugDescription: String {
		"{" +
			"\nurl = " + urlString +
			"\nmethod = " + method.rawValue +
			"\nheaders = \(headers)" +
			"\nparameters = \(parameters)" +
			"\ntimeoutInterval = \(timeoutInterval)" +
			"\nqueryParameters = \(String(describing: queryParameters))" +
			"\nqueryItems = \(String(describing: queryItems))" +
			"\nformParameters = \(String(describing: formParameters))" +
			"\nuserAgent = \(String(describing: userAgent))" +
			"\nshouldHandleCookies = \(shouldHandleCookies)" +
			"\nformParametersAllowedCharacters = \(String(describing: formParametersAllowedCharacters))" +
			"\ncachePolicy = \(cachePolicy)" +
			"\nparameterEncoding = \(parameterEncoding)" +
			"\n}"
	}
}
