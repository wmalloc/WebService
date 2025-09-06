//
//  WebService.swift
//  WebService
//
//  Created by Waqar Malik on 10/7/24.
//

import Foundation
import HTTPRequestable
import HTTPTypes

final class WebService: HTTPTransferable, @unchecked Sendable {
  let session: URLSession

  var requestModifiers: [any HTTPRequestModifier] = []
  var interceptors: [any  HTTPInterceptor] = []

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
