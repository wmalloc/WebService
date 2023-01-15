//
//  URLRequest+HTTPHeaders.swift
//
//  Created by Waqar Malik on 1/14/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public extension URLRequest {
	var headers: HTTPHeaders? {
		get {
			let values = allHTTPHeaderFields?.compactMap { (key: String, value: String) in
				HTTPHeader(name: key, value: value)
			}
			guard let values else {
				return nil
			}
			return HTTPHeaders(values)
		}
		set {
			allHTTPHeaderFields = newValue?.dictionary
		}
	}
}
