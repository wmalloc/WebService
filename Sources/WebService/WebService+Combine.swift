//
//  WebService+Combine.swift
//
//  Created by Waqar Malik on 6/16/21
//

import Combine
import Foundation
import HTTPRequestable

public extension WebService {
  func dataPublisher(for url: URL) -> AnyPublisher<Data, any Error> {
    dataPublisher(for: URLRequest(url: url), transformer: { data, _ in data })
  }

  func dataPublisher(for request: URLRequest) -> AnyPublisher<Data, any Error> {
    dataPublisher(for: request, transformer: { data, _ in data })
  }

  func decodablePublisher<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<ObjectType, any Error> {
    dataPublisher(for: request)
      .decode(type: ObjectType.self, decoder: decoder)
      .eraseToAnyPublisher()
  }

  func serializablePublisher(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) -> AnyPublisher<Any, any Error> {
    dataPublisher(for: request, transformer: { data, _ in try JSONSerialization.jsonObject(with: data, options: options) })
  }

  func uploadPublisher<ObjectType>(for request: URLRequest, fromFile file: URL, transform: @escaping Transformer<Data, ObjectType>) -> AnyPublisher<ObjectType, any Error> {
    var sessionDataTask: URLSessionDataTask?
    let receiveCancel = { sessionDataTask?.cancel() }
    return Future { [weak self] promise in
      sessionDataTask = self?.upload(with: request, fromFile: file, transformer: transform) { result in
        promise(result)
      }
    }
    .handleEvents(receiveCancel: {
      receiveCancel()
    })
    .eraseToAnyPublisher()
  }
}

public extension HTTPTransferable {
  func dataPublisher<ObjectType>(for request: URLRequest, transformer: @escaping Transformer<Data, ObjectType>) -> AnyPublisher<ObjectType, any Error> {
    return session.dataTaskPublisher(for: request)
      .tryMap { result -> URLSession.DataTaskPublisher.Output in
        let httpURLResponse = try result.response.httpURLResponse
        return (result.data, httpURLResponse)
      }
      .tryMap { result -> ObjectType in
        let httpURLResponse = try result.response.httpURLResponse
        try result.data.url_validateNotEmptyData()
        return try transformer(result.data, httpURLResponse)
      }
      .eraseToAnyPublisher()
  }
  
  func dataPublisher<Route: HTTPRequestable>(for route: Route) -> AnyPublisher<Route.ResultType, any Error> {
    guard let urlRequest = try? route.urlRequest else {
      return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }
    
    return dataPublisher(for: urlRequest, transformer: route.responseTransformer)
  }
}

