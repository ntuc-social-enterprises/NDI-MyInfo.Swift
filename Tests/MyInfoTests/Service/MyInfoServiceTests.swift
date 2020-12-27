//
//  MyInfoServiceTests.swift
//  MyInfoTests
//
//  Created by Li Hao Lai on 22/12/20.
//

import CryptoSwift
@testable import MyInfo
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

class MyInfoServiceTests: XCTestCase {
  let serviceProvider = MyInfoServiceProvider(in: Bundle(for: MyInfoServiceTests.self))

  var mainStub: HTTPStubsDescriptor?

  override func setUp() {
    super.setUp()

    mainStub = stub(condition: isHost("test.api.myinfo.gov.sg")) { request -> HTTPStubsResponse in
      guard let path = request.url?.path else {
        return HTTPStubsResponse(jsonObject: [:], statusCode: 400, headers: nil)
      }

      if path.contains("/com/v3/person") {
        return HTTPStubsResponse(data: EncryptUtil.mockEncryptedPersonData(), statusCode: 200, headers: nil)
      }

      switch path {
      case "/com/v3/token":
        return HTTPStubsResponse(fileAtPath: Bundle(for: Self.self).path(forResource: "token", ofType: "json") ?? "", statusCode: 200, headers: nil)
      default:
        return HTTPStubsResponse(jsonObject: [:], statusCode: 400, headers: nil)
      }
    }
  }

  override func tearDown() {
    super.tearDown()
    HTTPStubs.removeStub(mainStub!)
  }

  func testGetToken() {
    let expect = expectation(description: "Wait for token")

    serviceProvider.service.getToken(with: "abc123") { accessToken, error in
      XCTAssertNotNil(accessToken)
      XCTAssertNil(error)
      expect.fulfill()
    }

    waitForExpectations(timeout: 15.0, handler: nil)
  }

  func testGetPerson() {
    let state = MyInfoStorageTests.getState(oAuth2Config: serviceProvider.oAuth2Config)
    serviceProvider.storage.setAuthState(with: state)

    let expect = expectation(description: "Wait for person")

    serviceProvider.service.getToken(with: "abc123") { _, error in
      self.serviceProvider.service.getPerson { json, error in
        XCTAssertEqual(json?.getName(), "TAN XIAO HUI")
        XCTAssertEqual(json?.getDOB(), "1958-05-17")
        XCTAssertEqual(json?.getSexCode(), "F")
        XCTAssertEqual(json?.getSexDesc(), "FEMALE")
        XCTAssertEqual(json?.getNationalityCode(), "SG")
        XCTAssertEqual(json?.getNationalityDesc(), "SINGAPORE CITIZEN")
        XCTAssertNil(error)
        expect.fulfill()
      }
    }

    waitForExpectations(timeout: 15.0, handler: nil)
  }
}
