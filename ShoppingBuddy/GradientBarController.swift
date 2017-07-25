//
//  GradientBarController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class GradientBarController: UITabBarController {
    //MARK: - Outlets

    
    //MARK: - Member
    var firebaseWebService:FirebaseWebService!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseWebService = FirebaseWebService()

        self.tabBar.tintColor = UIColor.white
        self.tabBarController?.selectedIndex = 1    
        
        
        //Hide back button to show custom Button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "log out", style: UIBarButtonItemStyle.plain, target: self, action:#selector(LogOutBarButtonItemPressed))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Tabbar Gradient
        let layerGradient = CAGradientLayer()
        layerGradient.colors = [UIColor.fromRGB(R: 61, G: 193, B: 202, alpha: 1).cgColor, UIColor.fromRGB(R: 0, G: 52, B: 84, alpha: 1).cgColor]
        layerGradient.startPoint = CGPoint(x: 0, y: 0)
        layerGradient.endPoint = CGPoint(x: 0, y: 0.7)
        layerGradient.frame = CGRect(x: 0, y: 0, width: self.tabBar.bounds.width,height: self.tabBar.bounds.height)
        self.tabBar.layer.insertSublayer(layerGradient, at: 0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationBar.appearance().tintColor = UIColor.white
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
