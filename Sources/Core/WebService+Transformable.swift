//
//  WebService+Transformable.swift
//
//
//  Created by Waqar Malik on 3/1/22.
//

import Foundation

public extension WebService {
	func dataTask<T>(request: URLRequest, transform: @escaping DataMapper<Data, T>, completion: WebService.DataHandler<T>?) -> URLSessionDataTask? {
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
				let mapped = try transform(data)
				completion?(.success(mapped))
			} catch {
				completion?(.failure(error))
			}
		}
		dataTask.resume()
		return dataTask
	}

	func dataTask(request: URLRequest, completion: WebService.DataHandler<Data>?) -> URLSessionDataTask? {
		dataTask(request: request, transform: { $0 }, completion: completion)
	}

	func decodableTask<T: Decodable>(request: URLRequest, decoder: JSONDecoder = JSONDecoder(), completion: WebService.DecodeblHandler<T>?) -> URLSessionDataTask? {
		dataTask(request: request) { data in
			try decoder.decode(T.self, from: data)
		} completion: { result in
			completion?(result)
		}
	}

	func serializableTask(request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments, completion: WebService.SerializableHandler?) -> URLSessionDataTask? {
		dataTask(request: request) { data in
			try JSONSerialization.jsonObject(with: data, options: options)
		} completion: { result in
			completion?(result)
		}
	}
}
