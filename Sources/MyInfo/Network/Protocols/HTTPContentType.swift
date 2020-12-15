//
//  HTTPContentType.swift
//  Radix
//
//  Created by Ryne Cheow on 28/3/19.
//  Copyright © 2020 NE Digital. All rights reserved.
//

import Foundation

/// MIME type
///
/// See https://tools.ietf.org/html/rfc6838
typealias MIMEType = String

/// Defines HTTP content type based on standard MIMETypes
enum HTTPContentType: Hashable, RawRepresentable, Comparable {
  static func <(lhs: HTTPContentType, rhs: HTTPContentType) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

  /// JSON type: `application/json`
  case json

  /// URL encoded form: `application/x-www-form-urlencoded`
  case form

  /// Multipart form data: `multipart/form-data; boundary=`
  case multipart(String)

  typealias RawValue = MIMEType

  init?(rawValue: HTTPContentType.RawValue) {
    switch rawValue {
    case "application/json": self = .json
    case "application/x-www-form-urlencoded": self = .form
    default: return nil
    }
  }

  var rawValue: HTTPContentType.RawValue {
    switch self {
    case .json: return "application/json"
    case .form: return "application/x-www-form-urlencoded"
    case let .multipart(boundary): return "multipart/form-data; boundary=\(boundary)"
    }
  }
}

/// HTTP method definitions.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
enum HTTPMethod: String {
  /// Defines `CONNECT` HTTP method
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  case connect = "CONNECT"

  /// Defines `DELETE` HTTP method
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  case delete = "DELETE"

  /// Defines `GET` HTTP method
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  case get = "GET"

  /// Defines `HEAD` HTTP method
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  case head = "HEAD"

  /// Defines `OPTIONS` HTTP method
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  case options = "OPTIONS"

  /// Defines `PATCH` HTTP method
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  case patch = "PATCH"

  /// Defines `POST` HTTP method
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  case post = "POST"

  /// Defines `PUT` HTTP method
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  case put = "PUT"

  /// Defines `TRACE` HTTP method
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  case trace = "TRACE"
}
