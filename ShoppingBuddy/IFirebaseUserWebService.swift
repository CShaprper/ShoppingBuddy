//
//  IFrrebaseUserWebService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 18.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

@objc protocol IFirebaseUserWebservice: IActivityAnimationService {
    @objc optional var firebaseUserWebserviceDelegate:IFirebaseUserWebservice? { get  set }
    @objc optional func UserProfileImageDownloadFinished()
    @objc optional func FirebaseUserLoggedIn()
    @objc optional func FirebaseUserLoggedOut() 
}
