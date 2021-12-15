//
//  File.swift
//  
//
//  Created by Waqar Malik on 12/14/21.
//

import Foundation

@available(iOS, introduced: 13, deprecated: 15.0, message: "Use the built-in API instead")
@available(tvOS, introduced: 13, deprecated: 15.0, message: "Use the built-in API instead")
@available(watchOS, introduced: 6, deprecated: 8, message: "Use the built-in API instead")
@available(macOS, introduced: 10.15, deprecated: 12, message: "Use the built-in API instead")
@available(macCatalyst, introduced: 10.15, deprecated: 12, message: "Use the built-in API instead")
public extension URLSession {
    func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
    
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
}
