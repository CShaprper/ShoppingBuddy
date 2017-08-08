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
    case StoresArray = "StoresArray"
    case LastUserLatitude = "LastUserLatitude"
    case LastUserLongitude = "LastUserLongitude"
    case isInitialLocationUpdate = "isInitialLocationUpdate"
    case hasUserChangedGeofenceRadius = "hasUserChangedGeofenceRadius"
}
