//
//  MyInfoStorageTests.swift
//  MyInfo
//
//  Created by Li Hao Lai on 22/12/20.
//

import AppAuth
@testable import MyInfo
import XCTest

class MyInfoStorageTests: XCTestCase {
  func testMyInfoStorage() {
    let serviceProvider = MyInfoServiceProvider(in: Bundle(for: Self.self))
    let oAuth2Config = serviceProvider.oAuth2Config
    let state = MyInfoStorageTests.getState(oAuth2Config: oAuth2Config)

    let storage = serviceProvider.storage
    XCTAssertNil(storage.authState)

    storage.setAuthState(with: state)
    XCTAssertNotNil(storage.authState)
  }

  static func getState(oAuth2Config: OAuth2Config) -> OIDAuthState {
    let requestConfig = OIDServiceConfiguration(authorizationEndpoint: oAuth2Config.authorizationURL,
                                                tokenEndpoint: oAuth2Config.tokenURL)
    let request = OIDAuthorizationRequest(configuration: requestConfig,
                                          clientId: oAuth2Config.clientId,
                                          clientSecret: oAuth2Config.clientSecret,
                                          scopes: [],
                                          redirectURL: oAuth2Config.redirectURI,
                                          responseType: OIDResponseTypeCode,
                                          additionalParameters: [
                                            "attributes": "name,sex,dob,nationality",
                                            "purpose": "Unit test"
                                          ])
    let response = OIDAuthorizationResponse(request: request, parameters: [:])
    return OIDAuthState(authorizationResponse: response)
  }
}
