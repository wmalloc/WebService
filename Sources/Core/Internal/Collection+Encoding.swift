//
//  Collection+Encoding.swift
//
//  Created by Waqar Malik on 1/15/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

extension Collection where Element == String {
	func ws_qualityEncoded() -> Element {
		enumerated().map { index, encoding in
			let quality = 1.0 - (Double(index) * 0.1)
			return "\(encoding);q=\(quality)"
		}.joined(separator: ", ")
	}
}
