//
//  IValidateable.swift
//  GrabIt
//
//  Created by Peter Sypek on 02.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

@objc protocol IValidationService: class {
    @objc optional var validationServiceDelegate:IValidationService? { get  set }
    @objc optional func Validate(validationString: String?) -> Bool
    @objc optional func Validate(segmentedControl: UISegmentedControl?) -> Bool
    @objc optional func ShowValidationAlert(title: String, message:String) -> Void
}
