//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 24.01.2026.
//

import Foundation

final class OAuth2TokenStorage {
    let tokenKey = "oauth2TokenKey"
    static let shared = OAuth2TokenStorage()

    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
