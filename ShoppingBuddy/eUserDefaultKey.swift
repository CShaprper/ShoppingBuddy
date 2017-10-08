//
//  eUserDefaultKey.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 03.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

enum eUserDefaultKey:String {
    case MonitoredRadius = "MonitoredRadius"
    case MonitoredRegions = "MonitoredRegions"
    case MapSpan = "MapSpan"
    case ListIDsArray = "ListIDsArray"
    case HomeLatitude = "HomeLatitude"
    case HomeLongitude = "HomeLongitude"
    case isInitialLocationUpdate = "isInitialLocationUpdate"
    case NeedToUpdateGeofence = "NeedToUpdateGeofence"
    case UserProfileImageURL = "UserProfileImageURL"
    case CurrentUserID = "CurrentUserID" 
}
