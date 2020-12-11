//
//  Authorise.swift
//  MyInfo
//
//  Created by Li Hao Lai on 12/12/20.
//

import AppAuth
import Foundation

public protocol Authorise {
  func login(from root: UIViewController, callback: @escaping (Error?) -> Void)
}

class MyInfoAuthorise: Authorise {
  let oAuth2Config: OAuth2Config

  let requestConfig: OIDServiceConfiguration

  let request: OIDAuthorizationRequest

  var currentAuthorizationFlow: OIDExternalUserAgentSession?

  init(oAuth2Config: OAuth2Config, attributes: String, purpose: String) {
    self.oAuth2Config = oAuth2Config
    requestConfig = OIDServiceConfiguration(authorizationEndpoint: oAuth2Config.authorizationURL,
                                            tokenEndpoint: oAuth2Config.tokenURL)
    request = OIDAuthorizationRequest(configuration: requestConfig,
                                      clientId: oAuth2Config.clientId,
                                      clientSecret: oAuth2Config.clientSecret,
                                      scopes: [],
                                      redirectURL: oAuth2Config.redirectURI,
                                      responseType: OIDResponseTypeCode,
                                      additionalParameters: [
                                        "attributes": attributes,
                                        "purpose": purpose
                                      ])
  }

  func login(from root: UIViewController, callback: @escaping (Error?) -> Void) {
    request.externalUserAgentRequestURL()

    currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: root) { _, error in
      callback(error)
    }
  }
}
