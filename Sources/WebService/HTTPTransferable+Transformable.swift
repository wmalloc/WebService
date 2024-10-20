//
//  HTTPTransferable+Transformable.swift
//
//  Created by Waqar Malik on 3/1/22
//

import Foundation
import HTTPRequestable
import HTTPTypes

public typealias DecodableHandler<T: Decodable> = @Sendable (Result<T, any Error>) -> Void
public typealias SerializableHandler = @Sendable (Result<Any, any Error>) -> Void
public typealias ErrorHandler = @Sendable ((any Error)?) -> Void
public typealias DataHandler<T> = @Sendable (Result<T, any Error>) -> Void

public extension HTTPTransferable {
  @discardableResult
  func dataTask<ObjectType>(for request: URLRequest, transformer: @escaping Transformer<Data, ObjectType>, completion: DataHandler<ObjectType>?) -> URLSessionDataTask? {
    let dataTask = session.dataTask(with: request) { data, urlResponse, error in
      if let error {
        completion?(.failure(error))
        return
      }

      guard let data else {
        completion?(.failure(URLError(.fileDoesNotExist)))
        return
      }
      do {
        let mapped = try transformer(data)
        completion?(.success(mapped))
      } catch {
        completion?(.failure(error))
      }
    }
    dataTask.resume()
    return dataTask
  }

  @discardableResult
  func dataTask<Route: HTTPRequestable>(for route: Route, completion: DataHandler<Route.ResultType>?) -> URLSessionDataTask? {
    guard let urlRequest = try? route.urlRequest else {
      return nil
    }
    return dataTask(for: urlRequest, transformer: route.responseTransformer, completion: completion)
  }
}

public extension HTTPTransferable {
  @discardableResult
  func dataTask(with request: URLRequest, completion: DataHandler<Data>? = nil) -> URLSessionDataTask? {
    dataTask(for: request, transformer: { data in data }, completion: completion)
  }

  /**
   Decodes the response data tinto codable object

   - parameter request:    Request where to get the data from
   - parameter options:    JSON decoder (Default: JSONDecoder)
   - parameter completion: Completion handler

   - returns: URLSessionDataTask
   */
  @discardableResult
  func decodableTask<T: Decodable & Sendable>(with request: URLRequest, decoder: JSONDecoder = JSONDecoder(), completion: DecodableHandler<T>? = nil) -> URLSessionDataTask? {
    dataTask(for: request, transformer: { data in try decoder.decode(T.self, from: data) }, completion: completion)
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
  func upload<T>(with request: URLRequest, fromFile file: URL, transformer: @escaping Transformer<Data, T>, completion: DataHandler<T>? = nil) -> URLSessionDataTask? {
    let uploadTask = session.uploadTask(with: request, fromFile: file) { data, urlResponse, error in
      if let error {
        completion?(.failure(error))
        return
      }

      guard let data else {
        completion?(.failure(URLError(.badServerResponse)))
        return
      }
      do {
        let mapped = try transformer(data)
        completion?(.success(mapped))
      } catch {
        completion?(.failure(error))
      }
    }
    uploadTask.resume()
    return uploadTask
  }
}
