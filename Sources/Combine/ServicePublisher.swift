//
//  ServicePublisher.swift
//  Webservice
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Combine
import Foundation
import WebService

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension URLSession {
	func servicePublisher(for url: URL) -> URLSession.ServicePublisher {
		servicePublisher(for: .init(.GET, url: url))
	}

	func servicePublisher(for request: Request) -> URLSession.ServicePublisher {
		.init(request: request, session: self)
	}

	class ServicePublisher: Publisher {
		public typealias Output = DataTaskPublisher.Output
		public typealias Failure = DataTaskPublisher.Failure

		public let session: URLSession
		var dataTaskPublisher: DataTaskPublisher?
		var request: Request

		public init(request: Request, session: URLSession) {
			self.request = request
			self.session = session
		}

		public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == URLSession.ServicePublisher.Failure, S.Input == URLSession.ServicePublisher.Output {
			let theSession = session
			guard let urlRequest = try? request.urlRequest() else {
				return
			}
			dataTaskPublisher = DataTaskPublisher(request: urlRequest, session: theSession)
			dataTaskPublisher?.receive(subscriber: subscriber)
		}
	}
}

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension URLSession.ServicePublisher {
	@discardableResult
	func setContentType(_ contentType: String) -> Self {
		request = request.setContentType(contentType)
		return self
	}

	@discardableResult
	func setShouldHandleCookies(_ handle: Bool) -> Self {
        request = request.setShouldHandleCookies(handle)
		return self
	}

	@discardableResult
	func setParameters(_ parameters: [String: Any], encoding: Request.ParameterEncoding? = nil) -> Self {
        request = request.setParameters(parameters, encoding: encoding)
		return self
	}

	@discardableResult
	func setBody(_ data: Data?) -> Self {
        request = request.setBody(data)
		return self
	}

	@discardableResult
	func setBody(_ data: Data?, contentType: String) -> Self {
        request = request.setBody(data, contentType: contentType)
        return self
	}

	@discardableResult
	func setJSON(_ json: Any?) -> Self {
        request = request.setJSON(json)
        return self
	}

	@discardableResult
	func setJSONData(_ json: Data?) -> Self {
		setBody(json, contentType: Request.ContentType.json)
	}

	@discardableResult
    func setHeaders(_ headers: Set<Request.HTTPHeader>?) -> Self {
        request = request.setHeaders(headers)
		return self
	}

	@discardableResult
	func setHeaderValue(_ value: String?, forName name: String) -> Self {
        request = request.setHeaderValue(value, forName: name)
		return self
	}

	@discardableResult
	func setCachePolicy(_ cachePolicy: NSURLRequest.CachePolicy) -> Self {
        request = request.setCachePolicy(cachePolicy)
        return self
	}

	@discardableResult
	func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
        request = request.setTimeoutInterval(timeoutInterval)
		return self
	}

	@discardableResult
	func setParameterEncoding(_ encoding: Request.ParameterEncoding) -> Self {
        request = request.setParameterEncoding(encoding)
        return self
	}

	@discardableResult
	func setQueryParameters(_ parameters: [String: Any]?) -> Self {
        request = request.setQueryParameters(parameters)
		    return self
	}

	@discardableResult
	func setQueryParameters(_ parameters: [String: Any], encoder: @escaping QueryParameterEncoder) -> Self {
        request = request.setQueryParameters(parameters, encoder: encoder)
        return self
	}

	@discardableResult
	func setQueryItems(_ queryItems: [URLQueryItem]?) -> Self {
		request = request.setQueryItems(queryItems)
		return self
	}

	@discardableResult
	func appendQueryItems(_ queryItems: [URLQueryItem]?) -> Self {
		request = request.appendQueryItems(queryItems)
		return self
	}

	@discardableResult
	func setFormParameters(_ parameters: [String: Any]?) -> Self {
        request = request.setFormParameters(parameters)
        return self
	}

	@discardableResult
	func setFormParametersAllowedCharacters(_ allowedCharacters: CharacterSet) -> Self {
        request = request.setFormParametersAllowedCharacters(allowedCharacters)
		return self
	}

	@discardableResult
	func setBody<T: Encodable>(_ body: T, encoder: JSONEncoder = JSONEncoder()) throws -> Self {
        request = try request.setBody(body, encoder: encoder)
        return self
	}
}
