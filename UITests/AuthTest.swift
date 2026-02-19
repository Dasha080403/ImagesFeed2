//
//  AuthTest.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 19.02.2026.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    private func dismissKeyboardByTappingOutside() {
        let upperSpace = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        upperSpace.tap()
    }
    
    override func setUpWithError() throws {
            continueAfterFailure = false
            app.launchArguments = ["--isUITesting"]
        }

    func test1_Auth() throws {
        app.launchArguments.append("RESET_APP")
        app.launch()
        
        let authButton = app.buttons["Войти"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews.element
        XCTAssertTrue(webView.waitForExistence(timeout: 10))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("")
        dismissKeyboardByTappingOutside()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("")
        dismissKeyboardByTappingOutside()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 20))
    }
    
    func test2_LikeFunctional() throws {
        app.launch()
            
            let tablesQuery = app.tables
            let firstCell = tablesQuery.cells.element(boundBy: 0)
            XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Лента не загрузилась")
            
            app.swipeUp()
            
            let cellToLike = tablesQuery.cells.element(boundBy: 1)
            let likeButton = cellToLike.buttons["like button off"]
            XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
            likeButton.tap()
            
            let unlikeButton = cellToLike.buttons["like button on"]
            XCTAssertTrue(unlikeButton.waitForExistence(timeout: 5))
            unlikeButton.tap()
            XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
            
            cellToLike.tap()
            
            let fullImage = app.scrollViews.images.element(boundBy: 0)
            XCTAssertTrue(fullImage.waitForExistence(timeout: 10), "Полноэкранное изображение не открылось")
            
            // pinch(withScale:velocity:) — scale > 1 увеличивает
            fullImage.pinch(withScale: 3, velocity: 1)
            
            // scale < 1 уменьшает
            fullImage.pinch(withScale: 0.5, velocity: -1)
            
            let backButton = app.buttons["nav back button white"]
            XCTAssertTrue(backButton.exists)
            backButton.tap()
            
            XCTAssertTrue(tablesQuery.element.exists)
    }

    
    func testProfile() throws {
        app.launch()
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 15))
        profileTab.tap()
        let nameLabel = app.staticTexts["Shemonaeva Darya"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 15), "Имя профиля не загрузилось")
        
        XCTAssertEqual(nameLabel.label, "Shemonaeva Darya")
        XCTAssertTrue(app.staticTexts["@dasha080403"].exists)
        
        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.exists)
        logoutButton.tap()
        
        let alert = app.alerts["Пока-пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 15), "Алерт не появился")
        
        let yesButton = alert.buttons["Да"]
        XCTAssertTrue(yesButton.exists)
        yesButton.tap()
        
        let authButton = app.buttons["Войти"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}
