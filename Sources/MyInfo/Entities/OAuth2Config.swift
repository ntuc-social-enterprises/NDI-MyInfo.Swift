//
//  OAuth2Config.swift
//  MyInfo
//
//  Created by Li Hao Lai on 11/12/20.
//

import Foundation

public enum Environment: String, Codable {
  case sandbox
  case test
  case prod = "production"
}

public struct OAuth2Config: Codable, Hashable {
  let issuer: String
  public let clientId: String
  let clientSecret: String
  let redirectURI: URL
  let authorizationURL: URL
  let tokenURL: URL
  public let environment: Environment
  let privateKeySecret: String

  enum CodingKeys: String, CodingKey {
    case issuer = "Issuer"
    case clientId = "ClientID"
    case clientSecret = "ClientSecret"
    case redirectURI = "RedirectURI"
    case authorizationURL = "AuthorizationURL"
    case tokenURL = "TokenURL"
    case environment = "Environment"
    case privateKeySecret = "PrivateKeySecret"
  }
}
