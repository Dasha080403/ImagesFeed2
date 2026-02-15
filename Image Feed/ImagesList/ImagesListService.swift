//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 15.02.2026.
//
import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    private let urlSession = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage) else {
            print("Error: Invalid request")
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching photos: \(error)")
                    self.task = nil
                    return
                }
                
                guard let data = data else {
                    self.task = nil
                    return
                }
                
                do {
                    let photoResults = try self.jsonDecoder.decode([PhotoResult].self, from: data)
                  
                    let newPhotos = photoResults.map { Photo(from: $0) }
                    
                    // Обновляем данные
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    self.task = nil
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    
                } catch {
                    print("Decoding error: \(error)")
                    self.task = nil
                }
            }
        }
        
        self.task = task
        task.resume()
    }
}


private extension ImagesListService {
    func makePhotosRequest(page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        
        // if let token = OAuth2TokenStorage.shared.token {
        //    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // }
        
        return request
    }
}


struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = ISO8601DateFormatter().date(from: result.createdAt ?? "")
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, description
        case createdAt = "created_at"
        case urls
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Codable {
    let thumb: String
    let full: String
}
