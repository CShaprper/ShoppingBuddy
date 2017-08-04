//
//  DesignableUISlider.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 05.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableUISlider: UISlider {

    @IBInspectable
    var ThumbImage:UIImage?{
        didSet{
            setThumbImage(ThumbImage, for: .normal)
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var HighligtedThumbImage:UIImage?{
        didSet{
            setThumbImage(ThumbImage, for: .highlighted)
            setNeedsDisplay()
        }
    }

}
