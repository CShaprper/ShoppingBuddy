//
//  UIColorExtension.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

extension UIColor{
   static func fromRGB(R:CGFloat, G:CGFloat, B:CGFloat, alpha:CGFloat) -> UIColor {
        return UIColor(red: R / 255, green: G / 255, blue: B / 255,  alpha: alpha
        )
    }
}
