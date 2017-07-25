//
//  ShoppingBuddyUITests.swift
//  ShoppingBuddyUITests
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import XCTest

class LoginControllerUITests: XCTestCase {
    var app:XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        // UI tests must launch the application that they test. 
        // Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_LoginButtonPressedWithout_Input(){
        XCUIDevice.shared().orientation = .portrait
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        let btnLoginButton = app.buttons["btn_login"]
        btnLoginButton.tap()
        
        let okButton = app.alerts["Validierungsfehler"].buttons["OK"]
        okButton.tap()
        
        let eMailTextField = app.textFields["E-mail"]
        eMailTextField.tap()
        eMailTextField.typeText("p.syppek")
        btnLoginButton.tap()
        okButton.tap()
        eMailTextField.typeText("@")
        btnLoginButton.tap()
        okButton.tap()
        eMailTextField.typeText("google.de")
        btnLoginButton.tap()
        okButton.tap()
        
        let passwortSecureTextField = app.secureTextFields["Passwort"]
        passwortSecureTextField.tap()
        passwortSecureTextField.typeText("aaaaa")
        btnLoginButton.tap()
        okButton.tap()
        passwortSecureTextField.typeText("aaaaaa")
        
    }
    
}
