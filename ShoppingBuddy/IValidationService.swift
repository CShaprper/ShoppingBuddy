//
//  IValidateable.swift
//  GrabIt
//
//  Created by Peter Sypek on 02.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

@objc protocol IValidationService: class , IAlertMessageDelegate{
    @objc optional func Validate(validationString: String?) -> Bool
    @objc optional func Validate(segmentedControl: UISegmentedControl?) -> Bool
}
