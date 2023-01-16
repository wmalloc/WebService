//
//  ProcessInfo+AppName.swift
//
//  Created by Waqar Malik on 1/15/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

extension ProcessInfo {
	var ws_appName: String? {
		arguments.first?.split(separator: "/").last.map(String.init)
	}
}
