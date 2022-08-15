//
//  HTTPMethod.swift
//
//  Created by Waqar Malik on 4/15/22.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public enum HTTPMethod: String, CaseIterable, Hashable {
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

extension HTTPMethod: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
