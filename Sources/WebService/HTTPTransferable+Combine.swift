//
//  HTTPTransferable+Combine.swift
//
//  Created by Waqar Malik on 6/16/21
//

import Combine
import Foundation
import HTTPRequestable

public extension HTTPTransferable {
  func dataPublisher<ObjectType>(for request: URLRequest, transformer: @escaping Transformer<Data, ObjectType>) -> AnyPublisher<ObjectType, any Error> {
    session.dataTaskPublisher(for: request)
      .tryMap { result -> URLSession.DataTaskPublisher.Output in
        let httpURLResponse = try result.response.httpURLResponse
        return (result.data, httpURLResponse)
      }
      .tryMap { result -> ObjectType in
        try result.data.url_validateNotEmptyData()
        return try transformer(result.data)
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

public extension HTTPTransferable {
  func dataPublisher(for url: URL) -> AnyPublisher<Data, any Error> {
    dataPublisher(for: URLRequest(url: url), transformer: { data in data })
  }

  func dataPublisher(for request: URLRequest) -> AnyPublisher<Data, any Error> {
    dataPublisher(for: request, transformer: { data in data })
  }

  func decodablePublisher<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<ObjectType, any Error> {
    dataPublisher(for: request)
      .decode(type: ObjectType.self, decoder: decoder)
      .eraseToAnyPublisher()
  }
}
