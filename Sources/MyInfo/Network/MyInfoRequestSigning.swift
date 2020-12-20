//
//  MyInfoRequestSigning.swift
//  MyInfo
//
//  Created by Li Hao Lai on 17/12/20.
//

import Foundation

struct RequestSigning {
  private static let PRIVATE_KEY_FILE_NAME = "MyInfo.p12"

  let oAuth2Config: OAuth2Config

  init(oAuth2Config: OAuth2Config) {
    self.oAuth2Config = oAuth2Config
  }

  func getAuthorizationHeader(method: HTTPMethod, url: URL, additionalParams: [String: String]) throws -> String {
    let clientId = oAuth2Config.clientId
    let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
    let nonce = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let baseParams = [
      "app_id": clientId,
      "nonce": nonce,
      "signature_method": "RS256",
      "timestamp": "\(timestamp)"
    ]

    guard let signature = try signing(method: method, url: url, baseParams: baseParams, additionalParams: additionalParams) else {
      throw APIClientError.failedToSign
    }

    return "PKI_SIGN app_id=\"\(clientId)\"" +
      ",timestamp=\"\(timestamp)\"" +
      ",nonce=\"\(nonce)\"" +
      ",signature_method=\"RS256\"" +
      ",signature=\"\(signature)\""
  }

  private func signing(method: HTTPMethod, url: URL, baseParams: [String: String], additionalParams: [String: String]) throws -> String? {
    var params = baseParams
    params.merge(additionalParams) { (_, new) -> String in new }

    let keyOrder = params.keys.sorted()

    var stringParams = ""
    keyOrder.forEach { key in
      stringParams += "&\(key)=\(params[key] ?? "")"
    }

    let final = "\(method.rawValue)&\(url.absoluteString)\(stringParams)"

    guard let privateKey = loadPrivateKey() else {
      logger.error("Failed to load private key.")
      return nil
    }
    let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256

    guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
      logger.error("Alogorithm not support with private key.")
      return nil
    }

    var error: Unmanaged<CFError>?
    guard let signature = SecKeyCreateSignature(privateKey,
                                                algorithm,
                                                Data(final.utf8) as CFData,
                                                &error) as Data?
    else {
      guard let signError = error?.takeRetainedValue() else {
        logger.error("Error on creating signature.")
        return nil
      }

      logger.error("Error on creating signature: \(signError.localizedDescription)")
      throw signError
    }

    return signature.base64EncodedString()
  }

  func loadPrivateKey(from bundle: Bundle = .main) -> SecKey? {
    guard let path = bundle.url(forResource: "MyInfo", withExtension: "p12"),
          let data = try? Data(contentsOf: path)
    else {
      logger.error("Please ensure `MyInfo.p12` has added to your app(main) bundle.")

      #if DEBUG
        fatalError("Please ensure `MyInfo.p12` has added to your app(main) bundle.")
      #else
        return nil
      #endif
    }

    let secret = oAuth2Config.privateKeySecret
    let options = [kSecImportExportPassphrase as String: secret]

    var rawItems: CFArray?
    var status = SecPKCS12Import(data as CFData,
                                 options as CFDictionary,
                                 &rawItems)

    guard status == errSecSuccess else {
      logger.error("Error on importing MyInfo.p12")
      return nil
    }
    let items = rawItems! as! [[String: Any]]
    let firstItem = items[0]

    guard let identity = firstItem[kSecImportItemIdentity as String] as! SecIdentity? else {
      return nil
    }

    var privateKey: SecKey?
    status = SecIdentityCopyPrivateKey(identity, &privateKey)

    guard status == errSecSuccess else {
      logger.error("Error on getting private key from MyInfo.p12")
      return nil
    }

    return privateKey
  }
}
