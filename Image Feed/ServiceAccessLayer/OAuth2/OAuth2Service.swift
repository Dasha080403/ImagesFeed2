//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 24.01.2026.
//
import Foundation

struct OAuthTokenResponse: Codable {
    let accessToken: String
    
    static let unsplashTokenURL = "https://unsplash.com/oauth/token"
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    static let unsplashTokenURL = "https://unsplash.com/oauth/token"
    private let jsonDecoder = JSONDecoder()
    
    private var ongoingRequests: [String: (Result<String, Error>) -> Void] = [:]
    private let queue = DispatchQueue(label: "OAuth2ServiceQueue")
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard var components = URLComponents(string: Self.unsplashTokenURL) else {
            let error = NetworkError.invalidURL
            self.logError(error)
            completion(.failure(error))
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
            let error = NetworkError.invalidURL
            self.logError(error)
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        
        fetchData(with: request) { result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try self.jsonDecoder.decode(OAuthTokenResponse.self, from: data)
                    OAuth2TokenStorage.shared.token = tokenResponse.accessToken
                    DispatchQueue.main.async {
                        completion(.success(tokenResponse.accessToken))
                    }
                } catch {
                    let decodingError = NetworkError.decodingError(error, data)
                    self.logError(decodingError)
                    DispatchQueue.main.async {
                        completion(.failure(decodingError))
                    }
                }
                
            case .failure(let error):
                self.logError(error)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func fetchData(with request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                let networkError = NetworkError.networkError(error)
                self.logError(networkError)
                completion(.failure(networkError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                let error = NetworkError.unexpectedResponse
                self.logError(error)
                completion(.failure(error))
                return
            }
            
            if (300..<400).contains(response.statusCode) {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                let serviceError = NetworkError.serviceError(code: response.statusCode, message: errorMessage)
                self.logError(serviceError)
                completion(.failure(serviceError))
                return
            } else if !(200..<300).contains(response.statusCode) {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"


let serviceError = NetworkError.serviceError(code: response.statusCode, message: errorMessage)
                self.logError(serviceError)
                completion(.failure(serviceError))
                return
            }
            
            guard let data = data else {
                let error = NetworkError.noData
                self.logError(error)
                completion(.failure(error))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    private func logError(_ error: Error) {
        print("Error occurred: (error.localizedDescription)")
    }

    private enum NetworkError: Error {
        case invalidURL
        case noData
        case unexpectedResponse
        case decodingError(Error, Data?)
        case networkError(Error)
        case serviceError(code: Int, message: String)
    }

    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
}
