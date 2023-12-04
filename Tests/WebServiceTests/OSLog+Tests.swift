//
//  OSLog+Tests.swift
//
//  Created by Waqar Malik on 6/21/20.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation
import os.log

extension OSLog {
	private static let subsystem = "com.waqarmalik.WebService"
	static let tests = OSLog(subsystem: subsystem, category: "WebServiceTests")
}
