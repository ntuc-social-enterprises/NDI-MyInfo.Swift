//
//  Authorise.swift
//  MyInfo
//
//  Created by Li Hao Lai on 12/12/20.
//

import AppAuth
import Foundation

public protocol Authorise: MyInfoServiceType {
  func login(from root: UIViewController, callback: @escaping (String?, Error?) -> Void)
}
