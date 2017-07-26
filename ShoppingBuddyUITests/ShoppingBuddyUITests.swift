//
//  ShoppingBuddyUITests.swift
//  ShoppingBuddyUITests
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import XCTest
@testable import ShoppingBuddy

class LoginControllerUITests: XCTestCase {
    var app:XCUIApplication!
    
  /*  override func setUp() {
        super.setUp()
        continueAfterFailure = false
        // UI tests must launch the application that they test. 
        // Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
        XCUIDevice.shared().orientation = .portrait
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_LoginButtonPressedWithout_Input(){
        app.buttons["btn_login"].tap()
        XCTAssertNotNil(app.alerts["Validation Error"], "Alert should appear")
    }
    func test_LoginButtonPressedWithoutInput_AlertTitleIsCorrect(){
        app.buttons["Sign up"].tap()
        
        let nicknameTextField = app.textFields["nickname"]
        nicknameTextField.tap()
        nicknameTextField.typeText("nick")
        nicknameTextField.typeText("name")
        
        let emailTextField = app.textFields["email"]
        emailTextField.tap()
        emailTextField.typeText("p.sypek")
        emailTextField.typeText("@")
        emailTextField.typeText("icloud.")
        emailTextField.typeText("com")

        
        let passwordSecureTextField = app.secureTextFields["password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("1234")
        app.buttons["Sign up"].tap()
        
    }*/
}
