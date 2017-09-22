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
        navigationBar.barTintColor = UIColor.ColorPaletteSecondBrightest()
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 35
        shadow.shadowOffset =  CGSize(width: -2, height: -2)
        let textAttributes = [NSAttributedStringKey.shadow.rawValue:shadow,
                              NSAttributedStringKey.foregroundColor:UIColor.ColorPaletteTintColor(),
                              NSAttributedStringKey.font:UIFont(name: "Courgette-Regular", size: 20)!] as! [String : Any]
        navigationBar.titleTextAttributes = textAttributes
        navigationBar.clipsToBounds = false 
        navigationBar.setBackgroundImage(#imageLiteral(resourceName: "UpperNavBar"), for: .default)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
