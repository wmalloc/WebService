//
//  Publisher+SinkOnMain.swift
//  WebService
//
//  Created by Waqar Malik on 8/13/21.
//

import Combine
import Foundation

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension Publisher {
	func sinkOnMain(receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
		receive(on: RunLoop.main).sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
	}
}
