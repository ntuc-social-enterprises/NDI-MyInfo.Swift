//
//  MyInfoTokenRequest.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import AppAuth
import Foundation

class MyInfoTokenRequest: OIDTokenRequest {
  let authHeader: String?

  init(configuration: OIDServiceConfiguration,
       grantType: String,
       authorizationCode code: String?,
       redirectURL: URL?,
       clientID: String,
       clientSecret: String?,
       scope: String?,
       refreshToken: String?,
       codeVerifier: String?,
       additionalParameters: [String: String]?,
       authHeader: String?) {
    self.authHeader = authHeader
    super.init(configuration: configuration,
               grantType: grantType,
               authorizationCode: code,
               redirectURL: redirectURL,
               clientID: clientID,
               clientSecret: clientSecret,
               scope: scope,
               refreshToken: refreshToken,
               codeVerifier: codeVerifier,
               additionalParameters: additionalParameters)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func urlRequest() -> URLRequest {
    var request = super.urlRequest()
    request.setValue(authHeader, forHTTPHeaderField: "Authorization")
    return request
  }
}
