//
//  DesignableUIView.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

@IBDesignable
public class DesignableUIView:UIView{
    
    @IBInspectable public var TopColor: UIColor = UIColor.clear{
        didSet{
            updateView()
        }
    }
    @IBInspectable public var BottomColor: UIColor = UIColor.clear{
        didSet{
           updateView()
        }
    }
    @IBInspectable public var CornerRadius:CGFloat = 0{
        didSet{
            updateView()
        }
    }
    @IBInspectable public var TopLocation:Double = 0.5{
        didSet{
            updateView()
        }
    }
    
    override public class var layerClass: AnyClass{
        get{
            return CAGradientLayer.self
        }
    }
    
    func updateView(){
        self.clipsToBounds = true
        let layer = self.layer as! CAGradientLayer
        self.layer.cornerRadius = CornerRadius
        layer.colors = [TopColor.cgColor, BottomColor.cgColor]
        layer.locations = [NSNumber(floatLiteral: TopLocation)]
        layer.bounds = self.layer.bounds 
    }
}
