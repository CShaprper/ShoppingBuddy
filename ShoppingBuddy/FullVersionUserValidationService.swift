//
//  FullVersionUserValidationService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 02.10.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

class FullVersionUserValidationService: IValidationService {
    var alertMessageDelegate: IAlertMessageDelegate?
    var validationServiceDelegate: IValidationService?
    let title = String.ValidationAlert_Title
    var message = ""
    
    func Validate() -> Bool {
        var isValid:Bool = false
        isValid = validateUserAsFullVersionUser()
        return isValid
    }
    
    private func validateUserAsFullVersionUser() -> Bool {
        
        let fullVersionStatus = UserDefaults.standard.bool(forKey: eUserDefaultKey.isFullVersionUser.rawValue)
        if fullVersionStatus == false {
            return false
        }
        
        return fullVersionStatus
    }
    
    internal func ShowAlertMessage(title: String, message: String) {
        
        if alertMessageDelegate != nil{
            alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
        }
        
    }
}
