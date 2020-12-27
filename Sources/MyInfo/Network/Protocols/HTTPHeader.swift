//
//  HTTPHeader.swift
//  Authentication
//
//  Created by Ryne Cheow on 28/3/19.
//  Copyright © 2020 NE Digital. All rights reserved.
//

import Foundation

/// List of default HTTP Header provided by Radix
enum HTTPHeader: Equatable {
  static func ==(lhs: HTTPHeader, rhs: HTTPHeader) -> Bool {
    switch (lhs, rhs) {
    case let (.contentDisposition(lhs), .contentDisposition(rhs)):
      return lhs == rhs
    case let (.accept(lhs), .accept(rhs)):
      return lhs.sorted() == rhs.sorted()
    case let (.contentType(lhs), .contentType(rhs)):
      return lhs == rhs
    case let (.authorization(lhs), .authorization(rhs)):
      return lhs == rhs
    case (let .custom(lhsKey, lhsValue), let .custom(rhsKey, rhsValue)):
      return lhsKey == rhsKey && lhsValue == rhsValue
    default:
      return false
    }
  }

  /// Content Disposition header
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition
  case contentDisposition(String)

  /// Accept header
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept
  case accept([HTTPContentType])

  /// Content-Type header
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type
  case contentType(HTTPContentType)

  /// Authorization header
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization
  case authorization(String)

  /// Custom HTTP header with value
  case custom(String, String)

  /// Header key
  var key: String {
    switch self {
    case .contentDisposition:
      return "Content-Disposition"
    case .accept:
      return "Accept"
    case .contentType:
      return "Content-Type"
    case .authorization:
      return "Authorization"
    case let .custom(key, _):
      return key
    }
  }

  /// Header value
  var value: String {
    switch self {
    case let .contentDisposition(disposition):
      return disposition
    case let .accept(types):
      let typeStrings = types.map { $0.rawValue }.sorted()
      return typeStrings.joined(separator: ", ")
    case let .contentType(type):
      return type.rawValue
    case let .authorization(token):
      return token
    case let .custom(_, value):
      return value
    }
  }
}
