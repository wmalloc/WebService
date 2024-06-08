//
//  OSLog+Tests.swift
//
//  Created by Waqar Malik on 6/21/20
//

import Foundation
import os.log

extension OSLog {
  private static let subsystem = "com.waqarmalik.WebService"
  static let tests = OSLog(subsystem: subsystem, category: "WebServiceTests")
}
