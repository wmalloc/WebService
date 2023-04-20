//
//  File.swift
//
//
//  Created by Waqar Malik on 4/18/23.
//

import Foundation

public extension WebService {
	func decoded<Route: URLRequestable>(route: Route, completion: DecodeblHandler<Route.Response>?) -> URLSessionDataTask? {
		guard let request = try? route.urlRequest(headers: nil, queryItems: nil) else {
			completion?(.failure(URLError(.badURL)))
			return nil
		}

		return dataTask(with: request, transform: route.transformer, completion: completion)
	}
}
