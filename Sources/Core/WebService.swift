//
//  WebService.swift
//  Webservice
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation

public final class WebService {
    public let baseURL: URL?
    public var baseURLString: String {
        baseURL?.absoluteString ?? ""
    }

    public var session: URLSession

    public init(baseURL: URL?, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public convenience init(baseURLString: String, session: URLSession = .shared) {
        let baseURL = URL(string: baseURLString)
        self.init(baseURL: baseURL, session: session)
    }
}

public extension WebService {
    func absoluteURL(_ string: String) -> URL {
        constructURL(string, relativeToURL: baseURL)!
    }

    func absoluteURLString(_ string: String) -> String {
        absoluteURL(string).absoluteString
    }

    internal func constructURL(_ string: String, relativeToURL: URL?) -> URL? {
        guard !string.isEmpty else { // if string is empty then just return the baseURL
            return baseURL
        }
        let url = URL(string: string, relativeTo: relativeToURL)
        return url
    }
}
