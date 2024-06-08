//
//  Bundle+LoadData.swift
//
//  Created by Waqar Malik on 3/4/22
//

import Foundation

public extension Bundle {
  func data(forResource: String, withExtension: String, subdirectory: String = "TestData") throws -> Data {
    guard let url = url(forResource: forResource, withExtension: withExtension, subdirectory: subdirectory) else {
      throw URLError(.fileDoesNotExist)
    }
    return try Data(contentsOf: url, options: [.mappedIfSafe])
  }
}
