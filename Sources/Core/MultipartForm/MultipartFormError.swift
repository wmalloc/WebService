//
//  File.swift
//
//
//  Created by Waqar Malik on 1/17/23.
//

import Foundation

public enum MultipartFormError: Error {
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
}
