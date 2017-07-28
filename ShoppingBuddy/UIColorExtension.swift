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
    static func ColorPaletteorange() ->UIColor{
        return UIColor(red: 249 / 255, green: 107 / 255, blue: 0 / 255,  alpha: 1)
    }
    static func ColorPaletteDarkest() ->UIColor{
        return UIColor(red: 114 / 255, green: 105 / 255, blue: 140 / 255,  alpha: 1)
    }
    static func ColorPaletteSecondDarkest() ->UIColor{
        return UIColor(red: 98 / 255, green: 126 / 255, blue: 156 / 255,  alpha: 1)
    }
    static func ColorPaletteMiddle() ->UIColor{
        return UIColor(red: 48 / 255, green: 170 / 255, blue: 184 / 255,  alpha: 1)
    }
    static func ColorPaletteSecondBrightest() ->UIColor{
        return UIColor(red: 167 / 255, green: 244 / 255, blue: 186 / 255,  alpha: 1)
    }
    static func ColorPaletteBrightest() ->UIColor{
        return UIColor(red: 216 / 255, green: 243 / 255, blue: 166 / 255,  alpha: 1)
    }
    static func ColorPaletteTintColor() ->UIColor{
        return UIColor(red: 247 / 255, green: 153 / 255, blue: 19 / 255,  alpha: 1)
    }
}
