//
//  GradientBarController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    //MARK: - Outlets
    
    
    //MARK: - Member
    var initialTabBarItemIndex:Int!
    var firebaseWebService:FirebaseWebService!
    var mydelegate = ScrollingTabBarControllerDelegate()
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = mydelegate  
        
        firebaseWebService = FirebaseWebService()
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset =  CGSize(width: -2, height: -2)
        let textAttributes = [NSFontAttributeName:UIFont(name: "Blazed", size: 10)!,
                              NSShadowAttributeName:shadow] as [String : Any]
         UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
        
        tabBar.items?[0].title = String.DashboardControllerTitle
        tabBar.items?[1].title = String.ShoppingListControllerTitle
        tabBar.items?[2].title = String.StoresControllerTitle
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar customization
        tabBar.barTintColor = UIColor.ColorPaletteDarkest()
        tabBar.tintColor = UIColor.ColorPaletteTintColor()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return  .lightContent
    }
    
    //MARK: - TabBar
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title! {
        case "Dashboard":
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.ColorPaletteTintColor()], for: .selected)
            break
        case "Stores":
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.ColorPaletteTintColor()], for: .selected)
            break
        default:
            break
        }
    } 
    
    //MARK: - Helper Functions
}
