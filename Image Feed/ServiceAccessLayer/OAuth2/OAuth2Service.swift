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
    private let jsonDecoder = JSONDecoder()
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard var components = URLComponents(string: Self.unsplashTokenURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        components.queryItems = [
            .init(name: "client_id", value: Constants.accessKey),
            .init(name: "client_secret", value: Constants.secretKey),
            .init(name: "redirect_uri", value: Constants.redirectURI),
            .init(name: "code", value: code),
            .init(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        enum HTTPMethod: String {
            case get = "GET"
            case post = "POST"
            case put = "PUT"
            case delete = "DELETE"
        }

        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue

fetchData(with: request) { [self] result in
switch result {
case .success(let data):
do {
let tokenResponse = try jsonDecoder.decode(OAuthTokenResponse.self, from: data)
OAuth2TokenStorage.shared.token = tokenResponse.accessToken
    DispatchQueue.main.async {
        completion(.success(tokenResponse.accessToken))
    }
}
    catch {
DispatchQueue.main.async {
completion(.failure(error))
    }
}
case .failure(let error):
DispatchQueue.main.async {
completion(.failure(error))
                }
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
