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
    var firebaseWebService:FirebaseWebService!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseWebService = FirebaseWebService()
        
        //Hide back button to show custom Button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "log out", style: UIBarButtonItemStyle.plain, target: self, action:#selector(LogOutBarButtonItemPressed))
        self.navigationItem.leftBarButtonItem = newBackButton
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
            tabBar.tintColor = UIColor.fromRGB(R: 247, G: 186, B: 19, alpha: 1)
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.fromRGB(R: 247, G: 186, B: 19, alpha: 1)], for: .selected)
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

}
