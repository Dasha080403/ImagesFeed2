//
//  ProfileViewTests.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 19.02.2026.
//

import XCTest
@testable import Image_Feed

// MARK: - Spies

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    func confirmLogout() {
        print("puk")
    }
    
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapLogoutCalled: Bool = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {
        didTapLogoutCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    func showLogoutAlert() {
        print("puk")
    }
    
    var displayProfileDetailsCalled: Bool = false
    var updateAvatarCalled: Bool = false
    var showSkeletonCalled: Bool = false
    var hideSkeletonCalled: Bool = false
    
    var lastUpdateAvatarURL: URL?

    func displayProfileDetails(name: String, login: String, bio: String) {
        displayProfileDetailsCalled = true
    }

    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        lastUpdateAvatarURL = url
    }

    func showSkeleton() {
        showSkeletonCalled = true
    }

    func hideSkeleton() {
        hideSkeletonCalled = true
    }
}

// MARK: - Tests

final class ProfileViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenterProtocol = ProfilePresenterSpy()
        viewController.presenterProtocol = presenterProtocol
        presenterProtocol.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenterProtocol.viewDidLoadCalled)
    }

    func testPresenterCallsShowSkeleton() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.showSkeletonCalled)
    }

    // 3. Тест: Презентер вызывает обновление данных (если профиль уже загружен в Service)
    func testPresenterCallsDisplayProfileDetails() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.displayProfileDetailsCalled)
    }

    func testPresenterCallsLogout() {
        // given
        let viewController = ProfileViewController()
        let presenterProtocol = ProfilePresenterSpy()
        viewController.presenterProtocol = presenterProtocol
        
        // when
        presenterProtocol.didTapLogout()
        
        // then
        XCTAssertTrue(presenterProtocol.didTapLogoutCalled)
    }
    
    // 5. Тест: Передача URL аватара во View
    func testPresenterUpdatesAvatarURL() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        if ProfileImageService.shared.avatarURL != nil {
            XCTAssertTrue(viewController.updateAvatarCalled)
        }
    }
}
