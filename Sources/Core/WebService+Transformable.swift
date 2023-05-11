//
//  WebService+Transformable.swift
//
//  Created by Waqar Malik on 3/1/22.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation
import URLRequestable

public extension WebService {
	@discardableResult
	func dataTask(with request: URLRequest, completion: DataHandler<Data>?) -> URLSessionDataTask? {
		dataTask(for: request, transformer: { $0.data }, completion: completion)
	}

	/**
	 Decodes the response data tinto codable object

	 - parameter request:    Request where to get the data from
	 - parameter options:    JSON decoder (Default: JSONDecoder)
	 - parameter completion: Completion handler

	 - returns: URLSessionDataTask
	 */
	@discardableResult
	func decodableTask<T: Decodable>(with request: URLRequest, decoder: JSONDecoder = JSONDecoder(), completion: DecodableHandler<T>?) -> URLSessionDataTask? {
		dataTask(for: request, transformer: JSONDecoder.transformer(decoder: decoder), completion: completion)
	}

	/**
	 Serilizes the response data  tinto raw JSON object

	 - parameter request:    Request where to get the data from
	 - parameter options:    JSON serialization options (Default: .allowFragments)
	 - parameter completion: Completion handler

	 - returns: URLSessionDataTask
	 */
	@discardableResult
	func serializableTask(with request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments, completion: SerializableHandler?) -> URLSessionDataTask? {
		dataTask(for: request, transformer: JSONSerialization.transformer(options: options), completion: completion)
	}

	/**
	 Serilizes the response data  tinto raw JSON object

	 - parameter request:    Request where to get the data from
	 - parameter fromFile:   URL of the file to upload
	 - parameter transform:  Closure to transform the result
	 - parameter completion: Completion handler

	 - returns: URLSessionDataTask
	 */
	@discardableResult
	func upload<T>(with request: URLRequest, fromFile file: URL, transformer: @escaping Transformer<DataResponse, T>, completion: DataHandler<T>?) -> URLSessionDataTask? {
		let uploadTask = session.uploadTask(with: request, fromFile: file) { data, urlResponse, error in
			if let error {
				completion?(.failure(error))
				return
			}

			guard let data, let urlResponse else {
				completion?(.failure(URLError(.badServerResponse)))
				return
			}
			do {
				try urlResponse.url_validate()
				let mapped = try transformer((data, urlResponse))
				completion?(.success(mapped))
			} catch {
				completion?(.failure(error))
			}
		}
		uploadTask.resume()
		return uploadTask
	}
}
