//
//  ImagesListPresenter.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 19.02.2026.
//

import UIKit

final class ImagesListPresenter: ImagesListViewOutput {
    weak var view: ImagesListViewInput?
    private let imagesListService: ImagesListServiceProtocol
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }

    // MARK: - ImagesListViewOutput
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePhotosArray()
        }
        imagesListService.fetchPhotosNextPage()
            
            updatePhotosArray()
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    func getPhoto(at index: Int) -> Photo {
        return photos[index]
    }
    
    func getCellDateString(at index: Int) -> String {
        guard let date = photos[index].createdAt else { return "" }
        return dateFormatter.string(from: date)
    }
    
    func calculateCellHeight(at index: Int, containerWidth: CGFloat) -> CGFloat {
        let photo = photos[index]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = containerWidth - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func didTapLike(at indexPath: IndexPath) {
            guard photos.indices.contains(indexPath.row) else { return }
            
            let photo = photos[indexPath.row]
            let photoId = photo.id
            let isLike = !photo.isLiked
            
            view?.showProgressHUD()
            
            imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
                guard let self = self else { return }
                self.view?.hideProgressHUD()
                
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let newIndexPath = IndexPath(row: index, section: 0)
                        
                        self.view?.setCellLikeState(at: newIndexPath, isLiked: self.photos[index].isLiked)
                    }
                    
                case .failure:
                    self.view?.showError(message: "Не удалось изменить лайк")
                }
            }
    }
    
    // 7. Обязательный метод из протокола
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    // MARK: - Private Methods
    
    private func updatePhotosArray() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count
        
        if newCount > oldCount { 
            self.photos = newPhotos
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
}
