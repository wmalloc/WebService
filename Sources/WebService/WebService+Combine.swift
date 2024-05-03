//
//  WebService+Combine.swift
//
//  Created by Waqar Malik on 6/16/21.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Combine
import Foundation
import HTTPRequestable

public extension WebService {
  func dataPublisher(for url: URL) -> AnyPublisher<Data, Error> {
    dataPublisher(for: URLRequest(url: url), transformer: { data, _ in data })
  }

  func dataPublisher(for request: URLRequest) -> AnyPublisher<Data, Error> {
    dataPublisher(for: request, transformer: { data, _ in data })
  }

  func decodablePublisher<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<ObjectType, Error> {
    dataPublisher(for: request)
      .decode(type: ObjectType.self, decoder: decoder)
      .eraseToAnyPublisher()
  }

  func serializablePublisher(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) -> AnyPublisher<Any, Error> {
    dataPublisher(for: request, transformer: { data, _ in try JSONSerialization.jsonObject(with: data, options: options) })
  }

  func uploadPublisher<ObjectType>(for request: URLRequest, fromFile file: URL, transform: @escaping Transformer<Data, ObjectType>) -> AnyPublisher<ObjectType, Error> {
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
