//
//  PasswordValidation.swift
//  GrabIt
//
//  Created by Peter Sypek on 01.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

class PasswordValidationService:IValidationService  {
    var validationServiceDelegate:IValidationService?
    let title = String.ValidationAlert_Title
    var message = ""
    
    func Validate(validationString: String?) -> Bool{
        var isValid: Bool = false
        isValid = validateNotNil(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateNotEmpty(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateCharactersCountNotBelowSix(validationString: validationString)
        return isValid
    }
    
    private func validateNotNil(validationString: String?) -> Bool{
        if validationString == nil {
            message = String.ValidationPasswordEmptyAlert_Message
            ShowValidationAlert(title: title, message: message)
            return false
        }
        return true
    }
    private func validateNotEmpty(validationString: String?) -> Bool{
        if validationString == nil { return false }
        if validationString! == "" {
            message = String.ValidationPasswordEmptyAlert_Message
            ShowValidationAlert(title: title, message: message)
            return false
        }
        return true
    }
    private func validateCharactersCountNotBelowSix(validationString: String?) -> Bool{
        if validationString == nil { return false }
        if validationString!.characters.count < 6 {
            message = String.ValidationPasswordCharactersCountBelowSixAlert_Message
            ShowValidationAlert(title: title, message: message)
            return false
        }
        return true
    }
    func ShowValidationAlert(title: String, message: String) {
        if validationServiceDelegate != nil{
            validationServiceDelegate!.ShowValidationAlert!(title: title, message: message)
        } else {
            print("TextfieldValidationService: alertMessageDelegate not set from calling class")
        }
    }
} 
