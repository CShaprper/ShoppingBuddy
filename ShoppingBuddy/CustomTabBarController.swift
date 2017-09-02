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
    var mydelegate = ScrollingTabBarControllerDelegate()
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshMessagesBadgeValue), name: Notification.Name.RefreshMessagesBadgeValue, object: nil)
        
        self.delegate = mydelegate  
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset =  CGSize(width: -2, height: -2)
        let textAttributes = [NSFontAttributeName:UIFont(name: "Courgette-Regular", size: 10)!] as [String : Any]
         UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
        tabBar.backgroundImage = #imageLiteral(resourceName: "BottomNavBar")
        
        tabBar.items?[0].title = String.DashboardControllerTitle
        tabBar.items?[1].title = String.ShoppingListControllerTitle
        tabBar.items?[2].title = String.MessagesControllerTitle
        tabBar.items?[3].title = String.SettingsControllerTitle
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
    
    func RefreshMessagesBadgeValue(notification: Notification) -> Void {
        tabBar.items?[2].badgeValue = String(currentUser!.invites.count)
    }
    
    //MARK: - TabBar
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title! {
        case String.DashboardControllerTitle:
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.ColorPaletteTintColor()], for: .selected)
            break
        case String.ShoppingListControllerTitle:
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.ColorPaletteTintColor()], for: .selected)
            break
        case String.SettingsControllerTitle:
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.ColorPaletteTintColor()], for: .selected)
            break
        case String.MessagesControllerTitle:
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.ColorPaletteTintColor()], for: .selected)
            break
        default:
            break
        }
    } 
    
    //MARK: - Helper Functions
}
