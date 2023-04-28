//
//  MultipartFormBodyPart.swift
//
//  Created by Waqar Malik on 1/24/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public class MultipartFormBodyPart {
	static var streamBufferSize: Int = 1024
	public let headers: HTTPHeaders
	public let bodyStream: InputStream
	public let bodyContentLength: UInt64

	public init(headers: HTTPHeaders, bodyStream: InputStream, bodyContentLength: UInt64) {
		self.headers = headers
		self.bodyStream = bodyStream
		self.bodyContentLength = bodyContentLength
	}
}

public extension MultipartFormBodyPart {
	func encoded() throws -> Data {
		var encoded = Data()
		let headerData = encodedHeaders()
		encoded.append(headerData)
		let bodyStreamData = try encodedBodyStream()
		encoded.append(bodyStreamData)
		return encoded
	}
}

extension MultipartFormBodyPart {
	func encodedHeaders() -> Data {
		let headerText = headers.map { "\($0.name): \($0.value ?? "")\(EncodingCharacters.crlf)" }
			.joined()
			+ EncodingCharacters.crlf

		return Data(headerText.utf8)
	}

	private func encodedBodyStream() throws -> Data {
		let inputStream = bodyStream
		inputStream.open()
		defer {
			inputStream.close()
		}

		var encoded = Data()

		while inputStream.hasBytesAvailable {
			var buffer = [UInt8](repeating: 0, count: Self.streamBufferSize)
			let bytesRead = inputStream.read(&buffer, maxLength: Self.streamBufferSize)

			if let error = inputStream.streamError {
				throw MultipartFormError.inputStreamReadFailed(error)
			}

			if bytesRead > 0 {
				encoded.append(buffer, count: bytesRead)
			} else {
				break
			}
		}

		guard UInt64(encoded.count) == bodyContentLength else {
			let message = "Expect body content length \(bodyContentLength), encodedLength \(encoded.count)"
			throw MultipartFormError.inputStreamLength(message)
		}

		return encoded
	}
}

extension MultipartFormBodyPart {
	func write(to outputStream: OutputStream) throws {
		let headerData = encodedHeaders()
		try Data.write(data: headerData, to: outputStream)
		try write(bodyStreamTo: outputStream)
	}

	func write(bodyStreamTo outputStream: OutputStream) throws {
		let inputStream = bodyStream

		inputStream.open()
		defer {
			inputStream.close()
		}

		while inputStream.hasBytesAvailable {
			var buffer = [UInt8](repeating: 0, count: Self.streamBufferSize)
			let bytesRead = inputStream.read(&buffer, maxLength: Self.streamBufferSize)

			if let error = inputStream.streamError {
				throw MultipartFormError.inputStreamReadFailed(error)
			}

			if bytesRead > 0 {
				if buffer.count != bytesRead {
					buffer = Array(buffer[0 ..< bytesRead])
				}
				try Data.write(buffer: &buffer, to: outputStream)
			} else {
				break
			}
		}
	}
}
