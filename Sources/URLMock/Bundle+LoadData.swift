//
//  File.swift
//
//
//  Created by Waqar Malik on 3/4/22.
//

import Foundation

public extension Bundle {
	func loadTestData(name: String, withExtension: String) throws -> Data {
		guard let url = url(forResource: name, withExtension: withExtension) else {
			throw URLError(.unsupportedURL)
		}
		let data = try Data(contentsOf: url, options: [])
		return data
	}
}
