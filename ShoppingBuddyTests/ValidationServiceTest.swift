//
//  ValidationServiceTest.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import XCTest
@testable import ShoppingBuddy

class ValidationServiceTest: XCTestCase {
    var alertMock:FakeValidationAlertMock!
    var passwordValidation:PasswordValidationService!
    var nicknameValidation:NicknameValidationService!
    var emailValidation:EmailValidationService!
    
    override func setUp() {
        super.setUp()
        alertMock = FakeValidationAlertMock()
        passwordValidation = PasswordValidationService()
        nicknameValidation = NicknameValidationService()
        emailValidation = EmailValidationService()
    }
    
    override func tearDown() {
        passwordValidation = nil
        nicknameValidation = nil
        emailValidation = nil
        alertMock = nil
        super.tearDown()
    }
    
    //MARK:- Password Validation
    func test_Validation_Passes_When_PassWord_hasSixCharacters() {
        XCTAssertTrue(passwordValidation.Validate(validationString: "123456"), "Validation should pass when validated string is six characters ore more")
    }
    func test_Validation_Failes_When_PassWord_hasLessThanSixCharacters(){
        XCTAssertFalse(passwordValidation.Validate(validationString: "12345"), "Validation should fail when valideted string is below six characters")
    }
    func test_Validation_Failes_When_PassWord_hasLessThanFiveCharacters(){
        XCTAssertFalse(passwordValidation.Validate(validationString: "1234"), "Validation should fail when valideted string is below five characters")
    }
    func test_PasswordValidationEmpty_ShowsCorrectAlertMessage(){
        passwordValidation.validationServiceDelegate = alertMock
        let _ = passwordValidation.Validate(validationString: "")
        XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is \(alertMock.title!) should be: \(String.ValidationAlert_Title)")
        XCTAssertTrue(alertMock.message! == String.ValidationPasswordEmptyAlert_Message, "Alert Message is \(alertMock.message!) should be: \(String.ValidationPasswordEmptyAlert_Message)")
    }
    func test_PasswordValidationBelowSixCharacters_ShowsCorrectAlertMessage(){
        let _ = ValidationFactory.Validate(type: .password, validationString: "12345", delegate: alertMock)
        XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is \(alertMock.title!) should be: \(String.ValidationAlert_Title)")
        XCTAssertTrue(alertMock.message! == String.ValidationPasswordCharactersCountBelowSixAlert_Message, "Alert Message is \(alertMock.message!) should be: \(String.ValidationPasswordCharactersCountBelowSixAlert_Message)")
    }
    
    //MARK: - Nickname Validation
    func test_NicknameValidationFails_onEmptyString(){
        XCTAssertFalse(nicknameValidation.Validate(validationString: ""), "Nickname validation should fail on empty string")
    }
    func test_NicknameValidatonFails_belowSixCharackters(){
        XCTAssertFalse(nicknameValidation.Validate(validationString: "1"), "Nickname Validation should fail below six characters")
        XCTAssertFalse(nicknameValidation.Validate(validationString: "12"), "Nickname Validation should fail below six characters")
        XCTAssertFalse(nicknameValidation.Validate(validationString: "123"), "Nickname Validation should fail below six characters")
        XCTAssertFalse(nicknameValidation.Validate(validationString: "1234"), "Nickname Validation should fail below six characters")
        XCTAssertFalse(nicknameValidation.Validate(validationString: "12345"), "Nickname Validation should fail below six characters")
    }
    func test_NicknameValidatonPasses_onSixCharachters(){
        XCTAssertTrue(nicknameValidation.Validate(validationString: "123456"), "Nickname validation should pass with six characters")
    }
    func test_txt_NicknameEmpty_ShowsCorrectAlertMessage(){
        let _ = ValidationFactory.Validate(type: .nickname, validationString: "", delegate: alertMock)
        XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is -\(alertMock.title!)- should be: -\(String.ValidationAlert_Title)-")
        XCTAssertTrue(alertMock.message! == String.ValidationNicknameEmptyAlert_Message, "Alert Message is -\(alertMock.message!)- should be: -\(String.ValidationNicknameEmptyAlert_Message)-")
    }
    func test_NicknameValidationBelowSixCharacters_ShowsCorrectAlertMessage(){
        let _ = ValidationFactory.Validate(type: .nickname, validationString: "12345", delegate: alertMock)
        XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is -\(alertMock.title!)- should be: -\(String.ValidationAlert_Title)-")
        XCTAssertTrue(alertMock.message! == String.ValidationNicknameShouldContainAtLeastSixCharacters, "Alert Message is -\(alertMock.message!)- should be: -\(String.ValidationNicknameShouldContainAtLeastSixCharacters)-")
    }
    
    //MARK: - Email Validation
    func test_EmailValidationEmpty_ShowsCorrectAlertMessage(){
        let _ = ValidationFactory.Validate(type: .email, validationString: "", delegate: alertMock)
        XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is -\(alertMock.title!)- should be: -\(String.ValidationAlert_Title)-")
        XCTAssertTrue(alertMock.message! == String.ValidationEmailEmptyAlert_Message, "Alert Message is -\(alertMock.message!)- should be: -\(String.ValidationEmailEmptyAlert_Message)-")
    }
    func test_EmailValidationContainsAtSign_ShowsCorrectAlertMessage(){
        let _ = ValidationFactory.Validate(type: .email, validationString: "p.sypekgmail.com", delegate: alertMock)
        XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is -\(alertMock.title!)- should be: -\(String.ValidationAlert_Title)-")
        XCTAssertTrue(alertMock.message! == String.ValidationEmailShouldContainAtSign, "Alert Message is -\(alertMock.message!)- should be: -\(String.ValidationEmailShouldContainAtSign)-")
    }
    func test_EmailValidationShouldContainDot_ShowsCorrectAlertMessage(){
        let _ = ValidationFactory.Validate(type: .email, validationString: "psypek@gmailde", delegate: alertMock)
        XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is -\(alertMock.title!)- should be: -\(String.ValidationAlert_Title)-")
        XCTAssertTrue(alertMock.message! == String.ValidationEmailShouldContainDot, "Alert Message is -\(alertMock.message!)- should be: -\(String.ValidationEmailShouldContainDot)-")
    }
    func test_EmailValidationContainsSpaces_ShowsCorrectAlertMessage(){
        let _ = ValidationFactory.Validate(type: .email, validationString: "petter @sypek.de", delegate: alertMock)
        XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is -\(alertMock.title!)- should be: -\(String.ValidationAlert_Title)-")
        XCTAssertTrue(alertMock.message! == String.ValidationEmailContainsSpaces, "Alert Message is -\(alertMock.message!)- should be: -\(String.ValidationEmailContainsSpaces)-")
    }
    func test_ValidationEmailShouldEndCorrect_ShowsCorrectAlertMessage(){
        let _ = ValidationFactory.Validate(type: .email, validationString: "p.sypek@zwilling.d", delegate: alertMock)
        XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is -\(alertMock.title!)- should be: -\(String.ValidationAlert_Title)-")
        XCTAssertTrue(alertMock.message! == String.ValidationEmailEndingInvalid, "Alert Message is -\(alertMock.message!)- should be: -\(String.ValidationEmailEndingInvalid)-")
    }
    
    //MARK: - TextField Validation
    func test_TextFieldValidationFails_BelowTwoCharachters(){
        XCTAssertFalse(ValidationFactory.Validate(type: .textField, validationString: "1", delegate: nil), "Textfield validation should fail below two charachters")
    }
    func test_TextfieldValidationServiceEmpty_ShowsCorrectAlertMessage(){
        let _ = ValidationFactory.Validate(type: .textField, validationString: "1", delegate: alertMock)
    XCTAssertTrue(alertMock.title! == String.ValidationAlert_Title, "Alert Title is -\(alertMock.title!)- should be: -\(String.ValidationAlert_Title)-")
    XCTAssertTrue(alertMock.message! == String.ValidationTextFieldBelowTwoCharachtersAlert_Message, "Alert Message is -\(alertMock.message!)- should be: -\(String.ValidationTextFieldEmptyAlert_Message)-")
    }
}

