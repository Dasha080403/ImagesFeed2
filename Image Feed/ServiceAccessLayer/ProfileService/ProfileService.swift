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
    let lastName: String
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
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            do {
                print("print data")
                print(data.base64EncodedString())
                print("print data")
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                let profile = Profile(
                    username: profileResult.username,
                    name: profileResult.firstName,
                    loginName: "@(profileResult.username)",
                    bio: profileResult.bio
                )
                self?.profile = profile
                completion(.success(profile))
            } catch {
                print("Error decoding profile data: (error)")
                completion(.failure(error))
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
