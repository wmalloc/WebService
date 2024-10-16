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
  @inlinable
  func data(from url: URL, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Data, HTTPURLResponse) {
    try await data(for: URLRequest(url: url), delegate: delegate)
  }

  @inlinable
  func data<ObjectType>(for request: URLRequest, transformer: @escaping Transformer<Data, ObjectType>) async throws -> ObjectType {
    try await object(for: request, transformer: transformer, delegate: nil)
  }

  @inlinable
  func decodable<ObjectType: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) async throws -> ObjectType {
    try await object(for: request, transformer: { data, _ in try decoder.decode(ObjectType.self, from: data) }, delegate: nil)
  }

  @inlinable
  func serializable(for request: URLRequest, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
    try await object(for: request, transformer: { data, _ in try JSONSerialization.jsonObject(with: data, options: options) }, delegate: nil)
  }

  func upload<ObjectType>(for request: URLRequest, fromFile file: URL, transformer: Transformer<Data, ObjectType>) async throws -> ObjectType {
    var updatedRequest = request
    for interceptor in requestInterceptors {
      try await interceptor.intercept(&updatedRequest, for: self.session)
    }
    let (data, response) = try await session.upload(for: request, fromFile: file)
    let httpResponse = try response.httpURLResponse
    for interceptor in self.responseInterceptors {
      try await interceptor.intercept(request: updatedRequest, data: data, response: httpResponse)
    }
    return try transformer(data, httpResponse)
  }
}
