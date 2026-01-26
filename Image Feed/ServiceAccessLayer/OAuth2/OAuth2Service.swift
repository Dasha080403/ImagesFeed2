//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 24.01.2026.
//
import Foundation

struct OAuthTokenResponse: Codable {
    let accessToken: String
    
    static let usplashTokenURL = "https://unsplash.com/oauth/token"
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    static let unsplashTokenURL = "https://unsplash.com/oauth/token"
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: OAuth2Service.unsplashTokenURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "client_id": Constants.accessKey,
            "redirect_uri": Constants.redirectURI,
            "grant_type": "authorization_code",
            "code": code,
            "scope": Constants.accessScope
        ]
        
        
        var bodyString = ""
        for (key, value) in parameters {
            if !bodyString.isEmpty {
                bodyString += "&"
            }
            bodyString += "(key)=(value)"
        }
        
        request.httpBody = bodyString.data(using: .utf8)

        fetchData(with: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(OAuthTokenResponse.self, from: data)
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func fetchData(with request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else {
                completion(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    private enum NetworkError: Error {
        case codeError
    }
    
}
