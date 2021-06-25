//
//  URLRequest+Compliance.swift
//  WebService
//
//  Created by Waqar Malik on 5/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

extension URLRequest: URLRequestEncodable {
    public func urlRequest() throws -> URLRequest {
        self
    }
}
