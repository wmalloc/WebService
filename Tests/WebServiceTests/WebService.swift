//
//  WebService.swift
//  WebService
//
//  Created by Waqar Malik on 10/7/24.
//

import Foundation
import HTTPTypes
import HTTPRequestable

class WebService: HTTPTransferable, @unchecked Sendable {
  var requestInterceptors: [any RequestInterceptor] = []
  var responseInterceptors: [any ResponseInterceptor] = []

  let session: URLSession

  static var sessionConfiguration: URLSessionConfiguration {
    let config = URLSessionConfiguration.default
    config.httpFields = HTTPFields.defaultHeaders
    config.requestCachePolicy = .useProtocolCachePolicy
    return config
  }

  required init(session: URLSession = .shared) {
    self.session = session
  }
}
