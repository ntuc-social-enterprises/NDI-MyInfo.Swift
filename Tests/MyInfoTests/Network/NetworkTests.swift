//
//  NetwrokTests.swift
//  AliasTests
//
//  Created by James Lai on 11/3/20.
//  Copyright © 2020 NE Digital. All rights reserved.
//

@testable import MyInfo
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

extension HTTPHeader {
  var fullHeaderValue: String {
    return "\(key): \(value)"
  }
}

final class NetworkTest: XCTestCase {
  static var allTests: [(String, (NetworkTest) -> () -> Void)] = [
    ("testHTTPContentType", testHTTPContentType),
    ("testHeaderValue", testHeaderValue)
  ]

  var mainStub: HTTPStubsDescriptor?

  let serviceProvider = MyInfoServiceProvider(in: Bundle(for: NetworkTest.self))

  override func setUp() {
    super.setUp()

    mainStub = stub(condition: isHost("google.com")) { request -> HTTPStubsResponse in
      guard let path = request.url?.path else {
        return HTTPStubsResponse(jsonObject: [:], statusCode: 400, headers: nil)
      }

      var responseBody: [String: Any] = [:]

      switch path {
      case "/api/mockRequest":
        responseBody = [
          "title": "mockTitle",
          "message": "mockMessage"
        ]
      default:
        return HTTPStubsResponse(jsonObject: [:], statusCode: 400, headers: nil)
      }

      return HTTPStubsResponse(jsonObject: responseBody, statusCode: 200, headers: nil)
    }
  }

  override func tearDown() {
    super.tearDown()
    HTTPStubs.removeStub(mainStub!)
  }

  func testHTTPContentType() {
    let tokenOne = "Bearer 123456"
    let tokenOneEqual = "Bearer 123456"
    let tokenTwo = "Bearer 789012"

    XCTAssertEqual(HTTPContentType(rawValue: "application/json"), .json)
    XCTAssertEqual(HTTPContentType(rawValue: "application/x-www-form-urlencoded"), .form)

    // Content type
    XCTAssertEqual(HTTPHeader.contentType(.json), HTTPHeader.contentType(.json))
    XCTAssertEqual(HTTPHeader.contentType(.form), HTTPHeader.contentType(.form))
    XCTAssertNotEqual(HTTPHeader.contentType(.json), HTTPHeader.contentType(.form))

    XCTAssertEqual(HTTPHeader.contentType(.multipart("boundary")),
                   HTTPHeader.contentType(.multipart("boundary")))
    XCTAssertNotEqual(HTTPHeader.contentType(.multipart("boundary")),
                      HTTPHeader.contentType(.multipart("boundary2")))

    // Accept
    XCTAssertEqual(HTTPHeader.accept([.json]), HTTPHeader.accept([.json]))
    XCTAssertEqual(HTTPHeader.accept([.multipart("boundary"), .json, .form]),
                   HTTPHeader.accept([.form, .multipart("boundary"), .json]))
    XCTAssertEqual(HTTPHeader.accept([]), HTTPHeader.accept([]))
    XCTAssertNotEqual(HTTPHeader.accept([.form]), HTTPHeader.accept([]))

    // Content Disposition
    XCTAssertEqual(HTTPHeader.contentDisposition("value"),
                   HTTPHeader.contentDisposition("value"))
    XCTAssertNotEqual(HTTPHeader.contentDisposition("value"),
                      HTTPHeader.contentDisposition("value2"))

    // Authorization
    XCTAssertEqual(HTTPHeader.authorization(tokenOne),
                   HTTPHeader.authorization(tokenOneEqual))
    XCTAssertNotEqual(HTTPHeader.authorization(tokenOne),
                      HTTPHeader.authorization(tokenTwo))

    // Authorization
    XCTAssertEqual(HTTPHeader.custom("key 1", "key 2"),
                   HTTPHeader.custom("key 1", "key 2"))
    XCTAssertNotEqual(HTTPHeader.custom("key 1", "key 2"),
                      HTTPHeader.custom("key 2", "key 2"))
    XCTAssertNotEqual(HTTPHeader.custom("key 1", "key 2"),
                      HTTPHeader.custom("key 2", "key 1"))
  }

  func testHeaderValue() {
    let tokenOne = "Bearer 123456"

    XCTAssertEqual(HTTPHeader.contentType(.json).fullHeaderValue,
                   "Content-Type: application/json")

    XCTAssertEqual(HTTPHeader.custom("key 1", "key 2").fullHeaderValue,
                   "key 1: key 2")

    XCTAssertEqual(HTTPHeader.authorization(tokenOne).fullHeaderValue,
                   "Authorization: Bearer 123456")

    XCTAssertEqual(HTTPHeader.contentDisposition("123").fullHeaderValue,
                   "Content-Disposition: 123")

    XCTAssertEqual(HTTPHeader.accept([.multipart("boundary"), .json, .form]).fullHeaderValue,
                   "Accept: application/json, application/x-www-form-urlencoded, multipart/form-data; boundary=boundary")
  }

  func testAPIClient() {
    let expectation = self.expectation(description: "Expect result")

    serviceProvider.apiClient.request(route: MockRoutes.mockRequest, for: MockRepsonse.self) { result in
      XCTAssertNotNil(try? result.get())
      expectation.fulfill()
    }

    waitForExpectations(timeout: 15, handler: nil)
  }

  func testAPIClientFailure() {
    let expectation = self.expectation(description: "Expect result")

    serviceProvider.apiClient.request(route: MockRoutes.mockFailure, for: MockRepsonse.self) { result in
      guard case .failure = result else {
        return
      }

      expectation.fulfill()
    }

    waitForExpectations(timeout: 15, handler: nil)
  }
}
