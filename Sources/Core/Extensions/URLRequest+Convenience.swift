//
//  URLRequest+Convenience.swift
//
//
//  Created by Waqar Malik on 4/15/22.
//

import Foundation

public extension URLRequest {
    subscript(header key: String) -> String? {
        get {
            allHTTPHeaderFields?.first { element in
                element.key == key
            }?.value
        }
        set {
            if let value = newValue {
                var headers = allHTTPHeaderFields ?? [:]
                headers.removeValue(forKey: key)
                headers[key] = value
                allHTTPHeaderFields = headers
            }
        }
    }

    var contentType: String? {
        get {
            self[header: URLRequest.Header.contentType]
        }
        set {
            self[header: URLRequest.Header.contentType] = newValue
        }
    }
    
    var userAgent: String? {
        get {
            self[header: URLRequest.Header.userAgent]
        }
        set {
            self[header: URLRequest.Header.userAgent] = newValue
        }
    }
}
