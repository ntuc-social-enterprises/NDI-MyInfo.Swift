//
//  MyInfoAuthoriseTests.swift
//  MyInfo
//
//  Created by Li Hao Lai on 14/12/20.
//

@testable import MyInfo
import XCTest

class MyInfoAuthoriseTests: XCTestCase {
  func testMyInfoAuthorise() {
    let attributes = "name,dob"
    let purpose = "MyInfo Unit Test"
    let serviceProvider = MyInfoServiceProvider(in: Bundle(for: Self.self))

    let authorise: Authorise = serviceProvider.service
    _ = authorise.setAttributes(attributes)
      .setPurpose(purpose)

    XCTAssertEqual(serviceProvider.service.attributes, attributes)
    XCTAssertEqual(serviceProvider.service.purpose, purpose)
  }
}
