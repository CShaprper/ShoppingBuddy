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
        
         UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Blazed", size: 10)!], for: .normal)
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
        tabBar.tintColor = UIColor.ColorPaletteBrightest()
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
            tabBar.tintColor = UIColor.ColorPaletteBrightest()
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.ColorPaletteBrightest()], for: .selected)
            break
        case "Stores":
            tabBar.tintColor = UIColor.ColorPaletteBrightest()
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.ColorPaletteBrightest()], for: .selected)
            break
        default:
            break
        }
    }
    
    
    
    //MARK: - Wired Actions
    func LogOutBarButtonItemPressed(sender: UIBarButtonItem) -> Void{
        firebaseWebService.LogUserOut()
    }
    func SegueToLoginController(sender: Notification) -> Void{
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Helper Functions
}
