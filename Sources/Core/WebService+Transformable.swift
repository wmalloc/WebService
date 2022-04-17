//
//  WebService+Transformable.swift
//
//
//  Created by Waqar Malik on 3/1/22.
//

import Foundation

public extension WebService {
	func dataTask<T>(with request: URLRequest, transform: @escaping DataMapper<(data: Data, response: URLResponse), T>, completion: WebService.DataHandler<T>?) -> URLSessionDataTask? {
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

	func dataTask(with request: URLRequest, completion: WebService.DataHandler<Data>?) -> URLSessionDataTask? {
        dataTask(with: request, transform: { $0.data }, completion: completion)
	}

	func decodableTask<T: Decodable>(with request: URLRequest, decoder: JSONDecoder = JSONDecoder(), completion: WebService.DecodeblHandler<T>?) -> URLSessionDataTask? {
		dataTask(with: request) { result in
            try decoder.decode(T.self, from: result.data)
		} completion: { result in
			completion?(result)
		}
	}

	func serializableTask(with request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments, completion: WebService.SerializableHandler?) -> URLSessionDataTask? {
		dataTask(with: request) { result in
            try JSONSerialization.jsonObject(with: result.data, options: options)
		} completion: { result in
			completion?(result)
		}
	}
}
