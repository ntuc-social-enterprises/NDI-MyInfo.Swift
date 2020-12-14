//
//  MyInfo.swift
//  MyInfo
//
//  Created by Li Hao Lai on 11/12/20.
//

import UIKit

public class MyInfo {
  static let shared = MyInfo()

  var currentAuthorise: Authorise?

  public static func authorise(with attributes: String, purpose: String) -> Authorise {
    let oAuth2Config = shared.clientConfiguration()!
    let authorise = MyInfoAuthorise(oAuth2Config: oAuth2Config, attributes: attributes, purpose: purpose)
    shared.currentAuthorise = authorise

    return authorise
  }

  func clientConfiguration(in bundle: Bundle = Bundle.main) -> OAuth2Config? {
    guard let path = bundle.url(forResource: "MyInfo", withExtension: "plist"),
          let configData = try? Data(contentsOf: path)
    else {
      print("Please ensure `MyInfo.plist` has added to your app(main) bundle.")
      return nil
    }

    do {
      return try PropertyListDecoder().decode(OAuth2Config.self, from: configData)
    } catch {
      print("Someting wrong when decoding your `MyInfo.plist`: \(error.localizedDescription)")
      return nil
    }
  }
}
