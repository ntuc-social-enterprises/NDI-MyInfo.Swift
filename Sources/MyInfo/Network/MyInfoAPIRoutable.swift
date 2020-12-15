//
//  MyInfoAPIRoutable.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import Foundation

enum MyInfoAPIRoutable: APIRoutable {
  case token(authCode: String, oAuth2Config: OAuth2Config)
//  case person

  var path: String {
    switch self {
    case .token:
      return "/com/v3/token"
    }
  }

  var parameters: [String: Any]? {
    switch self {
    case let .token(authCode, oAuth2Config):
      return [
        "code": authCode,
        "client_secret": oAuth2Config.clientSecret,
        "client_id": oAuth2Config.clientId,
        "redirect_uri": oAuth2Config.redirectURI.absoluteString,
        "grant_type": "authorization_code",
        "state": "123"
      ]
    }
  }

  var body: Data? {
    nil
  }

  var method: HTTPMethod {
    switch self {
    case .token:
      return .post
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
    case .token:
      #if DEBUG
        return [HTTPHeader.contentType(HTTPContentType.form)]
      #else
        // TODO: Signed Authorization header
        return [HTTPHeader.contentType(HTTPContentType.form)]
      #endif
    }
  }

  var query: [String: String]? {
    nil
  }
}
