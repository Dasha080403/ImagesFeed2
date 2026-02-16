//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 15.02.2026.
//
import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    private var fetchTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    
    private let urlSession = URLSession.shared
    private let dateFormatter = ISO8601DateFormatter()
    
    private init() {}

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if fetchTask != nil { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage) else {
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.fetchTask = nil
                
                if let error = error {
                    print("Error fetching photos: \(error)")
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    let photoResults = try decoder.decode([PhotoResult].self, from: data)
                    
                    let newPhotos = photoResults.map { Photo(from: $0) }
                    
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }
        
        self.fetchTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        likeTask?.cancel()
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.likeTask = nil
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                }
                
                completion(.success(()))
            }
        }
        
        self.likeTask = task
        task.resume()
    }
    
    private func makePhotosRequest(page: Int) -> URLRequest? {
        let urlString = "https://api.unsplash.com/photos"
        guard var urlComponents = URLComponents(string: urlString) else { return nil }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

// MARK: - Models

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
    
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
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Codable {
    let thumb: String
    let full: String
}
