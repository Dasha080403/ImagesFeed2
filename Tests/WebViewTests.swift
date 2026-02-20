//
//  Image_FeedTests2.swift
//  Image FeedTests2
//
//  Created by Дарья Савинкина on 19.02.2026.
//

import XCTest
@testable import Image_Feed

// MARK: - Spies
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled: Bool = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {}

    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {}
    func setProgressHidden(_ isHidden: Bool) {}
}

// MARK: - Tests
final class WebViewTests: XCTestCase {
   
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    // 2. Тест связи Presenter -> View
    func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = WebViewHelper() 
        let presenter = WebViewPresenter(authHelper: authHelper)
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    // 3. Тест логики скрытия прогресса (меньше 1)
    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = WebViewHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertFalse(shouldHideProgress)
    }
    
    // 4. Тест логики скрытия прогресса (равно 1)
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = WebViewHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertTrue(shouldHideProgress)
    }
    
    // 5. Тест формирования запроса в AuthHelper
    func testAuthHelperAuthURL() {
        // given
        let authHelper = WebViewHelper()
        
        // when
        let request = authHelper.authRequest()
        guard let urlString = request?.url?.absoluteString else {
            XCTFail("URL is nil")
            return
        }
        
        // then
        XCTAssertTrue(urlString.contains(WebViewConstants.unsplashAuthorizeURLString))
        XCTAssertTrue(urlString.contains(Constants.accessKey))
        XCTAssertTrue(urlString.contains(Constants.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(Constants.accessScope))
    }
    
    // 6. Тест извлечения кода из URL
    func testCodeFromURL() {
        // given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = WebViewHelper()
        
        // when
        let code = authHelper.code(from: url)
        
        // then
        XCTAssertEqual(code, "test code")
    }
}
