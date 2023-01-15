//
//  URLSessionConfiguration+HTTPHeaders.swift
//
//  Created by Waqar Malik on 1/14/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public extension URLSessionConfiguration {
	var headers: HTTPHeaders? {
		get {
			let result = httpAdditionalHeaders?.compactMap { (key: AnyHashable, value: Any) -> HTTPHeader? in
				guard let name = key as? String, let value = value as? String else {
					return nil
				}
				return HTTPHeader(name: name, value: value)
			}
			guard let result else {
				return nil
			}
			return HTTPHeaders(result)
		}
		set {
			httpAdditionalHeaders = newValue?.dictionary
		}
	}
}
