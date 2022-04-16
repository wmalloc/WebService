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
            value(forHTTPHeaderField: key)
        }
        set {
            setValue(newValue, forHTTPHeaderField: key)
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
