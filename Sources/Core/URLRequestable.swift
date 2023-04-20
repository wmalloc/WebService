//
//  URLRequestable.swift
//
//  Created by Waqar Malik on 4/18/23.
//

import Foundation

public protocol URLRequestable {
	associatedtype Response: Decodable
	typealias DecodableTransformer = WebService.Transformer<WebService.DataResponse, Response>

	var apiBaseURLString: String { get }
	var method: HTTPMethod { get }
	var path: String { get }
	var headers: HTTPHeaders { get }
	var body: Data? { get }
	var queryItems: [URLQueryItem]? { get }

	var transformer: DecodableTransformer { get }

	func url(queryItems: [URLQueryItem]?) throws -> URL
	func urlRequest(headers: HTTPHeaders?, queryItems: [URLQueryItem]?) throws -> URLRequest
}

public extension URLRequestable {
	var headers: HTTPHeaders {
		HTTPHeaders()
			.add(.accept(URLRequest.ContentType.json))
	}

	var body: Data? {
		nil
	}

	var queryItems: [URLQueryItem]? {
		nil
	}

	func url(queryItems: [URLQueryItem]? = nil) throws -> URL {
		guard var components = URLComponents(string: apiBaseURLString) else {
			throw URLError(.badURL)
		}
		var items = self.queryItems ?? []
		items.append(contentsOf: queryItems ?? [])
		components.appendQueryItems(items)
		components.path = path
		guard let url = components.url else {
			throw URLError(.unsupportedURL)
		}
		return url
	}

	func urlRequest(headers: HTTPHeaders? = nil, queryItems: [URLQueryItem]? = nil) throws -> URLRequest {
		let url = try url(queryItems: queryItems)
		let request = URLRequest(url: url)
			.setMethod(method)
			.addHeaders(self.headers)
			.addHeaders(headers?.headers ?? [])
			.setHttpBody(body, contentType: URLRequest.ContentType.json)
		return request
	}

	var transformer: DecodableTransformer {
		WebService.jsonDecodableTransformer()
	}
}
