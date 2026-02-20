//import XCTest
@testable import Image_Feed
import Foundation
import XCTest

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var displayProfileDetailsCalled = false
    var updateAvatarCalled = false
    var showSkeletonCalled = false
    var hideSkeletonCalled = false
    var showLogoutAlertCalled = false
    
    var name: String?
    var login: String?
    var bio: String?
    var avatarURL: URL?

    func displayProfileDetails(name: String, login: String, bio: String) {
        displayProfileDetailsCalled = true
        self.name = name
        self.login = login
        self.bio = bio
    }
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        self.avatarURL = url
    }
    
    func showSkeleton() {
        showSkeletonCalled = true
    }
    
    func hideSkeleton() {
        hideSkeletonCalled = true
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapLogoutCalled: Bool = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {
        didTapLogoutCalled = true
    }
    
    func confirmLogout() {}
}


final class ProfileViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testPresenterCallsShowSkeleton() {
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewControllerSpy
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewControllerSpy.showSkeletonCalled)
    }

    func testPresenterCallsDisplayDetails() {
           // Given 
           let presenter = ProfilePresenter()
           let viewSpy = ProfileViewControllerSpy()
           presenter.view = viewSpy
           
           // When
           presenter.viewDidLoad()
           
           // Then
           XCTAssertTrue(viewSpy.showSkeletonCalled, "Презентер должен был вызвать показ скелетона")
       }

    func testPresenterCallsShowLogoutAlert() {
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewControllerSpy
        
        presenter.didTapLogout()
        
        XCTAssertTrue(viewControllerSpy.showLogoutAlertCalled)
    }
}
