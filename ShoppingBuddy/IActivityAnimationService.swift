//
//  IActivityAnimationService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 18.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation


@objc protocol IActivityAnimationService {
    @objc optional var activityAnimationServiceDelegate:IActivityAnimationService? { get set }
    @objc optional func ShowActivityIndicator()
    @objc optional func HideActivityIndicator()
}
