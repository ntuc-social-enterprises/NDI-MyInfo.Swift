//
//  MyInfoRequestSigning.swift
//  MyInfo
//
//  Created by Li Hao Lai on 17/12/20.
//

import CryptoSwift
import Foundation
import JOSESwift
import JWTDecode

struct APIUtils {
  enum Error: Swift.Error {
    case unsupportedAlgorithm
    case failedToDecryptCEK
    case failedToLoadPrivateKey
    case failedToCreateSign
  }

  private static let PRIVATE_KEY_FILE_NAME = "MyInfo.p12"

  let oAuth2Config: OAuth2Config

  let bundle: Bundle

  init(oAuth2Config: OAuth2Config, in bundle: Bundle = .main) {
    self.oAuth2Config = oAuth2Config
    self.bundle = bundle
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

    let signature = try signing(method: method, url: url, baseParams: baseParams, additionalParams: additionalParams)
    return "PKI_SIGN app_id=\"\(clientId)\"" +
      ",timestamp=\"\(timestamp)\"" +
      ",nonce=\"\(nonce)\"" +
      ",signature_method=\"RS256\"" +
      ",signature=\"\(signature)\""
  }

  func decodeJWE(body: Data) throws -> [String: Any] {
    guard let privateKey = loadPrivateKey() else {
      logger.error("Failed to load private key.")
      throw Error.failedToLoadPrivateKey
    }

    do {
      let jwe = try JWE(compactSerialization: body)
      let cek = try decodeCEK(encrypted: jwe.encryptedKey, privateKey: privateKey)
      let jweProtectedHeader = jwe.compactSerializedString.split(separator: ".").first ?? ""
      let authenticatedData = Data(jweProtectedHeader.utf8)
      let payload = try decodeContent(with: jwe,
                                      cek: cek,
                                      authenticatedData: authenticatedData,
                                      privateKey: privateKey)
      return payload
    } catch {
      throw (error)
    }
  }

  func loadPrivateKey() -> SecKey? {
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

  private func signing(method: HTTPMethod, url: URL,
                       baseParams: [String: String],
                       additionalParams: [String: String]) throws -> String {
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
      throw Error.failedToLoadPrivateKey
    }
    let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256

    guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
      logger.error("Alogorithm not support with private key.")
      throw Error.unsupportedAlgorithm
    }

    var error: Unmanaged<CFError>?
    guard let signature = SecKeyCreateSignature(privateKey,
                                                algorithm,
                                                Data(final.utf8) as CFData,
                                                &error) as Data?
    else {
      guard let signError = error?.takeRetainedValue() else {
        logger.error("Error on creating signature.")
        throw Error.failedToCreateSign
      }

      logger.error("Error on creating signature: \(signError.localizedDescription)")
      throw signError
    }

    return signature.base64EncodedString()
  }

  private func decodeCEK(encrypted: Data, privateKey: SecKey) throws -> Data {
    let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA1
    guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
      logger.error("Alogorithm not support with private key.")
      throw Error.unsupportedAlgorithm
    }

    var error: Unmanaged<CFError>?
    guard
      let key = SecKeyCreateDecryptedData(privateKey, algorithm, encrypted as CFData, &error)
    else {
      guard let decryptionError = error?.takeRetainedValue() else {
        logger.error("Error on decrypting CEK.")
        throw Error.failedToDecryptCEK
      }

      logger.error("Error on decrypting CEK: \(decryptionError.localizedDescription)")
      throw decryptionError
    }

    return key as Data
  }

  private func decodeContent(with jwe: JWE,
                             cek: Data,
                             authenticatedData: Data,
                             privateKey: SecKey) throws -> [String: Any] {
    do {
      // In combined mode, the authentication tag is appended to the encrypted message. This is usually what you want.
      let gcm = GCM(iv: [UInt8](jwe.initializationVector),
                    authenticationTag: [UInt8](jwe.authenticationTag),
                    additionalAuthenticatedData: [UInt8](authenticatedData))
      let aes = try AES(key: [UInt8](cek), blockMode: gcm, padding: .noPadding)
      let decrypted = try aes.decrypt([UInt8](jwe.ciphertext))
      let decryptedString = String(data: Data(decrypted), encoding: .utf8) ?? ""
      let payload = try decodeJWTPart(String(decryptedString.split(separator: ".")[1]))

      return payload
    } catch {
      throw (error)
    }
  }

  private func decodeJWTPart(_ value: String) throws -> [String: Any] {
    guard let bodyData = base64UrlDecode(value) else {
      throw DecodeError.invalidBase64Url(value)
    }

    guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
      throw DecodeError.invalidJSON(value)
    }

    return payload
  }

  private func base64UrlDecode(_ value: String) -> Data? {
    var base64 = value
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length
    if paddingLength > 0 {
      let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
      base64 += padding
    }
    return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
  }
}
