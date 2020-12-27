//
//  MyInfo.swift
//  MyInfo
//
//  Created by Li Hao Lai on 11/12/20.
//

import UIKit

public class MyInfo {
  public static var oAuth2Config: OAuth2Config {
    shared.serviceProvider.oAuth2Config
  }

  public static var stateManager: MyInfoStateManager {
    shared.serviceProvider.storage
  }

  public static var service: MyInfoServiceType {
    shared.serviceProvider.service
  }

  static let shared = MyInfo()

  public static func authorise() -> Authorise {
    shared.serviceProvider.service
  }

  let serviceProvider: MyInfoServiceProvider

  init() {
    serviceProvider = MyInfoServiceProvider()
  }
}
