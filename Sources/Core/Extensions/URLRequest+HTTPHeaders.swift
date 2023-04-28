//
//  URLRequest+HTTPHeaders.swift
//
//  Created by Waqar Malik on 1/14/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation
import URLRequestable

public extension URLRequest {
    @discardableResult
    func setHttpHeaders(_ httpHeaders: HTTPHeaders?) -> Self {
        var request = self
        request.headers = httpHeaders
        return request
    }

    @discardableResult
    func addHeaders(_ headers: HTTPHeaders) -> Self {
        addHeaders(headers.headers)
    }
}

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
