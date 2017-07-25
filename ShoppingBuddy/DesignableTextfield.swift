//
//  DesignableTextfield.swift
//  Shopping-Buddy
//
//  Created by Peter Sypek on 15.06.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

//@IBDesignable
public class DesignableTextField: UITextField {
    
    @IBInspectable public var LeftImage: UIImage?{
        didSet{
            updateLeftView()
        }
    }
    
    @IBInspectable public var RightImage: UIImage?{
        didSet{
            updateRightView()
        }
    }
    
    
    @IBInspectable public var LeftImageTopPadding: CGFloat = 0{
        didSet{
            updateLeftView()
        }
    }
    
    @IBInspectable public var LeftImagePadding: CGFloat = 0{
        didSet{
            updateLeftView()
        }
    }
    
    
    @IBInspectable public var RightImageTopPadding: CGFloat = 0{
        didSet{
            updateLeftView()
        }
    }

    @IBInspectable public var RightImagePadding: CGFloat = 0{
        didSet{
            updateRightView()
        }
    }
    
    @IBInspectable public var RightImageVisibility: Bool = false{
        didSet{
            updateRightView()
        }
    }
    
    @IBInspectable public var LeftImageVisibility: Bool = false{
        didSet{
            updateLeftView()
        }
    }
    
    @IBInspectable public var WidthLeftImage: CGFloat = 20{
        didSet{
            updateLeftView()
        }
    }
    
    @IBInspectable public var HeightLeftImage: CGFloat = 20{
        didSet{
            updateLeftView()
        }
    }
    
    @IBInspectable public var WidthRightImage: CGFloat = 20{
        didSet{
            updateRightView()
        }
    }
    
    @IBInspectable public var HeightRightImage: CGFloat = 20{
        didSet{
            updateRightView()
        }
    }
    
    
    func updateLeftView() {
        if let image = LeftImage{
            leftViewMode = .always
            
            let imageview = UIImageView(frame: CGRect(x:LeftImagePadding, y:LeftImageTopPadding, width: WidthLeftImage, height: HeightLeftImage))
            imageview.image = image
            
            let view = UIView(frame: CGRect(x:0, y:0, width: WidthLeftImage, height: HeightLeftImage))
            view.addSubview(imageview)
            
            leftView = view    
            
            if LeftImageVisibility{
                leftView?.alpha = 1
            } else {
                leftView?.alpha = 0
            }
            
        } else {
            leftViewMode = .never
        }
        
    }
    
    func updateRightView() {
        if let image = RightImage{
            rightViewMode = .always
            
            let imageview = UIImageView(frame: CGRect(x:-RightImagePadding, y:RightImageTopPadding, width: WidthRightImage, height: HeightRightImage))
            imageview.image = image
            
            let view = UIView(frame: CGRect(x:0, y:0, width: WidthRightImage, height: HeightRightImage))
            view.addSubview(imageview)
            
            rightView = view
            
            if RightImageVisibility{
                rightView?.alpha = 1
            } else {
                rightView?.alpha = 0
            }
            
        } else {
            rightViewMode = .never
        }
    }
    

}
