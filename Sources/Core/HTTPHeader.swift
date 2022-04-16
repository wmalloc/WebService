//
//  File.swift
//  
//
//  Created by Waqar Malik on 4/15/22.
//

import Foundation

public struct HTTPHeader: Hashable, Identifiable {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    public var id: String {
        name
    }
}
