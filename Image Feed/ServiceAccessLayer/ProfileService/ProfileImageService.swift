//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 05.02.2026.
//
import Foundation
import Kingfisher

struct ProfileImage: Codable {
    let small, medium, large: String
}

struct UserResult: Codable {
    let profileImage: ProfileImage?

     enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
 
    static let shared = ProfileImageService()
    private init() {}

    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    
    private(set) var avatarURL: String?

    private var task: URLSessionTask?

  
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()

    guard let token = OAuth2TokenStorage.shared.token else { return }
        
    guard let request = makeProfileImageRequest(username: username, token: token) else
        {
    completion(.failure(URLError(.badURL)))
                    return
    }
        
    let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
    DispatchQueue.main.async {
    guard let self = self else { return }
                        
    switch result {
    case .success(let userResult):
    let imageUrl = userResult.profileImage?.medium ?? userResult.profileImage?.small
                            
    if let imageUrl = imageUrl {
    self.avatarURL = imageUrl
    completion(.success(imageUrl))
                                
    NotificationCenter.default.post(
    name: Self.didChangeNotification,
    object: self,
    userInfo: ["URL": imageUrl])
    } else {
    print("[ProfileImageService]: Ссылка на фото отсутствует в ответе")
    }
    case .failure(let error): print("[ProfileImageService]: Ошибка получения профиля: \(error)")
    completion(.failure(error))
    }
    self.task = nil
                    }
                }

    self.task = task
    task.resume()
    }

    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        print("[ProfileImageService]: Запрашиваю аватар для пользователя: \(username)")
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
