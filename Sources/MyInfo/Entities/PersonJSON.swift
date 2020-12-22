//
//  PersonJSON.swift
//  MyInfo
//
//  Created by Li Hao Lai on 22/12/20.
//

import Foundation

public enum PersonJSONKey: String, CodingKey {
  case name
  case sex
  case nationality
  case dob
}

public extension Dictionary where Key == String, Value == Any {
  func getName() -> String? {
    guard let innerJSON = self[PersonJSONKey.name.rawValue] as? [String: Any] else {
      return nil
    }

    return innerJSON["value"] as? String
  }

  func getSexCode() -> String? {
    guard let innerJSON = self[PersonJSONKey.sex.rawValue] as? [String: Any] else {
      return nil
    }

    return innerJSON["code"] as? String
  }

  func getSexDesc() -> String? {
    guard let innerJSON = self[PersonJSONKey.sex.rawValue] as? [String: Any] else {
      return nil
    }

    return innerJSON["desc"] as? String
  }

  func getNationalityCode() -> String? {
    guard let innerJSON = self[PersonJSONKey.nationality.rawValue] as? [String: Any] else {
      return nil
    }

    return innerJSON["code"] as? String
  }

  func getNationalityDesc() -> String? {
    guard let innerJSON = self[PersonJSONKey.nationality.rawValue] as? [String: Any] else {
      return nil
    }

    return innerJSON["desc"] as? String
  }

  func getDOB() -> String? {
    guard let innerJSON = self[PersonJSONKey.dob.rawValue] as? [String: Any] else {
      return nil
    }

    return innerJSON["value"] as? String
  }
}
