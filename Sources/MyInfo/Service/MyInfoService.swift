//
//  MyInfoService.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import AppAuth
import Foundation

class MyInfoService {
  let oAuth2Config: OAuth2Config

  let storage: MyInfoStorageType

  var attributes: String = ""

  var purpose: String = ""

  var currentAuthorizationFlow: OIDExternalUserAgentSession?

  private lazy var requestConfig: OIDServiceConfiguration = {
    OIDServiceConfiguration(authorizationEndpoint: oAuth2Config.authorizationURL,
                            tokenEndpoint: oAuth2Config.tokenURL)
  }()

  init(oAuth2Config: OAuth2Config, storage: MyInfoStorageType) {
    self.oAuth2Config = oAuth2Config
    self.storage = storage
  }
}

extension MyInfoService: Authorise {
  func setAttributes(_ attributes: String) -> Self {
    self.attributes = attributes
    return self
  }

  func setPurpose(_ purpose: String) -> Self {
    self.purpose = purpose
    return self
  }

  func login(from root: UIViewController, callback: @escaping (String?, Error?) -> Void) {
    let request = OIDAuthorizationRequest(configuration: requestConfig,
                                          clientId: oAuth2Config.clientId,
                                          clientSecret: oAuth2Config.clientSecret,
                                          scopes: [],
                                          redirectURL: oAuth2Config.redirectURI,
                                          responseType: OIDResponseTypeCode,
                                          additionalParameters: [
                                            "attributes": attributes,
                                            "purpose": purpose
                                          ])

    request.externalUserAgentRequestURL()

    currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: root) { [weak self] response, error in
      if let response = response,
         let authorizationCode = response.authorizationCode {
        let authState = OIDAuthState(authorizationResponse: response)
        self?.storage.setAuthState(with: authState)
        self?.getToken(with: authorizationCode, callback: callback)
      } else {
        callback(nil, error)
      }
    }
//    getToken(with: "2694dbf4cb4c6f10684b6ca0119a51e40d71e5aa", callback: callback)
  }

  private func getToken(with authorizationCode: String, callback: @escaping (String?, Error?) -> Void) {
    let authState = storage.authState
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
      self?.storage.update(with: response, error: error)
      callback(response?.accessToken, error)
    }
  }
}
