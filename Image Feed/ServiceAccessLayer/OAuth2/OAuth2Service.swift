//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 24.01.2026.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success("")) // TODO [Sprint 10] Добавьте реализацию запроса токена
    }
}
