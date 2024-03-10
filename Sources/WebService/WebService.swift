//
//  WebService.swift
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation
import HTTPTypes
import URLRequestable

open class WebService: URLTransferable {
	public let session: URLSession

	public static var sessionConfiguration: URLSessionConfiguration = {
		var config = URLSessionConfiguration.default
		config.headers = HTTPFields.defaultHeaders
		config.requestCachePolicy = .useProtocolCachePolicy
		return config
	}()

	public required init(session: URLSession = .shared) {
		self.session = session
	}
}
