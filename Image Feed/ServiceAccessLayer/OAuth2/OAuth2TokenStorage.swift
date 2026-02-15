//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 24.01.2026.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "oauth2TokenKey"
    static let shared = OAuth2TokenStorage()

    private init() {}

    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if !isSuccess {
                    print("[OAuth2TokenStorage]: Ошибка при записи токена в Keychain")
                }
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}

