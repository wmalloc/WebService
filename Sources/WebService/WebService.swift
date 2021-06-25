//
//  WebService.swift
//  Webservice
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, macCatalyst 13.0, watchOS 6.0, *)
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

@available(macOS 10.15, iOS 13.0, tvOS 13.0, macCatalyst 13.0, watchOS 6.0, *)
public extension WebService {
    func GET(_ path: String) -> URLSession.ServicePublisher {
        request(.GET, path: path)
    }

    func POST(_ path: String) -> URLSession.ServicePublisher {
        request(.POST, path: path)
    }

    func PUT(_ path: String) -> URLSession.ServicePublisher {
        request(.PUT, path: path)
    }

    func PATCH(path: String) -> URLSession.ServicePublisher {
        request(.PATCH, path: path)
    }

    func DELETE(_ path: String) -> URLSession.ServicePublisher {
        request(.DELETE, path: path)
    }

    func HEAD(_ path: String) -> URLSession.ServicePublisher {
        request(.HEAD, path: path)
    }

    func request(_ method: Request.Method, path: String) -> URLSession.ServicePublisher {
        servicePublisher(request: Request(method, url: absoluteURL(path)))
    }

    func servicePublisher(request: Request) -> URLSession.ServicePublisher {
        URLSession.ServicePublisher(request: request, session: session)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, macCatalyst 13.0, watchOS 6.0, *)
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
