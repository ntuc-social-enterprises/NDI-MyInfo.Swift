//
//  Logger.swift
//  MyInfo
//
//  Created by Li Hao Lai on 15/12/20.
//

import Foundation
import Logging

#if DEBUG
  let logFormatter = BasicFormatter
    .standardDebugFormatter(version: "v\(Bundle(for: MyInfo.self).infoDictionary?["CFBundleShortVersionString"] ?? "")",
                            contextName: "[MyInfo.Swift]")
  let logHandler = Handler(formatter: logFormatter,
                           pipe: LoggerTextOutputStreamPipe.standardOutput,
                           logLevel: .debug)
#else
  let logFormatter = BasicFormatter
    .standardInfoFormatter(version: "v\(Bundle(for: MyInfo.self).infoDictionary?["CFBundleShortVersionString"] ?? "")",
                           contextName: "[MyInfo.Swift]")
  let logHandler = Handler(formatter: logFormatter,
                           pipe: LoggerTextOutputStreamPipe.standardOutput)
#endif

var logger = Logger(label: "") { _ in
  logHandler
}
