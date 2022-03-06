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
	func GET(_ path: String) -> URLSession.ServicePublisher {
		request(.GET, path: path)
	}

	func POST(_ path: String) -> URLSession.ServicePublisher {
		request(.POST, path: path)
	}

	func PUT(_ path: String) -> URLSession.ServicePublisher {
		request(.PUT, path: path)
	}

	func PATCH(path: String) -> URLSession.ServicePublisher {
		request(.PATCH, path: path)
	}

	func DELETE(_ path: String) -> URLSession.ServicePublisher {
		request(.DELETE, path: path)
	}

	func HEAD(_ path: String) -> URLSession.ServicePublisher {
		request(.HEAD, path: path)
	}

	func request(_ method: Request.Method, path: String) -> URLSession.ServicePublisher {
		servicePublisher(request: Request(method, url: absoluteURL(path)))
	}

	func servicePublisher(request: Request) -> URLSession.ServicePublisher {
		URLSession.ServicePublisher(request: request, session: session)
	}
}
