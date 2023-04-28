//
//  MultiformDataTests.swift
//
//
//  Created by Waqar Malik on 1/29/23.
//

@testable import WebService
import XCTest
import URLRequestable

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

	func testOneItem() throws {
		let boundray = "109AF0987D004171B0A8481D6401B62D"
		let profileDataString = "{\"familyName\": \"Malik\", \"givenName\": \"Waqar\"}"
		let profileData = profileDataString.data(using: .utf8)
		XCTAssertNotNil(profileData)
		let multiformData = MultipartFormData(boundary: boundray)
		multiformData.append(data: profileData!, withName: "Profile", mimeType: .json)
		let imageDataString = "{\"homePage\": \"https://www.apple.com\"}"
		let imageString = imageDataString.data(using: .utf8)?.base64EncodedData()
		XCTAssertNotNil(imageString)
		multiformData.append(data: imageString!, withName: "Image", mimeType: "application/octet-stream")
		//        let url = Bundle.module.url(forResource: "announce-hero", withExtension: "jpeg", subdirectory: "TestData")
		//        XCTAssertNotNil(url)
		//        try multiformData.append(fileURL: url!, withName: "Image", fileName: "announce-hero", mimeType: URLRequest.ContentType.jpeg)
		let encoedData = try multiformData.encoded()
		try encoedData.write(to: URL(fileURLWithPath: "/tmp/MultipartFormData.txt"))
	}
}
