//
//  WebService+Decodable.swift
//
//
//  Created by Waqar Malik on 3/1/22.
//

import Foundation

public extension WebService {
	func dataTask(urlRequest: URLRequest, completion: WebService.DataHandler?) -> URLSessionDataTask? {
		let dataTask = session.dataTask(with: urlRequest) { data, urlResponse, error in
			if let error = error {
				completion?(.failure(error))
				return
			}
			guard let data = data, let urlResponse = urlResponse else {
				completion?(.failure(URLError(.badServerResponse)))
				return
			}
			do {
				let validData = try data.ws_validate(urlResponse).ws_validateNotEmptyData()
				completion?(.success(validData))
			} catch {
				completion?(.failure(error))
			}
		}
		dataTask.resume()
		return dataTask
	}

	func dataTask(request: Request, completion: WebService.DataHandler?) -> URLSessionDataTask? {
		guard let urlRequest = try? request.urlRequest() else {
			return nil
		}
		return dataTask(urlRequest: urlRequest, completion: completion)
	}

	func decodableTask<T: Decodable>(request: Request, decoder: JSONDecoder = JSONDecoder(), completion: WebService.DecodeblHandler<T>?) -> URLSessionDataTask? {
		dataTask(request: request) { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let data):
				do {
					let decoded = try decoder.decode(T.self, from: data)
					completion?(.success(decoded))
				} catch {
					completion?(.failure(error))
				}
			}
		}
	}

	func serializableTask(request: Request, options: JSONSerialization.ReadingOptions = .allowFragments, completion: WebService.SerializableHandler?) -> URLSessionDataTask? {
		dataTask(request: request) { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let data):
				do {
					let decoded = try JSONSerialization.jsonObject(with: data, options: options)
					completion?(.success(decoded))
				} catch {
					completion?(.failure(error))
				}
			}
		}
	}
}
