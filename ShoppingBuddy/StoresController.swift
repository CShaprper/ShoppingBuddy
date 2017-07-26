//
//  StoresController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class StoresController: UIViewController {
    //MARK: - Outlets
    @IBOutlet var BackgroundView: DesignableUIView!
    
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SetTitle
        navigationItem.title = String.StoresControllerTitle
        
        
        //Add Store Button
        let addStore = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-AddStore"), style: .plain, target: self, action: #selector(AddStoreBarButtonItemPressed))
        navigationItem.rightBarButtonItem = addStore
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = String.StoresControllerTitle
    }
    
    
    //MARK: - Wired actions
    func AddStoreBarButtonItemPressed(sender: UIBarButtonItem) -> Void{
        
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
