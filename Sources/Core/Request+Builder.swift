//
//  Request+Builder.swift
//  
//
//  Created by Waqar Malik on 4/15/22.
//

import Foundation

public extension Request {
    @discardableResult
    func setContentType(_ contentType: String?) -> Self {
        var request = self
        request.contentType = contentType
        return request
    }

    @discardableResult
    func setUserAgent(_ userAgent: String?) -> Self {
        var request = self
        request.userAgent = userAgent
        return request
    }

    @discardableResult
    func setShouldHandleCookies(_ handle: Bool) -> Self {
        var request = self
        request.shouldHandleCookies = handle
        return request
    }

    @discardableResult
    func setParameters(_ parameters: [String: Any], encoding: Request.ParameterEncoding? = nil) -> Self {
        guard !parameters.isEmpty else {
            return self
        }
        var request = self
        request.parameters = parameters
        request.parameterEncoding = encoding ?? .percent
        return request
    }

    @discardableResult
    func setBody(_ data: Data?) -> Self {
        guard let data = data else {
            return self
        }

        var request = self
        request.body = data
        return request
    }

    @discardableResult
    func setBody(_ data: Data?, contentType: String) -> Self {
        guard let data = data else {
            return self
        }
        var request = self
        request.body = data
        request.contentType = contentType
        return request
    }

    @discardableResult
    func setJSON(_ json: Any?) -> Self {
        guard let json = json else {
            return self
        }
        var request = self
        request.contentType = URLRequest.ContentType.json
        request.body = try? JSONSerialization.data(withJSONObject: json, options: [])
        return request
    }

    @discardableResult
    func setJSONData(_ json: Data?) -> Self {
        setBody(json, contentType: URLRequest.ContentType.json)
    }

    @discardableResult
    func setHeaders(_ headers: Set<HTTPHeader>?) -> Self {
        guard let headers = headers, !headers.isEmpty else {
            return self
        }
        var request = self
        request.headers = headers
        return request
    }

    @discardableResult
    func updateHeaders(_ headers: Set<HTTPHeader>?) -> Self {
        guard let headers = headers, !headers.isEmpty else {
            return self
        }

        var request = self
        request.headers.formUnion(headers)
        return request
    }

    @discardableResult
    func setHeaderValue(_ value: String, forName name: String) -> Self {
        var request = self
        let httpHeader = HTTPHeader(name: name, value: value)
        request.headers.insert(httpHeader)
        return request
    }

    @discardableResult
    func setCachePolicy(_ cachePolicy: NSURLRequest.CachePolicy) -> Self {
        var request = self
        request.cachePolicy = cachePolicy
        return request
    }

    @discardableResult
    func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
        var request = self
        request.timeoutInterval = timeoutInterval
        return request
    }

    @discardableResult
    func setParameterEncoding(_ encoding: Request.ParameterEncoding) -> Self {
        var request = self
        request.parameterEncoding = encoding
        return request
    }

    @discardableResult
    func setQueryParameters(_ parameters: [String: Any]?) -> Self {
        guard let parameters = parameters else {
            return self
        }
        var request = self
        request.queryParameters = parameters
        return request
    }

    @discardableResult
    func setQueryParameters(_ parameters: [String: Any], encoder: @escaping QueryParameterEncoder) -> Self {
        guard !parameters.isEmpty else {
            return self
        }
        var request = setQueryParameters(parameters)
        request.queryParameterEncoder = encoder
        return request
    }

    @discardableResult
    func setQueryItems(_ queryItems: [URLQueryItem]?) -> Self {
        guard let queryItems = queryItems else {
            return self
        }

        var request = self
        request.queryItems = queryItems
        return request
    }

    @discardableResult
    func appendQueryItems(_ queryItems: [URLQueryItem]?) -> Self {
        guard let queryItems = queryItems else {
            return self
        }

        var existingItems = self.queryItems ?? []
        existingItems.append(contentsOf: queryItems)
        return setQueryItems(existingItems)
    }

    @discardableResult
    func setFormParameters(_ parameters: [String: Any]?) -> Self {
        guard let parameters = parameters else {
            return self
        }

        var request = self
        request.formParameters = parameters
        return request
    }

    @discardableResult
    func setFormParametersAllowedCharacters(_ allowedCharacters: CharacterSet) -> Self {
        var request = self
        request.formParametersAllowedCharacters = allowedCharacters
        return request
    }

    @discardableResult
    func setBody<T: Encodable>(_ body: T, encoder: JSONEncoder = JSONEncoder()) throws -> Self {
        var request = self
        let data = try encoder.encode(body)
        request.body = data
        request.contentType = URLRequest.ContentType.json
        return request
    }
}
