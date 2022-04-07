//
//  Publisher+SinkOnMain.swift
//  WebService
//
//  Created by Waqar Malik on 8/13/21.
//

import Combine
import Foundation

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
extension Publisher {
	public func sinkOnMain(receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
		receive(on: RunLoop.main)
            .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
	}
}


@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
extension Publisher where Self.Failure == Never {
    public func sinkOnMain(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        receive(on: RunLoop.main)
            .sink(receiveValue: receiveValue)
    }
}
