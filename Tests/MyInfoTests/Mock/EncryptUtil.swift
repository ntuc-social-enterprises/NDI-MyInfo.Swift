//
//  EncryptUtil.swift
//  MyInfoTests
//
//  Created by Li Hao Lai on 23/12/20.
//

import CryptoSwift
import Foundation

struct EncryptUtil {
  private static let cek = "mYMfsggkTAm0TbvtlFh2hyoXnbEzJQjMxmgLN3d8xXA"

  private static let iv = "-nBoKLH0YkLZPSI9"

  static func mockEncryptedPersonData() -> Data {
    guard let protectedHeader = prepareProtectedHeader() else {
      fatalError("Unable to get protectedHeader")
    }

    guard let encryptedKey = prepareEncryptedKey() else {
      fatalError("Unable to get encryptedKey")
    }

    guard let (cipherText, authenticationTag) = prepareCipherTextAndAuthenticationTag(with: protectedHeader) else {
      fatalError("Unable to get cipherText and authenticationTag")
    }

    let jwe = "\(protectedHeader).\(encryptedKey).\(iv).\(cipherText).\(authenticationTag)"

    return Data(jwe.utf8)
  }

  private static func prepareProtectedHeader() -> String? {
    let header = [
      "alg": "RSA-OAEP",
      "kid": "google.com",
      "enc": "A256GCM"
    ]

    guard let json = try? JSONSerialization.data(withJSONObject: header, options: .prettyPrinted) else {
      print("Failed to parse header to json data.")
      return nil
    }

    return json.base64EncodedString()
  }

  private static func plainText() -> Data? {
    guard let jsonPath = Bundle(for: MyInfoTests.self).url(forResource: "person", withExtension: "json") else {
      print("Failed to get person.json")
      return nil
    }

    guard let jsonData = try? Data(contentsOf: jsonPath) else {
      print("Failed to load person.json data")
      return nil
    }

    guard let part1 = prepareProtectedHeader() else {
      print("Failed to prepare protected header")
      return nil
    }
    let part2 = jsonData.base64EncodedString()
    let part3 = Data("part3".utf8).base64EncodedString()

    return Data("\(part1).\(part2).\(part3)".utf8)
  }

  private static func prepareEncryptedKey() -> String? {
    guard let publicKey = loadPublicKey() else {
      print("Failed to load public key")
      return nil
    }

    let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA1

    guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
      print("Alogorithm not support with private key.")
      return ""
    }

    var error: Unmanaged<CFError>?
    guard let cekData = base64UrlDecode(cek),
          let encryptedKey = SecKeyCreateEncryptedData(publicKey,
                                                       algorithm,
                                                       cekData as CFData,
                                                       &error) as Data?
    else {
      print("Failed to prepare encrypted key")
      return nil
    }

    return encryptedKey.base64EncodedString()
  }

  private static func prepareCipherTextAndAuthenticationTag(with protectedHeader: String) -> (String, String)? {
    guard let ivData = base64UrlDecode(iv),
          let cekData = base64UrlDecode(cek)
    else {
      print("Failed to get iv and cek data")
      return nil
    }

    let protectedHeaderData = Data(protectedHeader.utf8)
    let gcm = GCM(iv: [UInt8](ivData), additionalAuthenticatedData: [UInt8](protectedHeaderData), mode: GCM.Mode.detached)

    guard let aes = try? AES(key: [UInt8](cekData), blockMode: gcm, padding: .noPadding),
          let plaintext = plainText(),
          let encrypted = try? aes.encrypt([UInt8](plaintext)),
          let tag = gcm.authenticationTag
    else {
      print("Failed to encrypt with AES.")
      return nil
    }

    return (Data(encrypted).base64EncodedString(), Data(tag).base64EncodedString())
  }

  private static func loadPublicKey() -> SecKey? {
    guard let publicCertUrl = Bundle(for: MyInfoTests.self).url(forResource: "MyInfo", withExtension: "der") else {
      print("Failed to get MyInfo.der")
      return nil
    }

    guard let publicCertData = try? Data(contentsOf: publicCertUrl) as CFData else {
      print("Failed to load MyInfo.der data")
      return nil
    }

    guard let certificate = SecCertificateCreateWithData(nil, publicCertData) else {
      print("Failed to create certificate from data")
      return nil
    }

    var trust: SecTrust?

    let policy = SecPolicyCreateBasicX509()
    _ = SecTrustCreateWithCertificates(certificate, policy, &trust)

    guard let t = trust else {
      print("Certificate trust in nil")
      return nil
    }

    return SecTrustCopyKey(t)
  }

  private static func base64UrlDecode(_ value: String) -> Data? {
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
