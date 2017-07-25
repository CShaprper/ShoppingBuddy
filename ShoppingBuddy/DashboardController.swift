//
//  DashboardController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class DashboardController: UIViewController{
    //MARK: - Outlets
    
    
    //MARK: - Member
    var firebaseWebService:FirebaseWebService!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Firebase Webservice
        firebaseWebService = FirebaseWebService()       
        
        //SetTitle
        self.tabBarItem.title = "Dashboard"
        
        //Notification Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(SegueToLoginController), name: NSNotification.Name.SegueToLogInController, object: nil)        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.tabBarController?.navigationItem.title = "Profile Settings"
    }
    
    
    //MARK: - Wired Actions
    func SegueToLoginController(sender: Notification) -> Void{
        self.navigationController?.popViewController(animated: true)
    }
    
}
