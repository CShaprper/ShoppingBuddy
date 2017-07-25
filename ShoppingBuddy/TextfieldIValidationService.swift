//
//  UserInputValidationService.swift
//  GrabItOrItsGone
//
//  Created by Peter Sypek on 14.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation


class TextfieldValidationService: IValidationService {
    var validationServiceDelegate:IValidationService?
    let title = ""
    var message = ""
    
    func Validate(validationString: String?) -> Bool {
        var isValid:Bool = false
        isValid = validateNotNil(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateStringEmpty(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateLessThanThreeCharacters(validationString: validationString)
        return isValid
    }
    
    private func validateNotNil(validationString: String?) -> Bool {
        if validationString == nil{
            message = ""
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    
    private func validateStringEmpty(validationString: String?) -> Bool {
        if validationString == nil { return false }
        if validationString! == ""{
            message = ""
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    private func validateLessThanThreeCharacters(validationString: String?) -> Bool{
        if validationString == nil { return false }
        if validationString!.characters.count < 3{
            message = ""
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    internal func ShowAlertMessage(title: String, message: String) {
        if validationServiceDelegate != nil {
            validationServiceDelegate!.ShowValidationAlert!(title: title, message: message)
        } else {
            print("TextfieldInputValidationService: alertMessageDelegate not set from calling class")
        }
    }
}
