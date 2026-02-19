//
//  Constants.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 24.01.2026.
//

import Foundation

enum Constants {
    static let accessKey = "JUObV1qKvXoUQhCaO3XoaN4mxa5gu5Ytvq98Fx81o14"
    static let secretKey = "I8xTzFpd0yO9IVEXdQAZim3wG64HE2Ws7lPB474n0fU"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURLString = "https://api.unsplash.com"
}

struct WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            authURLString: WebViewConstants.unsplashAuthorizeURLString, // Исправлено: WebViewConstants вместо Constants
            defaultBaseURLString: Constants.defaultBaseURLString
        )
    }

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
        self.defaultBaseURLString = defaultBaseURLString
    }
}
