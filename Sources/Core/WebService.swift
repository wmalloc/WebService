//
//  WebService.swift
//
//  Created by Waqar Malik on 4/28/20.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public final class WebService {
	public typealias DecodeblHandler<T: Decodable> = (Result<T, Error>) -> Void
	public typealias SerializableHandler = (Result<Any, Error>) -> Void
	public typealias DataHandler<T> = (Result<T, Error>) -> Void
	public typealias ErrorHandler = (Error?) -> Void
	public typealias DataMapper<InputType, OutputType> = (InputType) throws -> OutputType
	public typealias DataResponse = (data: Data, response: URLResponse)
	public let session: URLSession

	public init(session: URLSession = .shared) {
		self.session = session
	}
}
