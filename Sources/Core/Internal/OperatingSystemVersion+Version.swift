//
//  OperatingSystemVersion+Version.swift
//
//  Created by Waqar Malik on 1/14/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

extension OperatingSystemVersion {
	var ws_versionString: String {
		"\(majorVersion).\(minorVersion).\(patchVersion)"
	}
}
