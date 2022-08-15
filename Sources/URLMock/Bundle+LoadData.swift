//
//  Bundle+LoadData.swift
//
//  Created by Waqar Malik on 3/4/22.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public extension Bundle {
    func data(forResource: String, withExtension: String, subdirectory: String = "TestData") throws -> Data {
		guard let url = url(forResource: forResource, withExtension: withExtension, subdirectory: subdirectory) else {
			throw URLError(.fileDoesNotExist)
		}
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
		return data
	}
}
