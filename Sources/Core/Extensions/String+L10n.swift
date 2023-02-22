//
//  String+L10n.swift
//
//  Created by Waqar Malik on 2/17/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

extension String {
	func localized(bundle: Bundle = .main, tableName: String? = nil, value: String = "", comment: String = "") -> String {
		NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: comment)
	}
}
