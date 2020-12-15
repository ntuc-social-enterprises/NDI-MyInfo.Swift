//
//  APIRoutable.swift
//  MyInfo
//
//  Created by Li Hao Lai on 14/12/20.
//

import Foundation

enum APIRoutableError: Swift.Error {
  case invalidURL(url: String)
  case parameterEncodingFailed(error: Error)
}

/// API Route definition.
///
///
protocol APIRoutable {
  /// Path for each API
  var path: String { get }

  /// Body parameter for HTTP call (e.g. JSON POST body)
  var parameters: [String: Any]? { get }

  /// Body parameter for HTTP call (e.g. JSON POST body)
  var body: Data? { get }

  /// HTTP Method will use for each API
  var method: HTTPMethod { get }

  /// Base URL for each API
  var urlHost: String { get }

  /// Additional headers for each API
  var headers: [HTTPHeader] { get }

  /// Query parameters
  var query: [String: String]? { get }

  /// Cache policy for API, defaults to `.useProtocolCachePolicy`
  var cachePolicy: URLRequest.CachePolicy { get }

  /// Timeout interval for API in seconds, defaults to 60 seconds.
  var timeoutInterval: TimeInterval { get }

  /// Should authenticate
  var shouldAuthenticate: Bool { get }
}

extension APIRoutable {
  /// Should authenticate
  var shouldAuthenticate: Bool { return false }

  /// Cache policy for API, defaults to `.useProtocolCachePolicy`
  var cachePolicy: URLRequest.CachePolicy { return .useProtocolCachePolicy }

  /// Timeout interval for API in seconds, defaults to 60 seconds.
  var timeoutInterval: TimeInterval { return 60 }

  /// Convert `APIRouter` into `URLRequest`
  func asURLRequest() throws -> URLRequest {
    guard let url = URL(string: urlHost),
          let apiUrl = URL(string: path, relativeTo: url),
          var urlComponents = URLComponents(url: apiUrl, resolvingAgainstBaseURL: true)
    else {
      logger.error("Invalid URL: \(path)")
      throw APIRoutableError.invalidURL(url: path)
    }

    // HTTP query items
    urlComponents.queryItems = query?.map { URLQueryItem(name: $0, value: $1) }

    guard let urlComponentsURL = urlComponents.url else {
      throw APIRoutableError.invalidURL(url: path)
    }

    var urlRequest = URLRequest(url: urlComponentsURL,
                                cachePolicy: cachePolicy,
                                timeoutInterval: timeoutInterval)
    // HTTP Method
    urlRequest.httpMethod = method.rawValue

    // Common Headers
    let commonHeaders = [
      HTTPHeader.accept([HTTPContentType.json])
    ]

    // Additinal Headers from Router
    let allHeaders = (commonHeaders + headers)
    for header in allHeaders {
      urlRequest.setValue(header.value,
                          forHTTPHeaderField: header.key)
    }

    // Body and Parameters
    if let body = body {
      urlRequest.httpBody = body
    } else if let parameters = parameters {
      if allHeaders.contains(HTTPHeader.contentType(HTTPContentType.form)) {
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = parameters.map { key, value -> URLQueryItem in
          .init(name: key, value: value as? String)
        }
        urlRequest.httpBody = requestBodyComponents.query?.data(using: .utf8)
      } else if allHeaders.contains(HTTPHeader.contentType(HTTPContentType.json)) {
        do {
          urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters,
                                                           options: [])
        } catch {
          logger.error("Parameter encoding failed for: \(parameters)")
          throw APIRoutableError.parameterEncodingFailed(error: error)
        }
      }
    }

    logger.info("URL request constructed for \(urlRequest.debugDescription)")
    return urlRequest
  }
}

extension URLRequest {
  var curlString: String {
    // Logging URL requests in whole may expose sensitive data,
    // or open up possibility for getting access to your user data,
    // so make sure to disable this feature for production builds!
    #if !DEBUG
      return ""
    #else
      var result = "curl -k "

      if let method = httpMethod {
        result += "-X \(method) \\\n"
      }

      if let headers = allHTTPHeaderFields {
        for (header, value) in headers {
          result += "-H \"\(header): \(value)\" \\\n"
        }
      }

      if let body = httpBody, !body.isEmpty, let string = String(data: body, encoding: .utf8), !string.isEmpty {
        result += "-d '\(string)' \\\n"
      }

      if let url = url {
        result += url.absoluteString
      }

      return result
    #endif
  }
}
