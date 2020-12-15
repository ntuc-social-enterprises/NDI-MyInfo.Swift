//
//  Authorise.swift
//  MyInfo
//
//  Created by Li Hao Lai on 12/12/20.
//

import AppAuth
import Foundation

public protocol Authorise {
  var authState: OIDAuthState? { get set }

  func login(from root: UIViewController, callback: @escaping (String?, Error?) -> Void)
}

class MyInfoAuthorise: Authorise {
  let oAuth2Config: OAuth2Config

  let requestConfig: OIDServiceConfiguration

  let request: OIDAuthorizationRequest

  var currentAuthorizationFlow: OIDExternalUserAgentSession?

  var authState: OIDAuthState?

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

  func login(from root: UIViewController, callback: @escaping (String?, Error?) -> Void) {
    request.externalUserAgentRequestURL()

    currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: root) { [weak self] response, error in
      if let response = response,
         let authorizationCode = response.authorizationCode {
        self?.authState = OIDAuthState(authorizationResponse: response)
        self?.getToken(with: authorizationCode, callback: callback)
      } else {
        callback(nil, error)
      }
    }
  }

  private func getToken(with authorizationCode: String, callback: @escaping (String?, Error?) -> Void) {
    let tokenRequest = MyInfoTokenRequest(configuration: requestConfig,
                                          grantType: "authorization_code",
                                          authorizationCode: authorizationCode,
                                          redirectURL: oAuth2Config.redirectURI,
                                          clientID: oAuth2Config.clientId,
                                          clientSecret: oAuth2Config.clientSecret,
                                          scope: authState?.scope,
                                          refreshToken: authState?.refreshToken,
                                          codeVerifier: nil,
                                          additionalParameters: [
                                            "client_secret": oAuth2Config.clientSecret,
                                            "client_id": oAuth2Config.clientId
                                          ],
                                          authHeader: nil)

    OIDAuthorizationService.perform(tokenRequest) { [weak self] response, error in
      self?.authState?.update(with: response, error: error)
      callback(response?.accessToken, error)
    }
  }
}
