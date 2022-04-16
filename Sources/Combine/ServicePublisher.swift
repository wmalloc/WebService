//
//  ServicePublisher.swift
//  Webservice
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Crimson Research, Inc. All rights reserved.
//

import Combine
import Foundation
import WebService

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension URLSession {
	func servicePublisher(for request: URLRequest) -> URLSession.ServicePublisher {
		.init(request: request, session: self)
	}

	class ServicePublisher: Publisher {
		public typealias Output = DataTaskPublisher.Output
		public typealias Failure = DataTaskPublisher.Failure

		public let session: URLSession
		var dataTaskPublisher: DataTaskPublisher?
		let request: URLRequest

		public init(request: URLRequest, session: URLSession) {
			self.request = request
			self.session = session
		}

		public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == URLSession.ServicePublisher.Failure, S.Input == URLSession.ServicePublisher.Output {
            dataTaskPublisher = DataTaskPublisher(request: request, session: session)
			dataTaskPublisher?.receive(subscriber: subscriber)
		}
	}
}
