//
//  MultipartBoundaryType.swift
//
//  Created by Waqar Malik on 1/24/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

enum EncodingCharacters {
    static let crlf = "\r\n"
}

enum MultipartFormBoundaryType {
    case initial      // --boundary
    case interstitial // --boundary
    case final        // --boundary--
    
    static func boundaryData(forBoundaryType boundaryType: MultipartFormBoundaryType, boundary: String) -> Data {
        return Data(self.boundary(forBoundaryType: boundaryType, boundary: boundary).utf8)
    }
    
    static func boundary(forBoundaryType boundaryType: MultipartFormBoundaryType, boundary: String) -> String {
        let boundaryText: String
        switch boundaryType {
        case .initial:
            boundaryText = "--\(boundary)\(EncodingCharacters.crlf)"
        case .interstitial:
            boundaryText = "\(EncodingCharacters.crlf)--\(boundary)\(EncodingCharacters.crlf)"
        case .final:
            boundaryText = "\(EncodingCharacters.crlf)--\(boundary)--\(EncodingCharacters.crlf)"
        }
        
        return boundaryText
   }
}
