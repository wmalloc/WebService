//
//  WebService+Transformable.swift
//
//  Created by Waqar Malik on 3/1/22.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public extension WebService {
    @discardableResult
	func dataTask(for request: URLRequest, completion: WebService.DataHandler<Data?>?) -> URLSessionDataTask? {
		let dataTask = session.dataTask(with: request) { data, urlResponse, error in
			if let error = error {
				completion?(.failure(error))
				return
			}

			guard let urlResponse = urlResponse else {
				completion?(.failure(URLError(.badServerResponse)))
				return
			}
			do {
				try urlResponse.ws_validate()
				completion?(.success(data))
			} catch {
				completion?(.failure(error))
			}
		}
		dataTask.resume()
		return dataTask
	}

	/**
	 Make a request call and return decoded data as decoded by the transformer, this requesst must return data

	 - parameter request:    Request where to get the data from
	 - parameter transform:  Transformer how to convert the data to different type
	 - parameter completion: completion handler

	 - returns: URLSessionDataTask
	 */
    @discardableResult
	func dataTask<T>(with request: URLRequest, transform: @escaping DataMapper<WebService.DataResponse, T>, completion: WebService.DataHandler<T>?) -> URLSessionDataTask? {
		let dataTask = session.dataTask(with: request) { data, urlResponse, error in
			if let error = error {
				completion?(.failure(error))
				return
			}

			guard let data = data, let urlResponse = urlResponse else {
				completion?(.failure(URLError(.badServerResponse)))
				return
			}
			do {
				try urlResponse.ws_validate()
				let mapped = try transform((data, urlResponse))
				completion?(.success(mapped))
			} catch {
				completion?(.failure(error))
			}
		}
		dataTask.resume()
		return dataTask
	}

    @discardableResult
	func dataTask(with request: URLRequest, completion: WebService.DataHandler<Data>?) -> URLSessionDataTask? {
		dataTask(with: request, transform: { $0.data }, completion: completion)
	}

	/**
	 Decodes the response data tinto codable object

	 - parameter request:    Request where to get the data from
	 - parameter options:    JSON decoder (Default: JSONDecoder)
	 - parameter completion: Completion handler

	 - returns: URLSessionDataTask
	 */
    @discardableResult
	func decodableTask<T: Decodable>(with request: URLRequest, decoder: JSONDecoder = JSONDecoder(), completion: WebService.DecodeblHandler<T>?) -> URLSessionDataTask? {
		dataTask(with: request) { result in
			try decoder.decode(T.self, from: result.data)
		} completion: { result in
			completion?(result)
		}
	}

	/**
	 Serilizes the response data  tinto raw JSON object

	 - parameter request:    Request where to get the data from
	 - parameter options:    JSON serialization options (Default: .allowFragments)
	 - parameter completion: Completion handler

	 - returns: URLSessionDataTask
	 */
    @discardableResult
	func serializableTask(with request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments, completion: WebService.SerializableHandler?) -> URLSessionDataTask? {
		dataTask(with: request) { result in
			try JSONSerialization.jsonObject(with: result.data, options: options)
		} completion: { result in
			completion?(result)
		}
	}

    @discardableResult
	func upload<T>(with request: URLRequest, fromFile file: URL, transform: @escaping DataMapper<WebService.DataResponse, T>, completion: WebService.DataHandler<T>?) -> URLSessionDataTask? {
		let uploadTask = session.uploadTask(with: request, fromFile: file) { data, urlResponse, error in
			if let error = error {
				completion?(.failure(error))
				return
			}

			guard let data = data, let urlResponse = urlResponse else {
				completion?(.failure(URLError(.badServerResponse)))
				return
			}
			do {
				try urlResponse.ws_validate()
				let mapped = try transform((data, urlResponse))
				completion?(.success(mapped))
			} catch {
				completion?(.failure(error))
			}
		}
		uploadTask.resume()
		return uploadTask
	}
}
