//
//  ContentView.swift
//  MyInfoDemo
//
//  Created by Li Hao Lai on 11/12/20.
//

import MyInfo
import SwiftUI

struct ContentView: View {
  @State var isAuthorised = MyInfo.stateManager.isAuthorized
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
                     Text("Authorise")
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
        }

        VStack(alignment: .leading) {
          Text("MyInfo Config")
            .font(.title)
            .padding(.top)
            .padding(.bottom)

          Text("Client ID: \(MyInfo.oAuth2Config.clientId)")

          Text("Environment: \(MyInfo.oAuth2Config.environment.rawValue)")
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
      .login(from: root) { accessToken, error in
        guard let at = accessToken else {
          print("Authorise: \(error?.localizedDescription ?? "Something went wrong")")
          return
        }

        print("AccessToken: \(at)")
        self.isAuthorised = accessToken != nil
      }
  }

  func getPerson() {
    MyInfo.service.getPerson { json, error in
      guard let rawJson = json else {
        print("Person API: \(error?.localizedDescription ?? "Something went wrong")")
        return
      }

      self.name = rawJson.getName()
      print("Person JSON: \(rawJson)")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
