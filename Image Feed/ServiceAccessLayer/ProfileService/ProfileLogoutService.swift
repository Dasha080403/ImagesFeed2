//
//  ProfileLogoutService.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 16.02.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    private init() { }
    
    func logout() {
        cleanCookies()
        clearToken()
        clearServicesData()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func clearToken() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func clearServicesData() {
        
        profileService.clearProfileData()
        profileImageService.clearAvatarURL()
        imagesListService.clearPhotos()
    }
}
