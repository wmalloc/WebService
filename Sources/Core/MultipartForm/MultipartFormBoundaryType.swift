//
//  MultipartBoundaryType.swift
//
//  Created by Waqar Malik on 1/24/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public enum EncodingCharacters {
	static let crlf = "\r\n"
}

public enum MultipartFormBoundaryType: Hashable, Identifiable {
	public var id: MultipartFormBoundaryType {
		self
	}

	case initial // --boundary
	case interstitial // --boundary
	case final // --boundary--

	public static func boundaryData(forBoundaryType boundaryType: MultipartFormBoundaryType, boundary: String) -> Data {
		Data(self.boundary(forBoundaryType: boundaryType, boundary: boundary).utf8)
	}

	public static func boundary(forBoundaryType boundaryType: MultipartFormBoundaryType, boundary: String) -> String {
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
