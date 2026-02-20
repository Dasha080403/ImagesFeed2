//
//  AuthTest.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 19.02.2026.
// Тест работает только с включенной англ клавиатурой

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    private func dismissKeyboardByTappingOutside() {
        let upperSpace = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        upperSpace.tap()
    }
    
    override func setUpWithError() throws {
            continueAfterFailure = false
        }

    func test1_Auth() throws {
        app.launchArguments = ["--isResetData"]
        app.launch()
        let authButton = app.buttons["Войти"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 10))

        let loginTextField = webView.textFields.firstMatch
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        loginTextField.tap()
        loginTextField.typeText("")

        webView.swipeUp()

        let passwordTextField = webView.secureTextFields.firstMatch
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        passwordTextField.tap()
        passwordTextField.typeText("")

        let loginButton = webView.buttons["Login"]
        if loginButton.waitForExistence(timeout: 5) {
            loginButton.tap()
        }
        
        let authorizeButton = webView.buttons["Authorize"]
        if authorizeButton.waitForExistence(timeout: 10) {
            authorizeButton.tap()
        }

        let tablesQuery = app.tables
        let cell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 20))
    }

    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        cell.swipeUp()
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        let likeButtonOff = cellToLike.buttons["like button off"]
        XCTAssertTrue(likeButtonOff.exists, "Кнопка 'off' не найдена")
        likeButtonOff.tap()
        
        let likeButtonOn = cellToLike.buttons["like button on"]
        XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 10), "Лайк не поставился вовремя")
        
        likeButtonOn.tap()
        
        XCTAssertTrue(likeButtonOff.waitForExistence(timeout: 10), "Лайк не снялся вовремя")
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10), "Полноэкранное фото не загрузилось")
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButtonWhiteButton.exists)
        navBackButtonWhiteButton.tap()
        
        XCTAssertTrue(tablesQuery.element.exists)
    }


    
    func test3_testProfile() throws {
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

