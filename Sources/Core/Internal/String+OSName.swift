//
//  String+OSName.swift
//
//  Created by Waqar Malik on 1/15/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

extension String {
	static var ws_osName: String {
		#if os(iOS)
		#if targetEnvironment(macCatalyst)
		return "macOS(Catalyst)"
		#else
		return "iOS"
		#endif
		#elseif os(watchOS)
		return "watchOS"
		#elseif os(tvOS)
		return "tvOS"
		#elseif os(macOS)
		return "macOS"
		#else
		return "Unknown"
		#endif
	}
}
