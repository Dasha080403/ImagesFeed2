//
//  ImagesListProtocol.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 19.02.2026.
//

import UIKit

protocol ImagesListViewInput: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func setCellLikeState(at indexPath: IndexPath, isLiked: Bool)
    func showProgressHUD()
    func hideProgressHUD()
    func showError(message: String)
}

protocol ImagesListViewOutput: AnyObject {
    func viewDidLoad()
    func getPhotosCount() -> Int
    func getPhoto(at index: Int) -> Photo
    func getCellDateString(at index: Int) -> String
    func calculateCellHeight(at index: Int, containerWidth: CGFloat) -> CGFloat
    func didTapLike(at indexPath: IndexPath)
    func willDisplayCell(at indexPath: IndexPath)
}

