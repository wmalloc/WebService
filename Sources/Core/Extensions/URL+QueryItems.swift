//
//  URL+QueryItems.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

public extension URL {
	func appendQueryItems(_ newItems: [URLQueryItem]) -> Self {
		var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
		components = components?.appendQueryItems(newItems)
		return components?.url ?? self
	}
}
