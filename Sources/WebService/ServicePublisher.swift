//
//  ServicePublisher.swift
//  Webservice
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Combine
import Foundation
import os.log

public extension URLSession {
    func servicePublisher(for url: URL) -> URLSession.ServicePublisher {
        servicePublisher(for: .init(.GET, url: url))
    }
    
    func servicePublisher(for request: Request) -> URLSession.ServicePublisher {
        .init(request: request, session: self)
    }
    
    class ServicePublisher: Publisher {
        public typealias Output = DataTaskPublisher.Output
        public typealias Failure = DataTaskPublisher.Failure
        
        public let session: URLSession
        var dataTaskPublisher: DataTaskPublisher?
        var request: Request
         
        public init(request: Request, session: URLSession) {
            self.request = request
            self.session = session
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == URLSession.ServicePublisher.Failure, S.Input == URLSession.ServicePublisher.Output {
            let theSession = session
            guard let urlRequest = try? request.urlRequest() else {
                return
            }
            dataTaskPublisher = DataTaskPublisher(request: urlRequest, session: theSession)
            dataTaskPublisher?.receive(subscriber: subscriber)
        }
    }
}

public extension URLSession.ServicePublisher {
    @discardableResult
    func setContentType(_ contentType: String) -> Self {
        request.contentType = contentType
        return self
    }
    
    @discardableResult
    func setShouldHandleCookies(_ handle: Bool) -> Self {
        request.shouldHandleCookies = handle
        return self
    }
    
    @discardableResult
    func setParameters(_ parameters: [String: Any], encoding: Request.ParameterEncoding? = nil) -> Self {
        request.parameters = parameters
        request.parameterEncoding = encoding ?? .percent
        return self
    }
    
    @discardableResult
    func setBody(_ data: Data) -> Self {
        request.body = data
        return self
    }
    
    @discardableResult
    func setBody(_ data: Data, contentType: String) -> Self {
        request.body = data
        request.contentType = contentType
        return self
    }
    
    @discardableResult
    func setJSON(_ json: Any) -> Self {
        request.contentType = Request.ContentType.json
        request.body = try? JSONSerialization.data(withJSONObject: json, options: [])
        return self
    }
    
    @discardableResult
    func setJSONData(_ json: Data) -> Self {
        return setBody(json, contentType: Request.ContentType.json)
    }
    
    @discardableResult
    func setHeaders(_ headers: [String: String]) -> Self {
        request.headers = headers
        return self
    }
    
    @discardableResult
    func setHeaderValue(_ value: String, forName name: String) -> Self {
        request.headers[name] = value
        return self
    }
    
    @discardableResult
    func setCachePolicy(_ cachePolicy: NSURLRequest.CachePolicy) -> Self {
        request.cachePolicy = cachePolicy
        return self
    }
    
    @discardableResult
    func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
        request.timeoutInterval = timeoutInterval
        return self
    }
    
    @discardableResult
    func setParameterEncoding(_ encoding: Request.ParameterEncoding) -> Self {
        request.parameterEncoding = encoding
        return self
    }
    
    @discardableResult
    func setQueryParameters(_ parameters: [String: Any]) -> Self {
        request.queryParameters = parameters
        return self
    }
    
    @discardableResult
    func setQueryParameters(_ parameters: [String: Any], encoder: @escaping QueryParameterEncoder) -> Self {
        setQueryParameters(parameters)
        request.queryParameterEncoder = encoder
        return self
    }

    @discardableResult
    func setQueryItems(_ queryItems: [URLQueryItem]) -> Self {
        request.setQueryItems(queryItems)
        return self
    }

    @discardableResult
    func appendQueryItems(_ queryItems: [URLQueryItem]) -> Self {
        request.appendQueryItems(queryItems)
        return self
    }

    @discardableResult
    func setFormParameters(_ parameters: [String: Any]) -> Self {
        request.formParameters = parameters
        return self
    }
    
    @discardableResult
    func setFormParametersAllowedCharacters(_ allowedCharacters: CharacterSet) -> Self {
        request.formParametersAllowedCharacters = allowedCharacters
        return self
    }
    
    @discardableResult
    func setBody<T: Encodable>(_ body: T, encoder: JSONEncoder = JSONEncoder()) -> Self {
        do {
            let data = try encoder.encode(body)
            request.body = data
            request.contentType = Request.ContentType.json
        } catch {
            os_log(.error, "Unable to encode body %@", error.localizedDescription)
        }
        return self
    }
}
