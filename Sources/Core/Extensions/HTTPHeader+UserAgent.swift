//
//  HTTPHeader+UserAgent.swift
//
//  Created by Waqar Malik on 1/14/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

extension HTTPHeader {
	/// See the [User-Agent header](https://tools.ietf.org/html/rfc7231#section-5.5.3).
	static func buildUserAgent() -> HTTPHeader {
		.userAgent(String.ws_userAgent)
	}
}
