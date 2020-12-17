//
//  MyInfoService.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import AppAuth
import Foundation
import JWTDecode

public protocol MyInfoServiceType {
  func setAttributes(_ attributes: String) -> Self

  func setPurpose(_ purpose: String) -> Self

  func getPerson(callback: @escaping ([String: Any]?, Error?) -> Void)
}

class MyInfoService: MyInfoServiceType {
  let oAuth2Config: OAuth2Config

  let storage: MyInfoStorageType

  let apiClient: APIClient

  var attributes: String = ""

  var purpose: String = ""

  var currentAuthorizationFlow: OIDExternalUserAgentSession?

  private lazy var requestConfig: OIDServiceConfiguration = {
    OIDServiceConfiguration(authorizationEndpoint: oAuth2Config.authorizationURL,
                            tokenEndpoint: oAuth2Config.tokenURL)
  }()

  init(oAuth2Config: OAuth2Config, apiClient: APIClient, storage: MyInfoStorageType) {
    self.oAuth2Config = oAuth2Config
    self.storage = storage
    self.apiClient = apiClient
  }

  func setAttributes(_ attributes: String) -> Self {
    self.attributes = attributes
    return self
  }

  func setPurpose(_ purpose: String) -> Self {
    self.purpose = purpose
    return self
  }

  func getPerson(callback: @escaping ([String: Any]?, Error?) -> Void) {
    guard let accessToken = storage.authState?.lastTokenResponse?.accessToken,
          let sub = getSub(accessToken: accessToken)
    else {
      logger.error("Access token not found, please proceed to authorise.")
      return
    }

    apiClient.request(route: MyInfoAPIRoutable.person(sub: sub, attributes: attributes, clientId: oAuth2Config.clientId)) { result in
      do {
        let data = try result.get()
        guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
          callback(nil, APIClientError.unableToDeserialiseData)
          return
        }
        callback(json, nil)
      } catch {
        logger.error("Failed to fetch Person API: \(error.localizedDescription)")
        callback(nil, error)
      }
    }
  }

  private func getSub(accessToken: String) -> String? {
    (try? decode(jwt: accessToken))?.claim(name: "sub").rawValue as? String
  }
}

extension MyInfoService: Authorise {
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
//
//    request.externalUserAgentRequestURL()
//
//    currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: root) { [weak self] response, error in
//      if let response = response,
//         let authorizationCode = response.authorizationCode {
//        let authState = OIDAuthState(authorizationResponse: response)
//        self?.storage.setAuthState(with: authState)
//        self?.getToken(with: authorizationCode, callback: callback)
//      } else {
//        callback(nil, error)
//      }
//    }
    let authState = OIDAuthState(authorizationResponse: OIDAuthorizationResponse(request: request,
                                                                                 parameters: [:]))
    storage.setAuthState(with: authState)
    getToken(with: "30a722e60ea1969eae2a82abfb57031051c33d7f", callback: callback)
  }

  private func getToken(with authorizationCode: String, callback: @escaping (String?, Error?) -> Void) {
    let authState = storage.authState
    let tokenRequest = MyInfoTokenRequest(configuration: requestConfig,
                                          grantType: "authorization_code",
                                          authorizationCode: authorizationCode,
                                          redirectURL: oAuth2Config.redirectURI,
                                          clientID: oAuth2Config.clientId,
                                          clientSecret: oAuth2Config.clientSecret,
                                          scope: nil,
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
