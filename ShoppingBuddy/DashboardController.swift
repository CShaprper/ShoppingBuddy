//
//  DashboardController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DashboardController: UIViewController, IFirebaseWebService{
    //MARK: - Outlets
    @IBOutlet var BackgroundView: UIImageView!
    @IBOutlet var MenuContainer: UIView!
    @IBOutlet var RoundMenu: UIImageView!
    @IBOutlet var ButtonStack: UIStackView!
    @IBOutlet var btn_Stores: UIButton!
    @IBOutlet var btn_ShoppingList: UIButton!
    @IBOutlet var MapView: MKMapView!
    
    
    //MARK: - Member
    var locationService:LocationService!
    var firebaseWebService:FirebaseWebService!
    private var isMenuOpened:Bool = false
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
        
        //Setup LocationService Class
        locationService = LocationService(mapView: MapView, alertDelegate: self)
        // MapView.mask = UIImageView(image: #imageLiteral(resourceName: "AddList-US-Logo"))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationService.RequestGPSAuthorization()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - IFirebaseWebservice Implementation
    func FirebaseUserLoggedOut() {}
    func FirebaseRequestStarted() {}
    func FirebaseRequestFinished() {}
    func FirebaseUserLoggedIn() {}
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if title != String.GPSAuthorizationRequestDenied_AlertTitle{
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        } else {
            alert.addAction(UIAlertAction(title: String.GPSAuthorizationRequestDenied_AlertActionSettingsTitle, style: .default, handler: { (action) in
                let url:URL! = URL(string : "App-Prefs:root=LOCATION_SERVICES")
                UIApplication.shared.openURL(url)
            }))
            alert.addAction(UIAlertAction(title: String.GPSAuthorizationRequestDenied_AlertActionSettingsNoTitle, style: .cancel, handler: nil))
        }
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Wired Actions
    func LogOutBarButtonItemPressed(sender: UIBarButtonItem)->Void{
        firebaseWebService.firebaseWebServiceDelegate  = nil
        firebaseWebService.LogUserOut()
    }
    func SegueToLoginController(sender: Notification) -> Void{
        performSegue(withIdentifier: String.SegueToLoginController_Identifier, sender: nil)
    }
    func MenuBarButtonItemPressed(sender: UIBarButtonItem) -> Void{
        if isMenuOpened{
            isMenuOpened = false
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.RoundMenu.transform = CGAffineTransform(translationX: self.RoundMenu.frame.size.width, y: 0)
            })
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.btn_Stores.transform = CGAffineTransform(translationX: self.MenuContainer.frame.width, y: 0)
                self.btn_ShoppingList.transform = CGAffineTransform(translationX: self.MenuContainer.frame.width, y: 0)
            })
        } else {
            isMenuOpened = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.RoundMenu.transform = .identity
            })
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.btn_Stores.transform = .identity
                self.btn_ShoppingList.transform = .identity
            })
        }
    }
    
    
    //MARK: - Helper Functions
    func ConfigureView() -> Void {
        // Firebase Webservice
        firebaseWebService = FirebaseWebService()
        firebaseWebService.firebaseWebServiceDelegate  = self
        firebaseWebService.alertMessageDelegate = self
        
        //Load all Stores
        firebaseWebService.ReadFirebaseShoppingListsSection()
        
        //SetNavigationBar Title
        navigationItem.title = String.DashboardControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.DashboardControllerTitle
        
        //LogOut Button
        let logoutButton = UIBarButtonItem(title: "log out", style: UIBarButtonItemStyle.plain, target: self, action:#selector(LogOutBarButtonItemPressed))
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset =  CGSize(width: -2, height: -2)
        logoutButton.setTitleTextAttributes([NSShadowAttributeName:shadow, NSStrokeWidthAttributeName:-1, NSStrokeColorAttributeName:UIColor.black, NSForegroundColorAttributeName:UIColor.ColorPaletteTintColor(), NSFontAttributeName:UIFont(name: "Courgette-Regular", size: 17)!], for: .normal)
        self.navigationItem.leftBarButtonItem = logoutButton
        
        //MenuButton
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-HamburgerMenu") , style: .plain, target: self, action: #selector(MenuBarButtonItemPressed))
        navigationItem.rightBarButtonItem = menuButton
        
        //Notification Listener
        NotificationCenter.default.addObserver(self, selector: #selector(SegueToLoginController), name: NSNotification.Name.SegueToLogInController, object: nil)
        
        //RoundMenu initial position
        RoundMenu.transform = CGAffineTransform(translationX: RoundMenu.frame.size.width, y: 0)
        
        //Button Stores
        btn_Stores.tintColor = UIColor.ColorPaletteSecondDarkest()
        btn_Stores.transform = CGAffineTransform(translationX: MenuContainer.frame.width, y: 0)
        
        //Button ShoppingList
        btn_ShoppingList.tintColor = UIColor.ColorPaletteSecondDarkest()
        btn_ShoppingList.transform = CGAffineTransform(translationX: MenuContainer.frame.width, y: 0)
    }
}
