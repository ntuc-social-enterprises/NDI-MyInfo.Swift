//
//  OAuth2ConfigTests.swift
//  MyInfo
//
//  Created by Li Hao Lai on 14/12/20.
//

@testable import MyInfo
import XCTest

class OAuth2ConfigTests: XCTestCase {
  func testOAuth2Conifg() {
    // This will read from MyInfoTest MyInfo.plist
    let config = MyInfoServiceProvider(in: Bundle(for: Self.self)).oAuth2Config
    XCTAssertNotNil(config)
  }

  func testOAuth2ConfigMissing() {
    let config = MyInfoServiceProvider.clientConfiguration() // load from main bundle instead of test
    XCTAssertNil(config)
  }

  func testOAuth2ConfigInvalid() {
    // modify MyInfo.plist
    guard let configUrl = Bundle(for: Self.self).path(forResource: "MyInfo", ofType: "plist") else {
      XCTFail("Fail to load MyInfo.plist")
      return
    }

    let dictionary = NSDictionary(contentsOfFile: configUrl) as? [String: Any]
    var modifiedDictionary = dictionary
    modifiedDictionary?.removeValue(forKey: "ClientID")

    let writeDictionary = NSDictionary(dictionary: modifiedDictionary ?? [:], copyItems: true)
    let result = writeDictionary.write(toFile: configUrl, atomically: true)
    debugPrint(result)

    // Check config is invalid now
    let config = MyInfoServiceProvider.clientConfiguration(in: Bundle(for: Self.self))
    XCTAssertNil(config)

    let recoverDictionary = NSDictionary(dictionary: dictionary ?? [:], copyItems: true)
    recoverDictionary.write(toFile: configUrl, atomically: true)

    // Check config is valid
    let recoverConfig = MyInfoServiceProvider.clientConfiguration(in: Bundle(for: Self.self))
    XCTAssertNotNil(recoverConfig)
  }
}
