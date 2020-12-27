# NDI-MyInfo.Swift

This project is to help developers to setup MyInfo login and fetch the person API
For the detail of the API please refer [here](https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.1.1.html)

### Configure MyInfo
Add your configuration in `MyInfo.plist`. If the file does not exist in your project yet, create one with the information below:

```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Issuer</key>
	<string>https://test.api.myinfo.gov.sg/com/v3/authorise</string>
	<key>ClientID</key>
	<string>client1</string>
	<key>ClientSecret</key>
	<string>client_secret</string>
	<key>PrivateKeySecret</key>
	<string>12345678</string>
	<key>Environment</key>
	<string>test</string>
	<key>RedirectURI</key>
	<dict>
		<key>relative</key>
		<string>https://google.com/callback</string>
	</dict>
	<key>AuthorizationURL</key>
	<dict>
		<key>relative</key>
		<string>https://test.api.myinfo.gov.sg/com/v3/authorise</string>
	</dict>
	<key>TokenURL</key>
	<dict>
		<key>relative</key>
		<string>https://test.api.myinfo.gov.sg/com/v3/token</string>
	</dict>
</dict>
</plist>
```

### Add Your Certificate
Add your p12 file (x509 cert & private key) as `MyInfo.p12` for the requesting signing and payload decryption.

### Configure Callback URLs
This SDK is built with assumption that we will have a double redirection from the callback url provided to MyInfo. (MyInfo only allow 302 redirection and the authcode is returned via HTTP callback, so in our URL we will redirect back to the app with the app scheme URL.)

In your application's Info.plist file, register your app scheme:
```plist
<!-- Info.plist -->

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>$(YOUR_APP_SCHEME)</string>
        </array>
    </dict>
</array>
```

### Authorise (Login)
The login process will automatically trigger the **Token API** and retrieve a valid access token to you, the access token will store in memory for the following API call if access token is needed.
```swift
MyInfo.authorise()
      // Set the attributes you need 
      .setAttributes("name,sex,nationality,dob")
      // Set the purpose 
      .setPurpose("demonstrating MyInfo APIs")
      .login(from: root) { accessToken, error in
        // After success login, a valid access token will return to you incase you need to call API yourself.      
        guard let at = accessToken else {
          print("Authorise: \(error?.localizedDescription ?? "Something went wrong")")
          return
        }

        print("AccessToken: \(at)")
      }
```

### Person API
The Person API must call after the login process because it will require the access token.
```swift
MyInfo.service
      // Set the attributes you need, if your attribute is same as previous, you can skip this line
      .setAttributes("name,sex,nationality,dob")
      .getPerson { json, error in
        guard let rawJson = json else {
          print("Person API: \(error?.localizedDescription ?? "Something went wrong")")
          return
        }

        self.name = rawJson.getName()
        print("Person JSON: \(rawJson)")
      }
```