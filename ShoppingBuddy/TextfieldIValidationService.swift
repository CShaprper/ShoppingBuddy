//
//  UserInputValidationService.swift
//  GrabItOrItsGone
//
//  Created by Peter Sypek on 14.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation


class TextfieldValidationService: IValidationService {
    var alertMessageDelegate: IAlertMessageDelegate?
    var validationServiceDelegate:IValidationService?
    let title = String.ValidationAlert_Title
    var message = ""
    
    func Validate(validationString: String?) -> Bool {
        var isValid:Bool = false
        isValid = validateNotNil(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateStringEmpty(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateLessThanTwoCharacters(validationString: validationString)
        return isValid
    }
    
    private func validateNotNil(validationString: String?) -> Bool {
        if validationString == nil{
            message = String.ValidationTextFieldEmptyAlert_Message
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    
    private func validateStringEmpty(validationString: String?) -> Bool {
        if validationString == nil { return false }
        if validationString! == ""{
            message = String.ValidationTextFieldEmptyAlert_Message
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    private func validateLessThanTwoCharacters(validationString: String?) -> Bool{
        if validationString == nil { return false }
        if validationString!.count < 2{
            message = String.ValidationTextFieldBelowTwoCharachtersAlert_Message
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    internal func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil{
            alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
        } else{
            print("AlertMessageDelegate not set from calling class in TextfieldValidationService")
        }
    }
}
