//
//  WebService+Concurrency
//
//  Created by Waqar Malik on 6/25/21
//

import Foundation
import HTTPRequestable
import HTTPTypes
import HTTPTypesFoundation
import os.log

public extension HTTPTransferable {
  func data(from url: URL, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await session.data(from: url, delegate: delegate)
    return try (data, response.httpURLResponse)
  }

  func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await session.data(for: request, delegate: delegate)
    return try (data, response.httpURLResponse)
  }

  func data<ObjectType>(for request: URLRequest, transformer: Transformer<Data, ObjectType>) async throws -> ObjectType {
    let (data, response) = try await data(for: request)
    return try transformer(data, response)
  }

  func decodable<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) async throws -> ObjectType {
    try await data(for: request, transformer: { data, _ in try decoder.decode(ObjectType.self, from: data) })
  }

  func serializable(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
    try await data(for: request, transformer: { data, _ in try JSONSerialization.jsonObject(with: data, options: options) })
  }

  func upload<ObjectType>(for request: URLRequest, fromFile file: URL, transformer: Transformer<Data, ObjectType>) async throws -> ObjectType {
    let (data, response) = try await session.upload(for: request, fromFile: file)
    let httpResponse = try response.httpURLResponse
    return try transformer(data, httpResponse)
  }
}
