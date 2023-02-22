//
//  String+UserAgent.swift
//
//
//  Created by Waqar Malik on 1/15/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public extension String {
	static var ws_userAgent: String {
		let infoDictionary = Bundle.main.infoDictionary
		let appName = infoDictionary?["CFBundleExecutable"] as? String ?? ProcessInfo.processInfo.ws_appName ?? "Unknown"
		let bundle = Bundle.main.bundleIdentifier ?? "Unknown"
		let appVersion = infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
		let appBuild = infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
		let os = String.ws_osName + " " + ProcessInfo.processInfo.operatingSystemVersionString
		let package = "WebService"
		let userAgent = "\(appName)/\(appVersion) (\(bundle); build:\(appBuild); \(os)) \(package)"
		return userAgent
	}
}
