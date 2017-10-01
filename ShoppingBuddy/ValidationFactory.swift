//
//  ValidationFactory.swift
//  GrabItOrItsGone
//
//  Created by Peter Sypek on 17.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ValidationFactory {
    static var segmentedControl:UISegmentedControl?
    
    static func Validate(type: eValidationType, validationString: String?, alertDelegate: IAlertMessageDelegate?) -> Bool{
        switch type {
            
        case .email:
            let validationService = EmailValidationService()
            validationService.alertMessageDelegate = alertDelegate
            return validationService.Validate(validationString: validationString)
            
        case .password:
            let validationService = PasswordValidationService()
            validationService.alertMessageDelegate = alertDelegate
            return validationService.Validate(validationString: validationString)
            
        case .textField:
            let validationService = TextfieldValidationService()
            validationService.alertMessageDelegate = alertDelegate
            return validationService.Validate(validationString: validationString)
            
        case .segmentedControl:
            let validationService = SegmentedControlValidationService()
            validationService.alertMessageDelegate = alertDelegate
            return validationService.Validate(segmentedControl: segmentedControl)
            
        case .nickname:
            let validationService = NicknameValidationService()
            validationService.alertMessageDelegate = alertDelegate
            return validationService.Validate(validationString: validationString)
            
        case .fullVersionUser:
            let validationService = FullVersionUserValidationService()
            validationService.alertMessageDelegate = alertDelegate
            return validationService.Validate()
            
        default:
            return false
        }
    }
}
