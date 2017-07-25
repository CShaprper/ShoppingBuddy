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
    var alertMock:FakeAlertMock!
    var passwordValidation:PasswordValidationService!
    var nicknameValidation:NicknameValidationService!
    var emailValidation:EmailValidationService!
    
    override func setUp() {
        super.setUp()
        alertMock = FakeAlertMock()
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
    //MARK: - Fake Alert Mock
    /*public class FakeAlertMock:IAlertMessageDelegate {
     var title:String?
     var message:String?
     public func initAlertMessageDelegate(delegate: IAlertMessageDelegate) {
     }
     
     public func ShowAlertMessage(title: String, message: String) {
     self.title = title
     self.message = message
     }
     }*/
    
    
    
}


//MARK: - Fake Alert Mock
public class FakeAlertMock:IValidationService {
    var title:String?
    var message:String?
    
    public func ShowValidationAlert(title: String, message: String) {
        self.title = title
        self.message = message
    }
}
