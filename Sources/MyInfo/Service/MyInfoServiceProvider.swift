//
//  MyInfoServiceProvider.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import Foundation

final class MyInfoServiceProvider {
  let oAuth2Config: OAuth2Config

  let service: MyInfoService

  let storage: MyInfoStorage

  let apiClient: APIClient

  init() {
    oAuth2Config = MyInfoServiceProvider.clientConfiguration()!
    storage = MyInfoStorage()
    apiClient = APIClient(storage: storage)
    service = MyInfoService(oAuth2Config: oAuth2Config, apiClient: apiClient, storage: storage)
  }

  static func clientConfiguration(in bundle: Bundle = Bundle.main) -> OAuth2Config? {
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
