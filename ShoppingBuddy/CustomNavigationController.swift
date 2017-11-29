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
        navigationBar.tintColor = UIColor.ColorPaletteBrightest()
        navigationBar.barTintColor = UIColor.ColorPaletteBrightest()
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 35
        shadow.shadowOffset =  CGSize(width: -2, height: -2)
        
        navigationBar.clipsToBounds = false
        navigationBar.contentMode = .scaleToFill
        navigationBar.setBackgroundImage(#imageLiteral(resourceName: "NavBarTop"), for: .default)
        navigationBar.setBackgroundImage(#imageLiteral(resourceName: "NavBarTop").resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
