//
//  WebService+Concurrency
//  WebService
//
//  Created by Waqar Malik on 6/25/21.
//

import Foundation
import Combine

@available(macOS 12, iOS 15, tvOS 15, macCatalyst 15, watchOS 8, *)
public extension WebService {
    func data(request: Request) async throws -> Data {
        let urlRequest = try request.urlRequest()
        let (data, response) = try await session.data(for: urlRequest)
        let validData = try data.ws_validate(response).ws_validateNotEmptyData()
        return validData
    }

    func decodable<T: Decodable>(request: Request, decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        let data = try await data(request: request)
        return try decoder.decode(T.self, from: data)
    }

    func serializable(request: Request, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
        let data = try await data(request: request)
        return try JSONSerialization.jsonObject(with: data, options: options)
    }
}
