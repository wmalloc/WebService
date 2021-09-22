//
//  URL+QueryItems.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

extension URL {
    func ws_URLByAppendingQueryItems(_ newItems: [URLQueryItem]) -> Self? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.ws_appendQueryItems(newItems)
        return components?.url
    }
}
