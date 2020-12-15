//
//  ContentView.swift
//  MyInfoDemo
//
//  Created by Li Hao Lai on 11/12/20.
//

import MyInfo
import SwiftUI

struct ContentView: View {
  var body: some View {
    Text("Hello, world!")
      .padding()
      .onAppear(perform: test)
  }

  func test() {
    guard let root = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController else {
      return
    }

    MyInfo.authorise(with: "name,sex,nationality,dob", purpose: "demonstrating MyInfo APIs")
      .login(from: root) { accessToken, _ in
        debugPrint("AccessToken: \(accessToken ?? "nil")")
      }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
