//
//  APIClientError.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import Foundation

enum APIClientError: Error {
  public enum RequestFailureReason {
    case badRequest(message: String?)
    case unauthorized(message: String?)
    case forbidden(message: String?)
    case notFound(message: String?)
    case internalServerError(message: String?)
    case badGateway(message: String?)
    case serviceUnavailable(message: String?)

    init?(code: Int, message: String? = nil) {
      switch code {
      case 400:
        self = .badRequest(message: message)
      case 401:
        self = .unauthorized(message: message)
      case 403:
        self = .forbidden(message: message)
      case 404:
        self = .notFound(message: message)
      case 500:
        self = .internalServerError(message: message)
      case 502:
        self = .badGateway(message: message)
      case 503:
        self = .serviceUnavailable(message: message)
      default:
        return nil
      }
    }

    var code: Int {
      switch self {
      case .badRequest:
        return 400
      case .unauthorized:
        return 401
      case .forbidden:
        return 403
      case .notFound:
        return 404
      case .internalServerError:
        return 500
      case .badGateway:
        return 502
      case .serviceUnavailable:
        return 503
      }
    }

    var message: String {
      switch self {
      case let .badRequest(message),
           let .unauthorized(message),
           let .forbidden(message),
           let .notFound(message),
           let .internalServerError(message),
           let .badGateway(message),
           let .serviceUnavailable(message):
        return message ?? "Response status code was unacceptable: \(code)."
      }
    }
  }

  case requestFailure(reason: RequestFailureReason)
  case unableToAuthenticate
  case accessTokenNotFound
  case nonHTTPResponse
  case invalidEmail
  case unknown(message: String)
}

extension Error {
  var asAPIClientError: APIClientError? {
    return self as? APIClientError
  }
}

extension APIClientError {
  var statusCode: Int? {
    guard case let .requestFailure(reason) = self else {
      return nil
    }

    return reason.code
  }

  var message: String? {
    guard case let .requestFailure(reason) = self else {
      return nil
    }

    return reason.message
  }

  var isRequestFailure: Bool {
    if case .requestFailure = self { return true }
    return false
  }
}
