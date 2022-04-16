//
//  WebService+ServicePublilsher.swift
//
//
//  Created by Waqar Malik on 2/28/22.
//

import Combine
import Foundation
import WebService

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, watchOS 6, *)
public extension WebService {
	func servicePublisher(request: URLRequest) -> URLSession.ServicePublisher {
		URLSession.ServicePublisher(request: request, session: session)
	}
}
