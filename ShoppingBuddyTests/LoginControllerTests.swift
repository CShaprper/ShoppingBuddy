//
//  ShoppingBuddyTests.swift
//  ShoppingBuddyTests
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import XCTest
@testable import ShoppingBuddy

class LoginControllerTests: XCTestCase {
    var storyboard:UIStoryboard!
    var sut:LoginController?
    
    override func setUp() {
        super.setUp()
        storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        sut = storyboard.instantiateViewController(withIdentifier: "LoginController") as? LoginController   
        
        // Test and Load the View at the Same Time!
        XCTAssertNotNil(sut?.view)
        sut?.viewDidLoad()
        sut?.viewWillAppear(false)
        sut?.didReceiveMemoryWarning()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    //BackgroundImage
    func test_BackgroundImage_Exists(){
        XCTAssertNotNil(sut!.BackgroundView, "BackgroundView should exist")
    }
    
    //Login Container
    func test_LoginContainer_Exists(){
        XCTAssertNotNil(sut!.LoginContainer, "LoginContainer should exist")
    }
    func test_LoginContainerBackground_Exists(){
        XCTAssertNotNil(sut!.LoginContainerBackground, "LoginContainerBackground should exist")
    }
    func test_LoginContainerBackground_CornerRadius(){
        XCTAssertEqual(sut!.LoginContainerBackground.layer.cornerRadius, 20, "LoginContainerBackground cornerRadius should be 20")
    }
    
    //txt_Nickname
    func test_NicknameContainer_Exists(){
        XCTAssertNotNil(sut!.NicknameContainer, "NicknameContainer should exist")
    }
    func test_txt_Nickname_Exists(){
        XCTAssertNotNil(sut!.txt_Nickname, "txt_Nickname should exist")
    }
    func test_txt_Nickname_Placeholder_isSet(){
        XCTAssertTrue(sut!.txt_Nickname.placeholder != "", "Missing placeholder value")
    }
    func test_txt_Nickname_Placeholder_isNotNil(){
        XCTAssertNotNil(sut!.txt_Nickname.placeholder, "Placeholder not set")
    }
    func test_txt_NicknameDelegate_isSet() {
        XCTAssertNotNil(sut!.txt_Nickname.delegate, "txt_Nickname.delegate not set")
    }
    
    
    //txt_Email
    func test_EmailContainer_Exists(){
        XCTAssertNotNil(sut!.EmailContainer, "EmailContainer should exist")
    }
    func test_txt_Email_Exists(){
        XCTAssertNotNil(sut!.txt_Email, "txt_Email should exist")
    }
    func test_txt_EmailDelegate_isSet() {
        XCTAssertNotNil(sut!.txt_Email.delegate, "txt_Email.delegate not set")
    }
    func test_txt_Email_Placeholder_Placeholder_isSet(){
        XCTAssertTrue(sut!.txt_Email.placeholder != "", "Missing placeholder value")
    }
    func test_txt_Email_Placeholder_isNotNil(){
        XCTAssertNotNil(sut!.txt_Email.placeholder, "Placeholder not set")
    }
    func test_EmailSeperator_Exists(){
        XCTAssertNotNil(sut!.EmailSeperator, "EmailSeperator should exist")
    } 
    
    //txt_Password
    func test_PasswordContainer_Exists(){
        XCTAssertNotNil(sut!.PasswordContainer, "PasswordContainer should exist")
    }
    func test_txt_Password_Exists(){
        XCTAssertNotNil(sut!.txt_Password, "txt_Password should exist")
    }
    func test_txt_PasswordDelegate_isSet() {
        XCTAssertNotNil(sut!.txt_Password.delegate, "txt_Password.delegate not set")
    }
    func test_txt_Password_Placeholder_isSet(){
        XCTAssertTrue(sut!.txt_Password.placeholder != "", "Missing placeholder value")
    }
    func test_txt_Password_Placeholder_ShowsLocalizedString(){
        XCTAssertEqual(sut!.txt_Password.placeholder, String.txt_Password_Placeholer, "txt_Password_Placeholer not localized")
    }
    func test_txt_Password_Placeholder_Placeholder_isNotNil(){
        XCTAssertNotNil(sut!.txt_Password.placeholder, "Placeholder not set")
    }
    
    //LoginSignUp Segmented Control
    func test_LoginSignUpSegmentedControl_Exists(){
        XCTAssertNotNil(sut!.LoginSignUpSegmentedControl, "LoginSignUpSegmentedControl should exist")
    }
    func test_LoginSignUpSegementedControll_hasTwoSegments(){
        XCTAssertTrue(sut!.LoginSignUpSegmentedControl.numberOfSegments == 2, "LoginSignUpSegmentedControl should have two segments")
    }
    func test_LoginSignUpSegmentedControlSegmentOne_isLocalized(){
        XCTAssertEqual(sut!.LoginSignUpSegmentedControl.titleForSegment(at: 0), String.LogInSegmentedControll_SegmentOne, "LoginSignUpSegementedControlSegmentOne title should be \(String.LogInSegmentedControll_SegmentOne) current title \(String(describing: sut!.LoginSignUpSegmentedControl.titleForSegment(at: 0)))")
    }
    func test_LoginSignUpSegmentedControlSegmentTwo_isLocalized(){
        XCTAssertEqual(sut!.LoginSignUpSegmentedControl.titleForSegment(at: 1), String.LogInSegmentedControll_SegmentTwo, "LoginSignUpSegementedControlSegmentTwo title should be \(String.LogInSegmentedControll_SegmentTwo) current title \(String(describing: sut!.LoginSignUpSegmentedControl.titleForSegment(at: 1)))")
    }
    
    //btn_Login
    func test_ButtonContainer_Exists(){
        XCTAssertNotNil(sut!.ButtonContainer, "ButtonContainer should exist")
    }
    func test_btn_Login_Exists(){
        XCTAssertNotNil(sut!.btn_Login, "btn_Login should exist")
    }
    func test_btn_Login_isWired_ToAction(){
        XCTAssertTrue(ControlTagetTester.checkTargetForOutlet(outlet: sut!.btn_Login, actionName: "btn_Login_Pressed", event: .touchUpInside, controller: sut! ))
    }
}
