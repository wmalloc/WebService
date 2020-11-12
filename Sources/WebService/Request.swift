//
//  Request.swift
//  Webservice
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Foundation
import os.log

public protocol URLRequestEncodable {
    var urlRequest: URLRequest { get }
}

public typealias QueryParameterEncoder = (_ url: URL?, _ parameters: [String: Any]) -> URL?

public struct Request {
    public enum Method: String, CaseIterable {
        case GET
        case HEAD
        case POST
        case PUT
        case PATCH
        case DELETE

        var shouldEncodeParametersInURL: Bool {
            switch self {
            case .GET, .HEAD, .DELETE:
                return true
            default:
                return false
            }
        }
    }

    public enum ParameterEncoding: CustomStringConvertible, CustomDebugStringConvertible, CaseIterable, Hashable {
        case percent
        case json

        public func encodeURL(_ url: URL, parameters: [String: Any]) -> URL? {
            switch self {
            case .percent:
                return url.ws_URLByAppendingQueryItems(parameters.ws_queryItems)
            case .json:
                assertionFailure("Cannot encode URL parameters using JSON encoding")
                return nil
            }
        }

        public func encodeBody(_ parameters: [String: Any], allowedCharacters: CharacterSet? = nil) -> Data? {
            switch self {
            case .percent:
                return parameters.ws_percentEncodedQueryString(with: allowedCharacters)?.data(using: .utf8, allowLossyConversion: false)
            case .json:
                return try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        }

        public var description: String {
            switch self {
            case .json:
                return "JSON"
            case .percent:
                return "PERCENT"
            }
        }

        public var debugDescription: String {
            description
        }
    }

    public enum Header {
        public static let userAgent = "User-Agent"
        public static let contentType = "Content-Type"
        public static let contentLength = "Content-Length"
        public static let contentEncoding = "Content-Encoding"
        public static let accept = "Accept"
        public static let cacheControl = "Cache-Control"
        public static let authorization = "Authorization"
        public static let acceptEncoding = "Accept-Encoding"
        public static let acceptLanguage = "Accept-Language"
        public static let date = "Date"
    }

    public enum ContentType {
        public static let formEncoded = "application/x-www-form-urlencoded"
        public static let json = "application/json"
        public static let xml = "application/xml"
        public static let textPlain = "text/plain"
        public static let html = "text/html"
        public static let css = "text/css"
        public static let octet = "application/octet-stream"
        public static let jpeg = "image/jpeg"
        public static let png = "image/png"
        public static let gif = "image/gif"
        public static let svg = "image/svg+xml"
    }

    public let method: Method
    public let requestURL: URL
    public var urlString: String {
        requestURL.absoluteString
    }

    public var body: Data?
    public var shouldHandleCookies: Bool = true
    public var parameters: [String: Any] = [:]
    public var queryParameters: [String: Any]?
    public var queryItems: [URLQueryItem]?
    public var formParameters: [String: Any]? {
        didSet {
            if let formData = formParameters?.ws_percentEncodedData(with: formParametersAllowedCharacters) {
                body = formData
                contentType = ContentType.formEncoded
            }
        }
    }

    public var queryParameterEncoder: QueryParameterEncoder = { url, parameters -> URL? in
        url?.ws_URLByAppendingQueryItems(parameters.ws_queryItems)
    }

    public var formParametersAllowedCharacters: CharacterSet?
    public var headers: [String: String] = [:]
    public var cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
    public var timeoutInterval: TimeInterval = 10.0
    public var parameterEncoding = ParameterEncoding.percent {
        didSet {
            if parameterEncoding == .json {
                contentType = ContentType.json
            }
        }
    }

    public var contentType: String? {
        set {
            guard let value = newValue else {
                return
            }
            headers[Header.contentType] = value
        }
        get {
            headers[Header.contentType]
        }
    }

    var userAgent: String? {
        set {
            guard let value = newValue else {
                return
            }
            headers[Header.userAgent] = value
        }
        get {
            headers[Header.userAgent]
        }
    }

    public init(_ method: Method, url: URL) {
        self.method = method
        requestURL = url
    }

    public init(_ method: Method, urlString: String) {
        let aURL = URL(string: urlString)!
        self.init(method, url: aURL)
    }
}

extension Request: URLRequestEncodable {
    public var urlRequest: URLRequest {
        var urlComponents = URLComponents(string: urlString)
        if var items = queryItems {
            items.append(contentsOf: urlComponents?.queryItems ?? [])
            if !items.isEmpty {
                urlComponents?.queryItems = items
            }
        }
        var urlRequest = URLRequest(url: urlComponents?.url ?? URL(string: urlString)!)
        urlRequest.httpMethod = method.rawValue
        urlRequest.cachePolicy = cachePolicy
        urlRequest.timeoutInterval = timeoutInterval
        urlRequest.httpShouldHandleCookies = shouldHandleCookies

        for (name, value) in headers {
            urlRequest.addValue(value, forHTTPHeaderField: name)
        }

        if !parameters.isEmpty {
            if method.shouldEncodeParametersInURL {
                if let encodedURL = queryParameterEncoder(urlRequest.url, parameters) {
                    urlRequest.url = encodedURL
                }
            } else {
                if let data = parameterEncoding.encodeBody(parameters) {
                    urlRequest.httpBody = data

                    if urlRequest.value(forHTTPHeaderField: Header.contentType) == nil {
                        urlRequest.setValue(ContentType.formEncoded, forHTTPHeaderField: Header.contentType)
                    }
                }
            }
        }

        if let body = body {
            urlRequest.httpBody = body
        }

        if let queryParameters = queryParameters, let encodedURL = queryParameterEncoder(urlRequest.url, queryParameters) {
            urlRequest.url = encodedURL
        }

        return urlRequest
    }
}

public extension Request {
    @discardableResult
    mutating func setContentType(_ contentType: String) -> Self {
        self.contentType = contentType
        return self
    }

    @discardableResult
    mutating func setShouldHandleCookies(_ handle: Bool) -> Self {
        shouldHandleCookies = handle
        return self
    }

    @discardableResult
    mutating func setParameters(_ parameters: [String: Any], encoding: Request.ParameterEncoding? = nil) -> Self {
        self.parameters = parameters
        parameterEncoding = encoding ?? .percent
        return self
    }

    @discardableResult
    mutating func setBody(_ data: Data) -> Self {
        body = data
        return self
    }

    @discardableResult
    mutating func setBody(_ data: Data, contentType: String) -> Self {
        body = data
        self.contentType = contentType
        return self
    }

    @discardableResult
    mutating func setJSON(_ json: Any) -> Self {
        contentType = Request.ContentType.json
        body = try? JSONSerialization.data(withJSONObject: json, options: [])
        return self
    }

    @discardableResult
    mutating func setJSONData(_ json: Data) -> Self {
        return setBody(json, contentType: Request.ContentType.json)
    }

    @discardableResult
    mutating func setHeaders(_ headers: [String: String]) -> Self {
        self.headers = headers
        return self
    }

    @discardableResult
    mutating func setHeaderValue(_ value: String, forName name: String) -> Self {
        headers[name] = value
        return self
    }

    @discardableResult
    mutating func setCachePolicy(_ cachePolicy: NSURLRequest.CachePolicy) -> Self {
        self.cachePolicy = cachePolicy
        return self
    }

    @discardableResult
    mutating func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
        self.timeoutInterval = timeoutInterval
        return self
    }

    @discardableResult
    mutating func setParameterEncoding(_ encoding: Request.ParameterEncoding) -> Self {
        parameterEncoding = encoding
        return self
    }

    @discardableResult
    mutating func setQueryParameters(_ parameters: [String: Any]) -> Self {
        queryParameters = parameters
        return self
    }

    @discardableResult
    mutating func setQueryParameters(_ parameters: [String: Any], encoder: @escaping QueryParameterEncoder) -> Self {
        setQueryParameters(parameters)
        queryParameterEncoder = encoder
        return self
    }

    @discardableResult
    mutating func setQueryItems(_ queryItems: [URLQueryItem]) -> Self {
        self.queryItems = queryItems
        return self
    }

    @discardableResult
    mutating func appendQueryItems(_ queryItems: [URLQueryItem]) -> Self {
        var existingItems = self.queryItems ?? []
        existingItems.append(contentsOf: queryItems)
        return setQueryItems(existingItems)
    }

    @discardableResult
    mutating func setFormParameters(_ parameters: [String: Any]) -> Self {
        formParameters = parameters
        return self
    }

    @discardableResult
    mutating func setFormParametersAllowedCharacters(_ allowedCharacters: CharacterSet) -> Self {
        formParametersAllowedCharacters = allowedCharacters
        return self
    }

    @discardableResult
    mutating func setBody<T: Encodable>(_ body: T, encoder: JSONEncoder = JSONEncoder()) -> Self {
        do {
            let data = try encoder.encode(body)
            self.body = data
            contentType = Request.ContentType.json
        } catch {
            os_log(.error, "Unable to encode body %@", error.localizedDescription)
        }
        return self
    }
}

extension Request: CustomStringConvertible {
    public var description: String {
        return "{" +
            "\nurl = " + urlString +
            "\nmethod = " + method.rawValue +
            "\nheaders = \(headers)" +
            "\nparameters = \(parameters)" +
            "\ntimeoutInterval = \(timeoutInterval)" +
            "\nqueryParameters = \(String(describing: queryParameters))" +
            "\nqueryItems = \(String(describing: queryItems))" +
            "\nformParameters = \(String(describing: formParameters))" +
            "\nuserAgent = \(String(describing: userAgent))" +
            "\n}"
    }
}

extension Request: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{" +
            "\nurl = " + urlString +
            "\nmethod = " + method.rawValue +
            "\nheaders = \(headers)" +
            "\nparameters = \(parameters)" +
            "\ntimeoutInterval = \(timeoutInterval)" +
            "\nqueryParameters = \(String(describing: queryParameters))" +
            "\nqueryItems = \(String(describing: queryItems))" +
            "\nformParameters = \(String(describing: formParameters))" +
            "\nuserAgent = \(String(describing: userAgent))" +
            "\nshouldHandleCookies = \(shouldHandleCookies)" +
            "\nformParametersAllowedCharacters = \(String(describing: formParametersAllowedCharacters))" +
            "\ncachePolicy = \(cachePolicy)" +
            "\nparameterEncoding = \(parameterEncoding)" +
            "\n}"
    }
}
