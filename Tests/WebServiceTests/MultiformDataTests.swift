//
//  MultiformDataTests.swift
//
//
//  Created by Waqar Malik on 1/29/23.
//

@testable import WebService
import XCTest

final class MultiformDataTests: XCTestCase {
	func testBoundary() throws {
		let boundary = UUID().uuidString.replacingOccurrences(of: "-", with: "")
		let multipartData = MultipartFormData(boundary: boundary)
		XCTAssertEqual(boundary, multipartData.boundary)
		let initialBoudary = "--\(boundary)\(EncodingCharacters.crlf)"
		XCTAssertEqual(multipartData.initialBoundary, initialBoudary)
		XCTAssertEqual(multipartData.initialBoundaryData, Data(initialBoudary.utf8))
		let interstitialBoudary = "\(EncodingCharacters.crlf)--\(boundary)\(EncodingCharacters.crlf)"
		XCTAssertEqual(multipartData.interstitialBoundary, interstitialBoudary)
		XCTAssertEqual(multipartData.interstitialBoundaryData, Data(interstitialBoudary.utf8))
		let finalBoundary = "\(EncodingCharacters.crlf)--\(boundary)--\(EncodingCharacters.crlf)"
		XCTAssertEqual(multipartData.finalBoundary, finalBoundary)
		XCTAssertEqual(multipartData.finalBoundaryData, Data(finalBoundary.utf8))
	}
}
