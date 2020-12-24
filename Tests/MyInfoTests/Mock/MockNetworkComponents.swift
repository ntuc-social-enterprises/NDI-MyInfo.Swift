//
//  MockNetworkComponents.swift
//  Alias
//
//  Created by James Lai on 11/3/20.
//  Copyright © 2020 NE Digital. All rights reserved.
//

import Foundation
@testable import MyInfo

struct MockRepsonse: Decodable {
  let title: String
  let message: String
}

enum MockRoutes: Route {
  case mockRequest
  case mockFailure

  var path: String {
    switch self {
    case .mockRequest:
      return "/api/mockRequest"
    case .mockFailure:
      return "/api/mockFailure"
    }
  }

  var body: Data? {
    return nil
  }

  var parameters: [String: Any]? {
    return nil
  }

  var method: HTTPMethod {
    return .get
  }

  var urlHost: String {
    return "https://google.com"
  }

  var headers: [HTTPHeader] {
    return []
  }

  var query: [String: String]? {
    return nil
  }

  var shouldAuthenticate: Bool {
    return false
  }
}
