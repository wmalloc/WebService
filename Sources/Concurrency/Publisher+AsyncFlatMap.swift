//
//  Publisher+AsyncFlatMap.swift
//  
//
//  Created by Waqar Malik on 4/6/22.
//

import Foundation
import Combine

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
extension Publisher {
    public func asyncFlatMap<T>(_ transform: @escaping (Output) async -> T) -> AnyCancellable {
        let flatMapOperation: Publishers.FlatMap<Future<T, Self.Failure>, Self> = flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
        return flatMapOperation.subscribe(PassthroughSubject())
    }
}
