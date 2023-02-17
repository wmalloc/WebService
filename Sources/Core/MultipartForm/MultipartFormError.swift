//
//  MultipartFormError.swift
//
//
//  Created by Waqar Malik on 1/17/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public enum MultipartFormError: LocalizedError {
	case invalidURL(URL)
	case invalidFilename(URL)
	case fileNotFound(URL, Error?)
	case fileAlreadyExists(URL)
	case accessDenied(URL)
	case fileIsDirectory(URL)
	case fileSizeNotAvailable(URL)
	case streamCreation(URL)
	case outputStreamWriteFailed(Error)
	case inputStreamReadFailed(Error)
	case inputStreamLength(String)

	public var errorDescription: String? {
		switch self {
		case .invalidURL(let url):
			return "webservice.invalid.url".localized(bundle: .module) + " " + url.absoluteString
		case .invalidFilename(let url):
			return url.absoluteString
		case .fileNotFound(let url, let error):
			return url.absoluteString + " " + (error?.localizedDescription ?? "")
		case .fileAlreadyExists(let url):
			return url.absoluteString
		case .accessDenied(let url):
			return url.absoluteString
		case .fileIsDirectory(let url):
			return url.absoluteString
		case .fileSizeNotAvailable(let url):
			return url.absoluteString
		case .streamCreation(let url):
			return url.absoluteString
		case .outputStreamWriteFailed(let error):
			return error.localizedDescription
		case .inputStreamReadFailed(let error):
			return error.localizedDescription
		case .inputStreamLength(let message):
			return message
		}
	}
}
