//
//  IFirebaseWebService.swift
//  GrabItOrItsGone
//
//  Created by Peter Sypek on 19.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

@objc protocol IFirebaseWebService: IAlertMessageDelegate {
    @objc optional var firebaseWebServiceDelegate:IFirebaseWebService? { get set }
    @objc optional func FirebaseRequestStarted() -> Void
    @objc optional func FirebaseRequestFinished() -> Void
    @objc optional func FirebaseUserLoggedIn() -> Void
    @objc optional func FirebaseUserLoggedOut() -> Void
    @objc optional func ReloadItems() -> Void
}
