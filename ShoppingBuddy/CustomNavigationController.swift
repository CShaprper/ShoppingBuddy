//
//  CustomNavigationController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor.ColorPaletteSecondDarkest()        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Global NavigationBar Style
        navigationBar.tintColor = UIColor.ColorPaletteSecondDarkest()
        navigationBar.barTintColor = UIColor.ColorPaletteBrightest()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.ColorPaletteSecondDarkest(), NSFontAttributeName:UIFont(name: "Blazed", size: 20)!]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
