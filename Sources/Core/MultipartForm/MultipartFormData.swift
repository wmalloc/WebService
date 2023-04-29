//
//  MultipartFormData.swift
//
//  Created by Waqar Malik on 1/15/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import CoreServices
import Foundation
import URLRequestable

open class MultipartFormData {
	public let boundary: String

	open lazy var contentType: String = "multipart/form-data; boundary=\(self.boundary)"

	public var contentLength: UInt64 {
		bodyParts.reduce(0) {
			$0 + $1.bodyContentLength
		}
	}

	public init(fileManager: FileManager = .default, boundary: String = UUID().uuidString.replacingOccurrences(of: "-", with: "")) {
		self.fileManager = fileManager
		self.boundary = "---------------------------" + boundary
	}

	let fileManager: FileManager
	public private(set) var bodyParts: [MultipartFormBodyPart] = []

	public func append(stream: InputStream, withLength length: UInt64, headers: HTTPHeaders) {
		let bodyPart = MultipartFormBodyPart(headers: headers, bodyStream: stream, bodyContentLength: length)
		bodyParts.append(bodyPart)
	}

	public func append(stream: InputStream, withLength length: UInt64, name: String, fileName: String, mimeType: String) {
		let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
		append(stream: stream, withLength: length, headers: headers)
	}

	public func append(data: Data, withName name: String, fileName: String? = nil, mimeType: String? = nil) {
		let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
		let stream = InputStream(data: data)
		let length = UInt64(data.count)
		append(stream: stream, withLength: length, headers: headers)
	}

	public func append(fileURL: URL, withName name: String) throws {
		let fileName = fileURL.lastPathComponent
		let pathExtension = fileURL.pathExtension

		if !fileName.isEmpty, !pathExtension.isEmpty {
			let mime = mimeType(forPathExtension: pathExtension)
			try append(fileURL: fileURL, withName: name, fileName: fileName, mimeType: mime)
		} else {
			throw MultipartFormError.invalidFilename(fileURL)
		}
	}

	public func append(fileURL: URL, withName name: String, fileName: String, mimeType: String) throws {
		let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)

		guard fileURL.isFileURL else {
			throw MultipartFormError.badURL(fileURL)
		}

		let isReachable = try fileURL.checkPromisedItemIsReachable()
		if isReachable == false {
			throw MultipartFormError.accessDenied(fileURL)
		}

		var isDirectory: ObjCBool = false
		let path = fileURL.path
		guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory), !isDirectory.boolValue else {
			throw MultipartFormError.fileIsDirectory(fileURL)
		}

		let bodyContentLength = try fileManager.fileSize(atPath: path)
		guard let stream = InputStream(url: fileURL) else {
			throw MultipartFormError.streamCreation(fileURL)
		}

		append(stream: stream, withLength: bodyContentLength, headers: headers)
	}

	public func encoded() throws -> Data {
		var encoded = Data()
		encoded.append(initialBoundaryData)
		var isInitial = true
		try bodyParts.forEach { bodyPart in
			if isInitial {
				isInitial = false
			} else {
				encoded.append(interstitialBoundaryData)
			}
			try encoded.append(bodyPart.encoded())
		}
		encoded.append(finalBoundaryData)
		return encoded
	}

	public func write(encodedDataTo fileURL: URL) throws {
		if fileManager.fileExists(atPath: fileURL.path) {
			throw MultipartFormError.fileAlreadyExists(fileURL)
		} else if !fileURL.isFileURL {
			throw MultipartFormError.invalidFilename(fileURL)
		}

		guard let outputStream = OutputStream(url: fileURL, append: false) else {
			throw MultipartFormError.streamCreation(fileURL)
		}

		outputStream.open()
		defer {
			outputStream.close()
		}

		var isInitial = true
		try initialBoundaryData.write(to: outputStream)
		for bodyPart in bodyParts {
			if isInitial {
				isInitial = false
			} else {
				try interstitialBoundaryData.write(to: outputStream)
			}
			try bodyPart.write(to: outputStream)
		}

		try finalBoundaryData.write(to: outputStream)
	}
}

extension MultipartFormData {
	var initialBoundary: String {
		MultipartFormBoundaryType.boundary(forBoundaryType: .initial, boundary: boundary)
	}

	var initialBoundaryData: Data {
		Data(initialBoundary.utf8)
	}

	var interstitialBoundary: String {
		MultipartFormBoundaryType.boundary(forBoundaryType: .interstitial, boundary: boundary)
	}

	var interstitialBoundaryData: Data {
		Data(interstitialBoundary.utf8)
	}

	var finalBoundary: String {
		MultipartFormBoundaryType.boundary(forBoundaryType: .final, boundary: boundary)
	}

	var finalBoundaryData: Data {
		Data(finalBoundary.utf8)
	}

	func contentHeaders(withName name: String, fileName: String? = nil, mimeType: String? = nil) -> HTTPHeaders {
		var disposition = "form-data; name=\"\(name)\""
		if let fileName {
			disposition += "; filename=\"\(fileName)\""
		}

		var headers: HTTPHeaders = [.contentDisposition(disposition)]
		if let mimeType = mimeType {
			headers = headers.add(.contentType(mimeType))
		}
		return headers
	}
}

extension MultipartFormData {
	func mimeType(forPathExtension pathExtension: String) -> String {
		if let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
		   let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
		{
			return contentType as String
		}
		return .octetStream
	}
}
