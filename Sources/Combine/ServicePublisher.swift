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
	func servicePublisher(method: HTTPMethod = .GET, url: URL) -> URLSession.ServicePublisher {
		servicePublisher(for: Request(method, url: url))
	}

	@available(*, deprecated, message: "Use servicePublisher(method:url:) instead")
	func servicePublisher(for url: URL) -> URLSession.ServicePublisher {
		servicePublisher(for: .init(.GET, url: url))
	}

	func servicePublisher(for request: Request) -> URLSession.ServicePublisher {
		.init(request: request, session: self)
	}

	class ServicePublisher: Publisher {
		public typealias Output = DataTaskPublisher.Output
		public typealias Failure = DataTaskPublisher.Failure

		public let session: URLSession
		var dataTaskPublisher: DataTaskPublisher?
		var request: Request

		public init(request: Request, session: URLSession) {
			self.request = request
			self.session = session
		}

		public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == URLSession.ServicePublisher.Failure, S.Input == URLSession.ServicePublisher.Output {
			let theSession = session
			guard let urlRequest = try? request.urlRequest() else {
				return
			}
			dataTaskPublisher = DataTaskPublisher(request: urlRequest, session: theSession)
			dataTaskPublisher?.receive(subscriber: subscriber)
		}
	}
}
