//
//  MyInfoStorage.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import AppAuth
import Foundation

public protocol MyInfoStateManager {
  var isAuthorized: Bool { get }
}

protocol MyInfoStorageType: MyInfoStateManager {
  var authState: OIDAuthState? { get set }

  func setAuthState(with newAuthState: OIDAuthState?)

  func update(with response: OIDTokenResponse?, error: Error?)
}

final class MyInfoStorage: MyInfoStorageType {
  enum Key: String {
    case authState = "AUTH_STATE"
  }

  var isAuthorized: Bool {
    authState?.isAuthorized ?? false
  }

  var authState: OIDAuthState?

  func setAuthState(with newAuthState: OIDAuthState?) {
    authState = newAuthState
  }

  func update(with response: OIDTokenResponse?, error: Error?) {
    authState?.update(with: response, error: error)
  }
}
