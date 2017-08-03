//
//  SegmentedControlValidationService.swift
//  GrabItOrItsGone
//
//  Created by Peter Sypek on 14.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class SegmentedControlValidationService: IValidationService {
    var alertMessageDelegate: IAlertMessageDelegate?
    var validationServiceDelegate:IValidationService?
    let title = ""
    var message = ""
    
    func Validate(segmentedControl: UISegmentedControl?) -> Bool {
        var isValid:Bool = false        
        isValid = validateNotNil(segmentedControl: segmentedControl)
        if !isValid { return isValid }
        isValid = validateIsSet(segmentedControl: segmentedControl)
        return isValid
    }
    
    private func validateNotNil(segmentedControl: UISegmentedControl?) -> Bool{
        if segmentedControl == nil {
            ShowAlertMessage(title: title, message: message)
             return false
        }
        return true
    }
    private func validateIsSet(segmentedControl: UISegmentedControl?) -> Bool{
        if segmentedControl == nil { return false }
        if segmentedControl!.selectedSegmentIndex == -1 {
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
