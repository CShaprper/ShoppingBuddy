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
     @IBOutlet var MapView: MKMapView!
    
    
    //MARK: - Member
    var locationService:LocationService!
    var firebaseWebService:FirebaseWebService!
    private var isMenuOpened:Bool = false
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
        
        //Load all Stores
        firebaseWebService.ReadFirebaseShoppingListsSection()
        
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
    
    //MARK: - Helper Functions
    func ConfigureView() -> Void {
        // Firebase Webservice
        firebaseWebService = FirebaseWebService()
        firebaseWebService.firebaseWebServiceDelegate  = self
        firebaseWebService.alertMessageDelegate = self
        
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
        
        //Notification Listener
        NotificationCenter.default.addObserver(self, selector: #selector(SegueToLoginController), name: NSNotification.Name.SegueToLogInController, object: nil)
    }
}
