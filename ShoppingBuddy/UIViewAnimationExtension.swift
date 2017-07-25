//
//  UIViewAnimationExtension.swift
//  Shopping-Buddy
//
//  Created by Peter Sypek on 21.06.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit 

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.3
        animation.values = [-8.0, 8.0, -6.0, 6.0, -3.0, 3.0, -1.5, 1.5, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    func HangingEffectBounce(duration:Double, delay:Double, spring:CGFloat){
        let originalCenter:CGPoint = self.center
        //Visiblity
        self.alpha = 1
        
        //Turn
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        self.center.y = self.center.y - (self.frame.height/2)
        self.transform = CGAffineTransform(rotationAngle: 1.8)
        
        //animate
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: spring, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        }) { (success) in
            self.center = originalCenter
            self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
    }
    
    func Arise(duration:Double, delay:Double, options:[UIViewAnimationOptions], toAlpha:CGFloat){
        UIView.animate(withDuration: (duration*0.5), delay: 0, options: [.curveEaseInOut], animations: {
            self.alpha = 0
        }, completion: {(finished: Bool) -> Void in
            UIView.animate(withDuration: (duration*0.5), delay: delay, options: [.curveEaseInOut], animations: { self.alpha = toAlpha }, completion: nil)
        })
    }
    
    func Bounce(duration:Double, delay:Double, spring:CGFloat){
        self.alpha = 1
        self.transform = CGAffineTransform(scaleX: 0.3, y: 2)
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: spring, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        }) { (Success) in
        }
    }
    
    func DropFromTop(duration:Double, delay:Double, spring:CGFloat){
        // Position view outside of top of superview
        self.transform = CGAffineTransform(translationX: 0, y: -(self.frame.height/2 + (self.superview?.frame.height)!))
        //Visiblity
        self.alpha = 1
        //animate
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: spring, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        })
    }
    
    func SpringFromBottom(duration:Double, delay:Double, spring:CGFloat){
        // Position view outside of bottom of superview
        self.transform = CGAffineTransform(translationX: 0, y: (self.frame.height/2 + (self.superview?.frame.height)!))
        //Visiblity
        self.alpha = 1
        //animate
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: spring, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        })
    }
    
    func SwipeFromLeft(duration:Double, delay:Double, spring:CGFloat){
        // Position view left outside of superview
        self.transform = CGAffineTransform(translationX: -(self.frame.width/2 + (self.superview?.frame.width)!/2), y: 0)
        //Visiblity
        self.alpha = 1
        //animate
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: spring, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        })
    }
    
    func SwipeFromRight(duration:Double, delay:Double, spring:CGFloat){
        // Position view left outside of superview
        self.transform = CGAffineTransform(translationX: (self.frame.width/2 + (self.superview?.frame.width)!/2), y: 0)
        //Visiblity
        self.alpha = 1
        //animate
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: spring, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        })
    }
    
    func Rotate(duration:Double, delay:Double, spring:CGFloat){
        //Visiblity
        self.alpha = 1
        // Rotate view
        self.transform = CGAffineTransform(rotationAngle: 3.6)
        //animate
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: spring, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        })
    }


}
