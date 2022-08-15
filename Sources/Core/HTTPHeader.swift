//
//  HTTPHeader.swift
//
//  Created by Waqar Malik on 4/15/22.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public struct HTTPHeader: Hashable, Identifiable {
	public let name: String
	public let value: String

	public init(name: String, value: String) {
		self.name = name
		self.value = value
	}

	public var id: String {
		name
	}
}

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
