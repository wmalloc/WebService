//
//  File.swift
//  
//
//  Created by Waqar Malik on 4/15/22.
//

import Foundation

extension URLRequest {
    public enum ContentType {
        public static let formEncoded = "application/x-www-form-urlencoded"
        public static let json = "application/json"
        public static let xml = "application/xml"
        public static let textPlain = "text/plain"
        public static let html = "text/html"
        public static let css = "text/css"
        public static let octet = "application/octet-stream"
        public static let jpeg = "image/jpeg"
        public static let png = "image/png"
        public static let gif = "image/gif"
        public static let svg = "image/svg+xml"
        public static let fhirjson = "application/fhir+json"
        public static let patchjson = "application/json-patch+json"
    }
}
