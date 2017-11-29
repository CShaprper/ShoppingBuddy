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
        
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshMessagesBadgeValue), name: Notification.Name.AllInvitesReceived, object: nil)
        
        self.delegate = mydelegate  
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset =  CGSize(width: -2, height: -2)
        
        //choose normal and selected fonts here
        let normalTitleFont = UIFont(name: "Courgette-Regular", size: 10)!
        
        //choose normal and selected colors here
        let normalTitleColor = UIColor.gray
        
        let attributesNormal = [
            NSAttributedStringKey.foregroundColor : normalTitleColor,
            NSAttributedStringKey.font :normalTitleFont
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributesNormal, for: .normal)
        tabBar.backgroundImage = #imageLiteral(resourceName: "NavBarBottom").resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch)
        
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
    
    
    @objc func RefreshMessagesBadgeValue(notification: Notification) -> Void {
        tabBar.items?[2].badgeValue = allMessages.count > 0 ? String(allMessages.count) : nil
    }
    
    //MARK: - TabBar
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        let selectedTitleFont = UIFont(name: "Courgette-Regular", size: 8)!
        let selectedTitleColor = UIColor.ColorPaletteTintColor()
        
        let attributesSelected = [
            NSAttributedStringKey.foregroundColor : selectedTitleColor,
            NSAttributedStringKey.font :selectedTitleFont
        ]
        
        switch item.title! {
        case String.DashboardControllerTitle:
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes(attributesSelected, for: .selected)
            break
        case String.ShoppingListControllerTitle:
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes(attributesSelected, for: .selected)
            break
        case String.SettingsControllerTitle:
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes(attributesSelected, for: .selected)
            break
        case String.MessagesControllerTitle:
            tabBar.tintColor = UIColor.ColorPaletteTintColor()
            item.setTitleTextAttributes(attributesSelected, for: .selected)
            break
        default:
            break
        }
        
    } 
    
    //MARK: - Helper Functions
}

extension UITabBar{
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        super.sizeThatFits(size)
        var mySize:CGSize = size
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                mySize.height = 105
                return mySize
            default:
                   mySize.height = 44
                return mySize
            }
        }
        return size
    }
}
