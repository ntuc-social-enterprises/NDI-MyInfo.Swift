//
//  APIClient.swift
//  MyInfo
//
//  Created by Li Hao Lai on 14/12/20.
//

import Foundation

typealias Route = APIRoutable

protocol APIClientType {
  func request(route: Route, completionHandler: @escaping (Result<Data, Error>) -> Void)

  func request<T>(route: Route, for type: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void) where T: Decodable
}

final class APIClient: APIClientType {
  private let storage: MyInfoStorage

  /// Initialise with optional `URLSessionConfiguration`, if this value is not set, `URLSessionConfiguration.default` will be used.
  init(configuration: URLSessionConfiguration = .default, storage: MyInfoStorage) {
    urlSession = URLSession(configuration: configuration)
    self.storage = storage
  }

  /// Default URLSession for API client
  let urlSession: URLSession
  ///
  /// Request from the internet based on information retrieved from `APIRoutable`.
  ///
  /// - Parameters:
  ///     - route: An `APIRoutable` instance which contains host, path, HTTP Method, Parameters and etc.
  /// - Returns: Response data
  ///
  func request(route: Route, completionHandler: @escaping (Result<Data, Error>) -> Void) {
    do {
      var request = try route.asURLRequest()
      logger.debug("URL request: \(request.curlString)")

      if route.shouldAuthenticate {
        guard storage.isAuthorized else {
          completionHandler(.failure(APIClientError.unableToAuthenticate))
          return
        }

        storage.authState?.performAction(freshTokens: { [weak self] accessToken, _, error in
          if error != nil {
            completionHandler(.failure(error ?? APIClientError.unknown(message: "Failed to authenticate without error")))
            return
          }

          guard let accessToken = accessToken else {
            return
          }

          request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
          self?.performDataTask(with: request, completionHandler: completionHandler)
        })
      } else {
        performDataTask(with: request, completionHandler: completionHandler)
      }
    } catch {
      completionHandler(.failure(error))
    }
  }

  private func performDataTask(with request: URLRequest, completionHandler: @escaping (Result<Data, Error>) -> Void) {
    urlSession.dataTask(with: request) { [weak self] data, response, error in
      guard let self = self else {
        completionHandler(.failure(APIClientError.unknown(message: "APIClient has deallocated.")))
        return
      }

      do {
        completionHandler(.success(try self.validate(data: data, response: response, error: error)))
      } catch {
        completionHandler(.failure(error))
      }
    }.resume()
  }

  private func validate(data: Data?, response: URLResponse?, error: Error?) throws -> Data {
    guard let response = response, let data = data else {
      throw error ?? APIClientError.unknown(message: "Cannot retrieve response or error.")
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIClientError.nonHTTPResponse
    }

    guard 200..<300 ~= httpResponse.statusCode else {
      var message: String?
      if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
        message = json["message"] as? String
      }

      guard let reason = APIClientError.RequestFailureReason(code: httpResponse.statusCode, message: message) else {
        throw APIClientError.unknown(message: "Unknows HTTP status code.")
      }

      throw APIClientError.requestFailure(reason: reason)
    }

    return data
  }
}

extension APIClient {
  ///
  /// Request from the internet based on information retrieved from `APIRoutable`.
  ///
  /// - Parameters:
  ///     - route: An `APIRoutable` instance which contains host, path, HTTP Method, Parameters and etc.
  ///     - forType: An ouput object that conforms the Decodable protocol.
  /// - Returns: Object observable
  ///
  func request<T>(route: Route, for type: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void) where T: Decodable {
    request(route: route) { result in
      switch result {
      case let .success(data):
        do {
          logger.debug("Request successful, response: \(String(describing: (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) ?? [:]))")
          completionHandler(.success(try JSONDecoder().decode(type, from: data)))
        } catch {
          logger.error("Failed deserialising response: \(error)")
          completionHandler(.failure(error))
        }
      case let .failure(error):
        logger.error("Request failed with error: \(error)")
        completionHandler(.failure(error))
      }
    }
  }
}
