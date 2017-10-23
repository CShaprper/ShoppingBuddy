//
//  UIViewShadowExtension.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 07.10.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

extension UIView {
    public func addShadow(color: UIColor, size: CGFloat, radius: CGFloat) {
        
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: size, height: size)
        layer.shouldRasterize = true
        layer.masksToBounds = false
        
    }
    
}

