//
//  MyInfoStorage.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import AppAuth
import Foundation
import SimpleKeychain

protocol MyInfoStorageType {
  var authState: OIDAuthState? { get set }

  func getAuthState() -> OIDAuthState?

  func setAuthState(with newAuthState: OIDAuthState?)

  func update(with response: OIDTokenResponse?, error: Error?)
}

final class MyInfoStorage: MyInfoStorageType {
  enum Key: String {
    case authState = "AUTH_STATE"
  }

  var authState: OIDAuthState?

  let keychain: A0SimpleKeychain

  init(keychain: A0SimpleKeychain = A0SimpleKeychain()) {
    self.keychain = keychain
  }

  func getAuthState() -> OIDAuthState? {
    guard authState == nil else {
      return authState
    }

    guard let data = keychain.data(forKey: Key.authState.rawValue),
          let loadedAuthState = try? NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data)
    else {
      return nil
    }

    authState = loadedAuthState

    return authState
  }

  func setAuthState(with newAuthState: OIDAuthState?) {
    authState = newAuthState

    guard let storeAuthState = newAuthState else {
      keychain.deleteEntry(forKey: Key.authState.rawValue)
      return
    }

    guard let data = try? NSKeyedArchiver.archivedData(withRootObject: storeAuthState, requiringSecureCoding: true) else {
      return
    }

    keychain.setData(data, forKey: Key.authState.rawValue)
  }

  func update(with response: OIDTokenResponse?, error: Error?) {
    authState?.update(with: response, error: error)
    setAuthState(with: authState)
  }
}
