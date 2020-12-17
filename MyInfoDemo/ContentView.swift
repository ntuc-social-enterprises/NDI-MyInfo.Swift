//
//  ContentView.swift
//  MyInfoDemo
//
//  Created by Li Hao Lai on 11/12/20.
//

import MyInfo
import SwiftUI

struct ContentView: View {
  @State var isAuthorised = true
  @State var name: String?

  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        HStack(alignment: .center) {
          Spacer()

          if isAuthorised {
            Button(action: getPerson,
                   label: {
                     Text("Get Person API")
                       .padding()
                       .padding(.horizontal, 50)
                       .foregroundColor(Color.white)
                       .background(Color.blue)
                       .cornerRadius(5.0)
                   })
          } else {
            Button(action: login,
                   label: {
                     Text("Logout")
                       .padding()
                       .padding(.horizontal, 50)
                       .foregroundColor(Color.white)
                       .background(Color.blue)
                       .cornerRadius(5.0)
                   })
          }

          Spacer()
        }.padding()

        if isAuthorised {
          Text("Hello, \(name ?? "Get Person API for your name")!")
            .padding()
        } else {
          VStack(alignment: .leading) {
            Text("MyInfo Config")
              .font(.title)
              .padding(.top)
              .padding(.bottom)

            Text("Client ID: \(MyInfo.oAuth2Config.clientId)")
          }
        }

        Spacer()
      }
      .navigationTitle("MyInfo Demo")
      .padding()
    }
  }

  func login() {
    guard let root = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController else {
      return
    }

    MyInfo.authorise()
      .setAttributes("name,sex,nationality,dob")
      .setPurpose("demonstrating MyInfo APIs")
      .login(from: root) { accessToken, _ in
        debugPrint("AccessToken: \(accessToken ?? "nil")")
        self.isAuthorised = accessToken != nil
      }
  }

  func getPerson() {
    MyInfo.service.getPerson { json, error in
      guard let rawJson = json else {
        debugPrint("Person API: \(error?.localizedDescription ?? "Something went wrong")")
        return
      }

      debugPrint("Person JSON: \(rawJson)")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
