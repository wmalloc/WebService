//
//  WebService+Decodable.swift
//
//
//  Created by Waqar Malik on 3/1/22.
//

import Foundation

public extension WebService {
    func dataTask<T>(request: Request, mapper: @escaping DataMapper<Data, T>, completion: WebService.DataHandler<T>?) -> URLSessionDataTask? {
        guard let urlRequest = try? request.urlRequest() else {
            completion?(.failure(URLError(.badURL)))
            return nil
        }
        return dataTask(urlRequest: urlRequest, mapper: mapper, completion: completion)
    }
    
    func dataTask<T>(urlRequest: URLRequest, mapper: @escaping DataMapper<Data, T>, completion: WebService.DataHandler<T>?) -> URLSessionDataTask? {
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
                let mapped = try mapper(validData)
                completion?(.success(mapped))
            } catch {
                completion?(.failure(error))
            }
        }
        dataTask.resume()
        return dataTask
   }

    func dataTask(urlRequest: URLRequest, completion: WebService.DataHandler<Data>?) -> URLSessionDataTask? {
        dataTask(urlRequest: urlRequest, mapper: {$0}, completion: completion)
    }

	func dataTask(request: Request, completion: WebService.DataHandler<Data>?) -> URLSessionDataTask? {
        dataTask(request: request, mapper: {$0}, completion: completion)
	}

	func decodableTask<T: Decodable>(request: Request, decoder: JSONDecoder = JSONDecoder(), completion: WebService.DecodeblHandler<T>?) -> URLSessionDataTask? {
        dataTask(request: request) { data in
            try decoder.decode(T.self, from: data)
        } completion: { result in
            completion?(result)
        }
	}

	func serializableTask(request: Request, options: JSONSerialization.ReadingOptions = .allowFragments, completion: WebService.SerializableHandler?) -> URLSessionDataTask? {
        dataTask(request: request) { data in
            try JSONSerialization.jsonObject(with: data, options: options)
        } completion: { result in
            completion?(result)
        }
	}
}
