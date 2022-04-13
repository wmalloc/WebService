//
//  URLRequest+Compliance.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

extension URLRequest: URLRequestable {
	public func url() throws -> URL {
		guard let url = url else {
			throw URLError(.badURL)
		}
		return url
	}

	public func urlRequest() throws -> URLRequest {
		self
	}
}
