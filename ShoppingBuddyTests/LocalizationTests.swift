//
//  LocalizationTests.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import XCTest
@testable import ShoppingBuddy

class LocalizationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //Validation Service Alert
    func test_ValidationAlert_Title_isLocalized(){
        print(String.ValidationAlert_Title)
        XCTAssertTrue(String.ValidationAlert_Title != "ValidationAlert_Title", "ValidationAlert_Title is not localized in strings file!")
    }
    
    //Password validation
    func test_ValidationPasswordEmptyAlert_Message_isLocalized(){
        XCTAssertTrue(String.ValidationPasswordEmptyAlert_Message != "ValidationPasswordEmptyAlert_Message", "ValidationPasswordEmptyAlert_Message is not localized in strings file!")
    }
    func test_ValidationPasswordCharactersCountBelowSixAlert_Message_isLocalized(){
        XCTAssertTrue(String.ValidationPasswordCharactersCountBelowSixAlert_Message != "ValidationPasswordCharactersCountBelowSixAlert_Message", "ValidationPasswordCharactersCountBelowSixAlert_Message is not localized in strings file!")
    }
    
    //Nickname validation
    func test_ValidationNicknameEmptyAlert_Message_isLocalized(){
        XCTAssertTrue(String.ValidationNicknameEmptyAlert_Message != "ValidationNicknameEmptyAlert_Message", "ValidationNicknameEmptyAlert_Message is not localized in strings file!")
    }
    func test_ValidationNicknameShouldContainAtLeastSixCharacters_isLocalized(){
        XCTAssertTrue(String.ValidationNicknameShouldContainAtLeastSixCharacters != "ValidationNicknameShouldContainAtLeastSixCharacters", "ValidationNicknameShouldContainAtLeastSixCharacters is not localized in strings file!")
    }
    
    //Email validation
    func test_ValidationEmailEmptyAlert_Message_isLocalized(){
        XCTAssertTrue(String.ValidationEmailEmptyAlert_Message != "ValidationEmailEmptyAlert_Message", "ValidationEmailEmptyAlert_Message is not localized in strings file!")
    }
    func test_ValidationEmailShouldContainAtSign_isLocalized(){
        XCTAssertTrue(String.ValidationEmailShouldContainAtSign != "ValidationEmailShouldContainAtSign", "ValidationEmailShouldContainAtSign is not localized in strings file!")
    }
    func test_ValidationEmailShouldContainDot_isLocalized(){
        XCTAssertTrue(String.ValidationEmailShouldContainDot != "ValidationEmailShouldContainDot", "ValidationEmailShouldContainDot is not localized in strings file!")
    }
    func test_ValidationEmailContainsSpaces_isLocalized(){
        XCTAssertTrue(String.ValidationEmailContainsSpaces != "ValidationEmailContainsSpaces", "ValidationEmailContainsSpaces is not localized in strings file!")
    }
    func test_ValidationEmailEndingInvalid_isLocalized(){
        XCTAssertTrue(String.ValidationEmailEndingInvalid != "ValidationEmailEndingInvalid", "ValidationEmailEndingInvalid is not localized in strings file!")
    }
    func test_ValidationEmailContainsInvalidCharacters_isLocalized(){
        XCTAssertTrue(String.ValidationEmailContainsInvalidCharacters != "ValidationEmailContainsInvalidCharacters", "ValidationEmailContainsInvalidCharacters is not localized in strings file!")
    }
    
    //Textfield validation
    func test_ValidationTextFieldEmptyAlert_Message_isLocalized(){
        XCTAssertTrue(String.ValidationTextFieldEmptyAlert_Message != "ValidationTextFieldEmptyAlert_Message", "ValidationTextFieldEmptyAlert_Message is not localized in strings file!")
    }
    
    //LoginController
    func test_LogInSegmentedControll_SegmentOne_isLocalized(){
        XCTAssertTrue(String.LogInSegmentedControll_SegmentOne != "LogInSegmentedControll_SegmentOne", "LogInSegmentedControll_SegmentOne is not localized in strings file!")
    }
    func test_LogInSegmentedControll_SegmentTwo_isLocalized(){
        XCTAssertTrue(String.LogInSegmentedControll_SegmentTwo != "LogInSegmentedControll_SegmentTwo", "LogInSegmentedControll_SegmentTwo is not localized in strings file!")
    }
    func test_txt_Nickname_Placeholder_isLocalized(){
        XCTAssertTrue(String.txt_Nickname_Placeholder != "txt_Nickname_Placeholder", "txt_Nickname_Placeholder is not localized in strings file!")
    }
    func test_txt_Email_Placeholder_isLocalized(){
        XCTAssertTrue(String.txt_Email_Placeholder != "txt_Email_Placeholder", "txt_Email_Placeholder is not localized in strings file!")
    }
    func test_txt_Password_Placeholer_isLocalized(){
        XCTAssertTrue(String.txt_Password_Placeholer != "txt_Password_Placeholer", "txt_Password_Placeholer is not localized in strings file!")
    }
    func test_LoginResetPassword_isLocalized(){
        XCTAssertTrue(String.LoginResetPassword != "LoginResetPassword", "LoginResetPassword is not localized in strings file!")
    }
    
    //DashboardController
    func test_DashboardControllerTitle_isLocalized(){
        XCTAssertTrue(String.DashboardControllerTitle != "DashboardControllerTitle", "DashboardControllerTitle is not localized in strings file!")
    }
    
    //StoresController
    func test_SettingsControllerTitle_isLocalized(){
        XCTAssertTrue(String.SettingsControllerTitle != "SettingsControllerTitle", "SettingsControllerTitle is not localized in strings file!")
    }
    func test_txt_AddStore_Placeholder_isLocalized(){
        XCTAssertTrue(String.txt_AddStore_Placeholder != "txt_AddStore_Placeholder", "txt_AddStore_Placeholder is not localized in strings file!")
    }
    
    
    
    //ShoppingListController
    func test_ShoppingListControllerTitle_isLocalized(){
        XCTAssertTrue(String.ShoppingListControllerTitle != "ShoppingListControllerTitle", "ShoppingListControllerTitle is not localized in strings file!")
    }
    func test_CustomRefreshControlImage_isLocalized(){
        XCTAssertTrue(String.CustomRefreshControlImage != "CustomRefreshControlImage", "CustomRefreshControlImage is not localized in strings file!")
    }
    
    //LocationService
    func test_GPSAuthorizationRequestDenied_AlertTitle_isLocalized(){
        XCTAssertTrue(String.GPSAuthorizationRequestDenied_AlertTitle != "GPSAuthorizationRequestDenied_AlertTitle", "GPSAuthorizationRequestDenied_AlertTitle is not localized in strings file!")
    }
    func test_GPSAuthorizationRequestDenied_AlertMessage_isLocalized(){
        XCTAssertTrue(String.GPSAuthorizationRequestDenied_AlertMessage != "GPSAuthorizationRequestDenied_AlertMessage", "GPSAuthorizationRequestDenied_AlertMessage is not localized in strings file!")
    }
    func test_GPSAuthorizationRequestDenied_AlertActionSettingsTitle_isLocalized(){
        XCTAssertTrue(String.GPSAuthorizationRequestDenied_AlertActionSettingsTitle != "GPSAuthorizationRequestDenied_AlertActionSettingsTitle", "<#name of string#> is not localized in strings file!")
    }
    func test_GPSAuthorizationRequestDenied_AlertActionSettingsNoTitle_isLocalized(){
        XCTAssertTrue(String.GPSAuthorizationRequestDenied_AlertActionSettingsNoTitle != "GPSAuthorizationRequestDenied_AlertActionSettingsNoTitle", "GPSAuthorizationRequestDenied_AlertActionSettingsNoTitle is not localized in strings file!")
    }
    func test_LocationManagerEnteredRegion_AlertTitle_isLocalized(){
        XCTAssertTrue(String.LocationManagerEnteredRegion_AlertTitle != "LocationManagerEnteredRegion_AlertTitle", "LocationManagerEnteredRegion_AlertTitle is not localized in strings file!")
    }
    func test_LocationManagerEnteredRegion_AlertMessage_isLocalized(){
        XCTAssertTrue(String.LocationManagerEnteredRegion_AlertMessage != "LocationManagerEnteredRegion_AlertMessage", "LocationManagerEnteredRegion_AlertMessage is not localized in strings file!")
    }
}
