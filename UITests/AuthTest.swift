//
//  AuthTest.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 19.02.2026.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
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
        loginTextField.typeText("savinkinadari@yandex.ru")
        dismissKeyboardByTappingOutside()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("Dasha2003.")
        dismissKeyboardByTappingOutside()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 20))
    }
    
    func test2_LikeFunctional() throws {
        let app = XCUIApplication()
            app.launchArguments.append("--isUITesting")
            app.launch()
        app.launch()
        
        
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence(timeout: 10))
        
        let cell = tablesQuery.cells.element(boundBy: 1)
        
        while !cell.isHittable {
            app.swipeUp()
        }
        
        let likeButton = cell.buttons["like button off"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "Кнопка лайка 'off' не найдена")
        
        likeButton.tap()
        
        let likeButtonOn = cell.buttons["like button on"]
        XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 5), "Кнопка не переключилась в состояние 'on'")
        
        likeButtonOn.tap()
        
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "Кнопка не вернулась в состояние 'off'")
    }

    
    func test3_Profile() throws {
        let app = XCUIApplication()
            app.launchArguments.append("--isUITesting")
            app.launch()
        app.launch()
        
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
       
        XCTAssertTrue(app.staticTexts["Darya Shem"].exists)
        XCTAssertTrue(app.staticTexts["@Dasha080403"].exists)
        
        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.exists)
        logoutButton.tap()
        
        let alert = app.alerts["Bye bye!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["Yes"].tap()
        
        XCTAssertTrue(app.buttons["Войти"].waitForExistence(timeout: 5))
    }
    
    private func dismissKeyboardByTappingOutside() {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
    }
}
