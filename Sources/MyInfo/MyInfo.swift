//
//  MyInfo.swift
//  MyInfo
//
//  Created by Li Hao Lai on 11/12/20.
//

import UIKit

public class MyInfo {
  static let shared = MyInfo()

  let serviceProvider: MyInfoServiceProvider

  init() {
    serviceProvider = MyInfoServiceProvider()
  }

  public static func authorise() -> Authorise {
    shared.serviceProvider.service
  }
}
