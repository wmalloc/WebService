//
//  Dictionary+Encoding.swift
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

/// Extension to modify the query items
extension Dictionary where Key == String, Value == String? {
    var ws_queryItems: [URLQueryItem] {
        let items = map { item -> URLQueryItem in
            URLQueryItem(name: item.key, value: item.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        }
        return items
    }

    var ws_percentEncodedData: Data? {
		ws_percentEncodedData(with: nil)
	}

	func ws_percentEncodedData(with allowedCharacterSet: CharacterSet? = nil) -> Data? {
		ws_percentEncodedQueryString(with: allowedCharacterSet)?.data(using: .utf8, allowLossyConversion: false)
	}

	var ws_percentEncodedQueryString: String? {
		ws_percentEncodedQueryString()
	}

	func ws_percentEncodedQueryString(with allowedCharacterSet: CharacterSet? = nil) -> String? {
        let characterSet = allowedCharacterSet ?? .urlQueryAllowed // Defaults to Query allowed
		var components = URLComponents(string: "")
		components?.queryItems = ws_queryItems

		components?.queryItems = ws_queryItems.map { item in
			URLQueryItem(name: item.name, value: item.value?.addingPercentEncoding(withAllowedCharacters: characterSet))
		}
		return components?.query
	}
}
