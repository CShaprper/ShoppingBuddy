//
//  IAlertMessageDelegate.swift
//  GrabIt
//
//  Created by Peter Sypek on 03.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

@objc protocol IAlertMessageDelegate: class {
    @objc optional var alertMessageDelegate:IAlertMessageDelegate? { get set }  
    func ShowAlertMessage(title: String, message: String)->Void
}
