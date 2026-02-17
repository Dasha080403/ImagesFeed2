//
//  ProfileService.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 02.02.2026.
//
import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    
    func clearProfileData() {
            task?.cancel() 
            task = nil
            profile = nil
        }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            let fulfillCompletionOnMainThread: (Result<Profile, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            if let error = error {
                fulfillCompletionOnMainThread(.failure(error))
                return
            }
            
            guard let data = data else {
                fulfillCompletionOnMainThread(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                
                let name = [profileResult.firstName, profileResult.lastName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                let profile = Profile(
                    username: profileResult.username,
                    name: name,
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )
                
                self?.profile = profile
                fulfillCompletionOnMainThread(.success(profile))
                
            } catch {
                fulfillCompletionOnMainThread(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
