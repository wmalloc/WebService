//
//  Dictionary+Encoding.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

extension Dictionary {
	var ws_queryItems: [URLQueryItem] {
		let items = map { item -> URLQueryItem in
			URLQueryItem(name: "\(item.key)", value: "\(item.value)")
		}
		return items
	}

	var ws_percentEncodedData: Data? {
		ws_percentEncodedData(with: nil)
	}

	func ws_percentEncodedData(with allowedCharacters: CharacterSet? = nil) -> Data? {
		ws_percentEncodedQueryString(with: allowedCharacters)?.data(using: .utf8, allowLossyConversion: false)
	}

	var ws_percentEncodedQueryString: String? {
		ws_percentEncodedQueryString()
	}

	func ws_percentEncodedQueryString(with allowedCharacters: CharacterSet? = nil) -> String? {
		var components = URLComponents(string: "")
		components?.queryItems = ws_queryItems
		guard let allowedCharacters = allowedCharacters else {
			return components?.url?.query
		}

		components?.queryItems = ws_queryItems.map { item in
			URLQueryItem(name: item.name, value: item.value?.addingPercentEncoding(withAllowedCharacters: allowedCharacters))
		}
		return components?.query
	}
}
