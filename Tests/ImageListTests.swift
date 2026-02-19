//
//  ImageListTests.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 19.02.2026.
//
import XCTest
@testable import Image_Feed
import UIKit

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

final class ImagesListViewControllerSpy: ImagesListViewInput {
    var updateTableViewAnimatedCalled = false
    var setCellLikeStateCalled = false
    var showProgressHUDCalled = false
    var hideProgressHUDCalled = false
    var lastIsLiked: Bool?

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func setCellLikeState(at indexPath: IndexPath, isLiked: Bool) {
        setCellLikeStateCalled = true
        lastIsLiked = isLiked
    }
    
    func showProgressHUD() { showProgressHUDCalled = true }
    func hideProgressHUD() { hideProgressHUDCalled = true }
    func showError(message: String) {}
}

final class ImagesListPresenterSpy: ImagesListViewOutput {
    var view: ImagesListViewInput?
    var viewDidLoadCalled: Bool = false
    var didTapLikeCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func getPhotosCount() -> Int { return 1 }
    
    func getPhoto(at index: Int) -> Photo {
        return Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    }
    
    func getCellDateString(at index: Int) -> String { return "1 января 2024" }
    
    func calculateCellHeight(at index: Int, containerWidth: CGFloat) -> CGFloat { return 100 }
    
    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }
    
    func willDisplayCell(at indexPath: IndexPath) {}
}

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCalculatesCorrectHeight() {
        let mockService = ImagesListServiceMock()
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        mockService.photos = [photo]
        
        let presenter = ImagesListPresenter(imagesListService: mockService)
        presenter.viewDidLoad()
        
        let containerWidth: CGFloat = 320
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageWidth = containerWidth - imageInsets.left - imageInsets.right
        let expectedHeight = (photo.size.height * (imageWidth / photo.size.width)) + imageInsets.top + imageInsets.bottom
        
        let calculatedHeight = presenter.calculateCellHeight(at: 0, containerWidth: 320)
        
        XCTAssertEqual(calculatedHeight, expectedHeight)
    }
    
    func testPresenterFormatsDate() {
        let mockService = ImagesListServiceMock()
        let photo = Photo(id: "1", size: .zero, createdAt: Date(), welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        mockService.photos = [photo]
        
        let presenter = ImagesListPresenter(imagesListService: mockService)
        presenter.viewDidLoad()
        
        let dateString = presenter.getCellDateString(at: 0)
        
        XCTAssertFalse(dateString.isEmpty)
    }
    
    func testLikeTapShowsLoading() {
        let viewController = ImagesListViewControllerSpy()
        let mockService = ImagesListServiceMock()
        let photo = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        mockService.photos = [photo]
        
        let presenter = ImagesListPresenter(imagesListService: mockService)
        presenter.view = viewController
        presenter.viewDidLoad()
        
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(viewController.showProgressHUDCalled)
    }

    func testPresenterUpdatesViewAfterNotification() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let mockService = ImagesListServiceMock()
        let presenter = ImagesListPresenter(imagesListService: mockService)
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        viewController.updateTableViewAnimatedCalled = false
        
        let photo = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        mockService.photos = [photo]
        
        // when
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        let expectation = expectation(description: "Wait for notification processing")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled, "View должна была обновить таблицу после получения уведомления")
    }
}
