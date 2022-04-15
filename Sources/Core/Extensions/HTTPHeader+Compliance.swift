//
//  HTTPHeader+Compliance.swift
//
//
//  Created by Waqar Malik on 3/25/22.
//

import Foundation

extension HTTPHeader: CustomStringConvertible {
	public var description: String {
		"""
		{
		    name: \(name),
		    value: \(String(describing: value))
		}
		"""
	}
}
