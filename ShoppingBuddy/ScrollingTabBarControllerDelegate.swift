//
//  ScrollingTabBarControllerDelegate.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 26.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ScrollingTabBarControllerDelegate: NSObject, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ScrollingTransitionAnimation(tabBarController: tabBarController, lastIndex: tabBarController.selectedIndex)
    }
}

class ScrollingTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var tabBarController:UITabBarController!
    var lastIndex:Int!
    var transitionContext:UIViewControllerContextTransitioning?
    
    init(tabBarController: UITabBarController, lastIndex: Int) {
        self.tabBarController = tabBarController
        self.lastIndex = lastIndex
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.transitionContext = transitionContext
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        containerView.addSubview(toViewController!.view)
        var viewWidth = CGRect(x: 0, y: 0, width: toViewController!.view.bounds.width, height: toViewController!.view.bounds.height).width
        if tabBarController.selectedIndex < lastIndex{
            viewWidth = -viewWidth
        }
        toViewController!.view.transform = CGAffineTransform(translationX: viewWidth, y: 0)
        
        UIView.animate(withDuration: self.transitionDuration(using: (self.transitionContext)), delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 2.5, options: .transitionFlipFromTop, animations: {
            toViewController!.view.transform = .identity
            fromViewController!.view.transform = CGAffineTransform(translationX: -viewWidth, y: 0)
        }, completion: { _ in
            self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled)
            fromViewController!.view.transform = .identity
        })
    }
}
