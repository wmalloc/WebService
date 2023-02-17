//
//  MultipartFormError.swift
//
//
//  Created by Waqar Malik on 1/17/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public enum MultipartFormError: LocalizedError {
	case badURL(URL)
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
		case .badURL(let url):
			return "invalid.url".localized(bundle: .module) + " " + url.absoluteString
		case .invalidFilename(let url):
			return "invalid.filename".localized(bundle: .module)  + " " + url.absoluteString
		case .fileNotFound(let url, let error):
			return "file.notfound".localized(bundle: .module) + " " + url.absoluteString + " " + (error?.localizedDescription ?? "")
		case .fileAlreadyExists(let url):
			return "file.already.exists".localized(bundle: .module) + " " + url.absoluteString
		case .accessDenied(let url):
            return "access.denined".localized(bundle: .module) + " " + url.absoluteString
		case .fileIsDirectory(let url):
			return "file.is.directory".localized(bundle: .module) + " " + url.absoluteString
		case .fileSizeNotAvailable(let url):
			return "file.size.not.available".localized(bundle: .module) + " " + url.absoluteString
		case .streamCreation(let url):
			return "stream.creation".localized(bundle: .module) + " " + url.absoluteString
		case .outputStreamWriteFailed(let error):
			return "output.stream.write.failed".localized(bundle: .module) + " " + error.localizedDescription
		case .inputStreamReadFailed(let error):
			return "input.stream.read.failed".localized(bundle: .module) + " " + error.localizedDescription
		case .inputStreamLength(let message):
			return "input.stream.length".localized(bundle: .module) + " " + message
		}
	}
}
