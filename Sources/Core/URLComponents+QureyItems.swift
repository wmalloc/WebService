//
//  URLComponents+QueryItems.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

public extension URLComponents {
    mutating func ws_appendQueryItems(_ newItems: [URLQueryItem]) {
        if let existingQueryItems = queryItems {
            queryItems = existingQueryItems + newItems
        } else {
            queryItems = newItems
        }
    }
}
