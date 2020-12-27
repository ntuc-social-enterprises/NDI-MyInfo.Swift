//
//  MyInfoAPIRoutable.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import Foundation

enum MyInfoAPIRoutable: APIRoutable {
  static var environment: Environment = .prod

  case person(sub: String, attributes: String, clientId: String)

  var path: String {
    switch self {
    case let .person(sub, _, _):
      return "/com/v3/person/\(sub)/"
    }
  }

  var parameters: [String: Any]? {
    nil
  }

  var body: Data? {
    nil
  }

  var method: HTTPMethod {
    switch self {
    case .person:
      return .get
    }
  }

  var urlHost: String {
    switch MyInfoAPIRoutable.environment {
    case .sandbox:
      return "https://sandbox.api.myinfo.gov.sg"
    case .test:
      return "https://test.api.myinfo.gov.sg"
    case .prod:
      return "https://api.myinfo.gov.sg"
    }
  }

  var headers: [HTTPHeader] {
    [HTTPHeader.contentType(HTTPContentType.form)]
  }

  var query: [String: String]? {
    switch self {
    case let .person(_, attributes, clientId):
      return [
        "attributes": attributes,
        "client_id": clientId
      ]
    }
  }

  var shouldAuthenticate: Bool {
    true
  }
}
