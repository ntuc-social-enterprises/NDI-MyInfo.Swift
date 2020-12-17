//
//  OAuth2Config.swift
//  MyInfo
//
//  Created by Li Hao Lai on 11/12/20.
//

import Foundation

public struct OAuth2Config: Codable, Hashable {
  let issuer: String
  public let clientId: String
  let clientSecret: String
  let redirectURI: URL
  let authorizationURL: URL
  let tokenURL: URL

  enum CodingKeys: String, CodingKey {
    case issuer = "Issuer"
    case clientId = "ClientID"
    case clientSecret = "ClientSecret"
    case redirectURI = "RedirectURI"
    case authorizationURL = "AuthorizationURL"
    case tokenURL = "TokenURL"
  }
}
