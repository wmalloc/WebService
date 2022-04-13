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
	public enum Method: String, CaseIterable {
		case GET
		case POST
		case PUT
		case PATCH
		case DELETE
		case HEAD
		case OPTIONS
		case TRACE

		var shouldEncodeParametersInURL: Bool {
			switch self {
			case .GET, .HEAD, .DELETE:
				return true
			default:
				return false
			}
		}
	}

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

	public enum Header {
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

	public enum ContentType {
		public static let formEncoded = "application/x-www-form-urlencoded"
		public static let json = "application/json"
		public static let xml = "application/xml"
		public static let textPlain = "text/plain"
		public static let html = "text/html"
		public static let css = "text/css"
		public static let octet = "application/octet-stream"
		public static let jpeg = "image/jpeg"
		public static let png = "image/png"
		public static let gif = "image/gif"
		public static let svg = "image/svg+xml"
		public static let fhirjson = "application/fhir+json"
		public static let patchjson = "application/json-patch+json"
	}

	public struct HTTPHeader: Hashable {
		public let name: String
		public let value: String

		public init(name: String, value: String) {
			self.name = name
			self.value = value
		}
	}

	public let method: Method
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
				contentType = ContentType.formEncoded
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
				contentType = ContentType.json
			}
		}
	}

	public var contentType: String? {
		get {
			let header = headers.first { header in
				header.name == Header.contentType
			}
			return header?.value
		}
		set {
			guard let contentType = newValue else {
				if let existing = headers.first(where: { header in
					header.name == Header.contentType
				}) {
					headers.remove(existing)
				}
				return
			}
			let header = HTTPHeader(name: Header.contentType, value: contentType)
			headers.insert(header)
		}
	}

	var userAgent: String? {
		get {
			let header = headers.first { header in
				header.name == Header.userAgent
			}
			return header?.value
		}
		set {
			guard let userAgent = newValue else {
				if let existing = headers.first(where: { header in
					header.name == Header.userAgent
				}) {
					headers.remove(existing)
				}
				return
			}

			let header = HTTPHeader(name: Header.userAgent, value: userAgent)
			headers.insert(header)
		}
	}

	public init(_ method: Method, url: URL) {
		self.method = method
		self.requestURL = url
	}

	public init(_ method: Method, urlString: String) {
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

					if urlRequest.value(forHTTPHeaderField: Header.contentType) == nil {
						urlRequest.setValue(ContentType.formEncoded, forHTTPHeaderField: Header.contentType)
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

public extension Request {
	@discardableResult
	func setContentType(_ contentType: String?) -> Self {
		var request = self
		request.contentType = contentType
		return request
	}

	@discardableResult
	func setUserAgent(_ userAgent: String?) -> Self {
		var request = self
		request.userAgent = userAgent
		return request
	}

	@discardableResult
	func setShouldHandleCookies(_ handle: Bool) -> Self {
		var request = self
		request.shouldHandleCookies = handle
		return request
	}

	@discardableResult
	func setParameters(_ parameters: [String: Any], encoding: Request.ParameterEncoding? = nil) -> Self {
		guard !parameters.isEmpty else {
			return self
		}
		var request = self
		request.parameters = parameters
		request.parameterEncoding = encoding ?? .percent
		return request
	}

	@discardableResult
	func setBody(_ data: Data?) -> Self {
		guard let data = data else {
			return self
		}

		var request = self
		request.body = data
		return request
	}

	@discardableResult
	func setBody(_ data: Data?, contentType: String) -> Self {
		guard let data = data else {
			return self
		}
		var request = self
		request.body = data
		request.contentType = contentType
		return request
	}

	@discardableResult
	func setJSON(_ json: Any?) -> Self {
		guard let json = json else {
			return self
		}
		var request = self
		request.contentType = Request.ContentType.json
		request.body = try? JSONSerialization.data(withJSONObject: json, options: [])
		return request
	}

	@discardableResult
	func setJSONData(_ json: Data?) -> Self {
		setBody(json, contentType: Request.ContentType.json)
	}

	@discardableResult
	func setHeaders(_ headers: Set<HTTPHeader>?) -> Self {
		guard let headers = headers, !headers.isEmpty else {
			return self
		}
		var request = self
		request.headers = headers
		return request
	}

	@discardableResult
	func updateHeaders(_ headers: Set<HTTPHeader>?) -> Self {
		guard let headers = headers, !headers.isEmpty else {
			return self
		}

		var request = self
		request.headers.formUnion(headers)
		return request
	}

	@discardableResult
	func setHeaderValue(_ value: String, forName name: String) -> Self {
		var request = self
		let httpHeader = HTTPHeader(name: name, value: value)
		request.headers.insert(httpHeader)
		return request
	}

	@discardableResult
	func setCachePolicy(_ cachePolicy: NSURLRequest.CachePolicy) -> Self {
		var request = self
		request.cachePolicy = cachePolicy
		return request
	}

	@discardableResult
	func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
		var request = self
		request.timeoutInterval = timeoutInterval
		return request
	}

	@discardableResult
	func setParameterEncoding(_ encoding: Request.ParameterEncoding) -> Self {
		var request = self
		request.parameterEncoding = encoding
		return request
	}

	@discardableResult
	func setQueryParameters(_ parameters: [String: Any]?) -> Self {
		guard let parameters = parameters else {
			return self
		}
		var request = self
		request.queryParameters = parameters
		return request
	}

	@discardableResult
	func setQueryParameters(_ parameters: [String: Any], encoder: @escaping QueryParameterEncoder) -> Self {
		guard !parameters.isEmpty else {
			return self
		}
		var request = setQueryParameters(parameters)
		request.queryParameterEncoder = encoder
		return request
	}

	@discardableResult
	func setQueryItems(_ queryItems: [URLQueryItem]?) -> Self {
		guard let queryItems = queryItems else {
			return self
		}

		var request = self
		request.queryItems = queryItems
		return request
	}

	@discardableResult
	func appendQueryItems(_ queryItems: [URLQueryItem]?) -> Self {
		guard let queryItems = queryItems else {
			return self
		}

		var existingItems = self.queryItems ?? []
		existingItems.append(contentsOf: queryItems)
		return setQueryItems(existingItems)
	}

	@discardableResult
	func setFormParameters(_ parameters: [String: Any]?) -> Self {
		guard let parameters = parameters else {
			return self
		}

		var request = self
		request.formParameters = parameters
		return request
	}

	@discardableResult
	func setFormParametersAllowedCharacters(_ allowedCharacters: CharacterSet) -> Self {
		var request = self
		request.formParametersAllowedCharacters = allowedCharacters
		return request
	}

	@discardableResult
	func setBody<T: Encodable>(_ body: T, encoder: JSONEncoder = JSONEncoder()) throws -> Self {
		var request = self
		let data = try encoder.encode(body)
		request.body = data
		request.contentType = Request.ContentType.json
		return request
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
