//
//  WebService.swift
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public final class WebService {
	public typealias DecodeblHandler<T: Decodable> = (Result<T, Error>) -> Void
	public typealias SerializableHandler = (Result<Any, Error>) -> Void
	public typealias DataHandler<T> = (Result<T, Error>) -> Void
	public typealias ErrorHandler = (Error?) -> Void
	public typealias Transformer<InputType, OutputType> = (InputType) throws -> OutputType
	public typealias DataResponse = (data: Data, response: URLResponse)
	public let session: URLSession

	static var sessionConfiguration: URLSessionConfiguration = {
		var config = URLSessionConfiguration.default
		config.headers = HTTPHeaders.defaultHeaders
		config.requestCachePolicy = .useProtocolCachePolicy
		return config
	}()

	public init(session: URLSession = .shared) {
		self.session = session
	}

	public static func jsonSerializableTransformer(options: JSONSerialization.ReadingOptions = .allowFragments) -> Transformer<WebService.DataResponse, Any> {
		{ response in
			try response.response.ws_validate()
			try response.data.ws_validateNotEmptyData()
			return try JSONSerialization.jsonObject(with: response.data, options: options)
		}
	}

	public static func jsonDecodableTransformer<T: Decodable>(decoder: JSONDecoder = JSONDecoder()) -> Transformer<WebService.DataResponse, T> {
		{ response in
			try response.response.ws_validate()
			try response.data.ws_validateNotEmptyData()
			return try decoder.decode(T.self, from: response.data)
		}
	}
}
