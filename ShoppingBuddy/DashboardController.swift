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
    @IBOutlet var TabBar: UIView!
    
    
    //MARK: - Member
    var firebaseWebService:FirebaseWebService!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Firebase Webservice
        firebaseWebService = FirebaseWebService()
        
         
        
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
    
    
    //MARK: - Wired Actions
    func SegueToLoginController(sender: Notification) -> Void{
        self.navigationController?.popViewController(animated: true)
    }
    
}
