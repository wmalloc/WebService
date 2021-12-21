//
//  WebService+Concurrency
//  WebService
//
//  Created by Waqar Malik on 6/25/21.
//

import Foundation
import Combine

@available(swift 5.5)
public extension WebService {
    func data(request: Request) async throws -> Data {
        let urlRequest = try request.urlRequest()
        let result: (Data, URLResponse)
        if #available(iOS 15, tvOS 15, watchOS 8, macCatalyst 15, macOS 12, *) {
            result = try await session.data(for: urlRequest, delegate: nil)
        } else {
            result = try await session.data(for: urlRequest)
        }
        
        let validData = try result.0.ws_validate(result.1).ws_validateNotEmptyData()
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
