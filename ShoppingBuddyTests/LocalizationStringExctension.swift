//
//  LocalizationStringExctension.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

extension String{
    //Validation Service Alert
    static let ValidationAlert_Title = NSLocalizedString("ValidationAlert_Title", comment: "")
    
    //Password validation
    static let ValidationPasswordEmptyAlert_Message = NSLocalizedString("ValidationPasswordEmptyAlert_Message", comment: "")
    static let ValidationPasswordCharactersCountBelowSixAlert_Message = NSLocalizedString("ValidationPasswordCharactersCountBelowSixAlert_Message", comment: "")
    
    //Nickname validation
    static let ValidationNicknameEmptyAlert_Message = NSLocalizedString("ValidationNicknameEmptyAlert_Message", comment: "")
    static let ValidationNicknameShouldContainAtLeastSixCharacters = NSLocalizedString("ValidationNicknameShouldContainAtLeastSixCharacters", comment: "")
    
    //Email validation
    static let ValidationEmailEmptyAlert_Message = NSLocalizedString("ValidationEmailEmptyAlert_Message", comment: "")
    static let ValidationEmailShouldContainAtSign = NSLocalizedString("ValidationEmailShouldContainAtSign", comment: "")
    static let ValidationEmailShouldContainDot = NSLocalizedString("ValidationEmailShouldContainDot", comment: "")
    static let ValidationEmailContainsSpaces = NSLocalizedString("ValidationEmailContainsSpaces", comment: "")
    static let ValidationEmailEndingInvalid = NSLocalizedString("ValidationEmailEndingInvalid", comment: "")
    static let ValidationEmailContainsInvalidCharacters = NSLocalizedString("ValidationEmailContainsInvalidCharacters", comment: "")
    
    //Textfield validation
    static let ValidationTextFieldEmptyAlert_Message = NSLocalizedString("ValidationTextFieldEmptyAlert_Message", comment: "")
    static let ValidationTextFieldBelowTwoCharachtersAlert_Message = NSLocalizedString("ValidationTextFieldBelowTwoCharachtersAlert_Message", comment: "")
    
    //LoginController
    static let LogInSegmentedControll_SegmentOne = NSLocalizedString("LogInSegmentedControll_SegmentOne", comment: "")
    static let LogInSegmentedControll_SegmentTwo = NSLocalizedString("LogInSegmentedControll_SegmentTwo", comment: "")
    static let txt_Nickname_Placeholder = NSLocalizedString("txt_Nickname_Placeholder", comment: "")
    static let txt_Email_Placeholder = NSLocalizedString("txt_Email_Placeholder", comment: "")
    static let txt_Password_Placeholer = NSLocalizedString("txt_Password_Placeholer", comment: "")
    static let LoginResetPassword = NSLocalizedString("LoginResetPassword", comment: "")
    
    //DashboardController
    static let DashboardControllerTitle = NSLocalizedString("DashboardControllerTitle", comment: "")
    
    //StoresController
    static let StoresControllerTitle = NSLocalizedString("StoresControllerTitle", comment: "")
    static let txt_AddStore_Placeholder = NSLocalizedString("txt_AddStore_Placeholder", comment: "")
}
