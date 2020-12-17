//
//  MyInfoAPIRoutable.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import Foundation

enum MyInfoAPIRoutable: APIRoutable {
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
    #if DEBUG
      return "https://sandbox.api.myinfo.gov.sg"
    #else
      return "https://api.myinfo.gov.sg"
    #endif
  }

  var headers: [HTTPHeader] {
    switch self {
    case .person:
      #if DEBUG
        return [HTTPHeader.contentType(HTTPContentType.form)]
      #else
        // TODO: Signed Authorization header
        return [HTTPHeader.contentType(HTTPContentType.form)]
      #endif
    }
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
