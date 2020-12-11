//
//  OAuth2Config.swift
//  MyInfo
//
//  Created by Li Hao Lai on 11/12/20.
//

import Foundation

struct OAuth2Config: Codable {
  let issuer: String
  let clientId: String
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
