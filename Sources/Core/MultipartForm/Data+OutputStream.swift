//
//  Data+OutputStream.swift
//
//  Created by Waqar Malik on 1/27/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

extension Data {
	func write(to outputStream: OutputStream) throws {
		try Data.write(data: self, to: outputStream)
	}

	static func write(data: Data, to outputStream: OutputStream) throws {
		var buffer = [UInt8](repeating: 0, count: data.count)
		data.copyBytes(to: &buffer, count: data.count)
		try write(buffer: &buffer, to: outputStream)
	}

	static func write(buffer: inout [UInt8], to outputStream: OutputStream) throws {
		var bytesToWrite = buffer.count

		while bytesToWrite > 0, outputStream.hasSpaceAvailable {
			let bytesWritten = outputStream.write(buffer, maxLength: bytesToWrite)
			if let error = outputStream.streamError {
				throw MultipartFormError.outputStreamWriteFailed(error)
			}
			bytesToWrite -= bytesWritten
			if bytesToWrite > 0 {
				buffer = Array(buffer[bytesWritten ..< buffer.count])
			}
		}
	}
}
