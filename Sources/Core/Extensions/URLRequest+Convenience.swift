//
//  URLRequest+Convenience.swift
//
//  Created by Waqar Malik on 4/15/22.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation
import URLRequestable

public extension URLRequest {
	subscript(header key: String) -> String? {
		get {
			value(forHTTPHeaderField: key)
		}
		set {
			setValue(newValue, forHTTPHeaderField: key)
		}
	}

	var contentType: String? {
		get {
			self[header: .contentType]
		}
		set {
			self[header: .contentType] = newValue
		}
	}

	var userAgent: String? {
		get {
			self[header: .userAgent]
		}
		set {
			self[header: .userAgent] = newValue
		}
	}
}
