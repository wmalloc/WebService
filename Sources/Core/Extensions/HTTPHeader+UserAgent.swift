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
		let infoDictionary = Bundle.main.infoDictionary
		let appName = infoDictionary?["CFBundleExecutable"] as? String ?? ProcessInfo.processInfo.ws_appName ?? "Unknown"
		let bundle = Bundle.main.bundleIdentifier ?? "Unknown"
		let appVersion = infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
		let appBuild = infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
		let os = String.ws_osName + " " + ProcessInfo.processInfo.operatingSystemVersionString
		let package = "WebService"
		let userAgent = "\(appName)/\(appVersion) (\(bundle); build:\(appBuild); \(os)) \(package)"
		return .userAgent(userAgent)
	}
}
