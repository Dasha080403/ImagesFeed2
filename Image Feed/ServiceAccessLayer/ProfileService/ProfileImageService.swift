//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 05.02.2026.
//
import Foundation

// MARK: - Models
struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

struct UserResult: Codable {
    let profileImage: ProfileImage?

    enum CodingKeys: String, CodingKey {
      
        case profileImage = "profileImage"
    }
}

// MARK: - Service
final class ProfileImageService {
    
    static let shared = ProfileImageService()
    
    private init() {}

    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared

    func clearAvatarURL() {
        avatarURL = nil
    }

    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(URLError(.notConnectedToInternet)))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let userResult):
                    guard let imageUrl = userResult.profileImage?.medium ?? userResult.profileImage?.small else {
                        return
                    }
                    
                    self.avatarURL = imageUrl
                    completion(.success(imageUrl))
                    
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": imageUrl]
                    )
                    
                case .failure(let error):
                    print("[ProfileImageService]: Ошибка получения профиля: \(error)")
                    completion(.failure(error))
                }
                
                self.task = nil
            }
        }

        self.task = task
        task.resume()
    }

    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
