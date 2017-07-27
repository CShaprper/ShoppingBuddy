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
    
    static func Validate(type: eValidationType, validationString: String?, delegate: IValidationService?) -> Bool{
        switch type {
            
        case .email:
            let validationService = EmailValidationService()
            validationService.validationServiceDelegate = delegate
            return validationService.Validate(validationString: validationString)
            
        case .password:
            let validationService = PasswordValidationService()
            validationService.validationServiceDelegate = delegate
            return validationService.Validate(validationString: validationString)
            
        case .textField:
            let validationService = TextfieldValidationService()
            validationService.validationServiceDelegate = delegate
            return validationService.Validate(validationString: validationString)
            
        case .segmentedControl:
            let validationService = SegmentedControlValidationService()
            validationService.validationServiceDelegate = delegate
            return validationService.Validate(segmentedControl: segmentedControl)
            
        case .nickname:
            let validationService = NicknameValidationService()
            validationService.validationServiceDelegate = delegate
            return validationService.Validate(validationString: validationString)
            
        default:
            return false
        }
    }
}
