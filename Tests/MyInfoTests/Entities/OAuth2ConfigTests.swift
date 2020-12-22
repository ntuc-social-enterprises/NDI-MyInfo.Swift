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
}
