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
import UserNotifications
import FirebaseAuth

class DashboardController: UIViewController, IFirebaseUserWebservice, IAlertMessageDelegate{
    //MARK: - Outlets
    @IBOutlet var BackgroundView: UIImageView!
    @IBOutlet var MapView: MKMapView!
    @IBOutlet var lbl_DebugMonitoredRegions: UILabel!
    @IBOutlet var lbl_DebugHasUserMovedDistance: UILabel!
    @IBOutlet var UserProfileImage: UIImageView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    
    
    //MARK: - Member
    var debugcounter:Int = 0 //can be removed in release
    internal var locationManager:CLLocationManager!
    internal var radiusToMonitore:CLLocationDistance!
    internal var mapSpan:Double!
    internal var userLocation:CLLocationCoordinate2D?
    private var firebaseUser:FirebaseUser!
    var firebaseShoppingList:ShoppingList!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // locationService.RequestGPSAuthorization()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        ActivityIndicator.activityIndicatorViewStyle = .whiteLarge
        ActivityIndicator.center = view.center
        ActivityIndicator.color = UIColor.green
        ActivityIndicator.startAnimating()
        view.addSubview(ActivityIndicator)
    }
    func HideActivityIndicator() {
        if view.subviews.contains(ActivityIndicator) {
            ActivityIndicator.removeFromSuperview()
        }
    }
    
    
    //MARK: - IFirebaseUserWebservice Implementation
    func FirebaseUserLoggedOut() {
        ShoppingListsArray = []
        CurrentUserProfileImage = nil
    }
    func FirebaseUserLoggedIn() {}
    func UserProfileImageDownloadFinished() {
        UserProfileImage.alpha = 1
        UserProfileImage.image = CurrentUserProfileImage
        for list in ShoppingListsArray {
            list.OwnerProfileImage = list.ID! == Auth.auth().currentUser!.uid ? CurrentUserProfileImage : #imageLiteral(resourceName: "ShoppingBuddy-Logo")
        }
    }
    
    
    
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
        firebaseUser.LogFirebaseUserOut()
    }
    func SegueToLoginController(sender: Notification) -> Void{
        performSegue(withIdentifier: String.SegueToLoginController_Identifier, sender: nil)
    }
    
    
    
    //MARK: - Helper Functions
    func ConfigureView() -> Void {
        //Firebase User
        firebaseUser = FirebaseUser()
        firebaseUser.alertMessageDelegate = self
        firebaseUser.firebaseUserWebServiceDelegate = self
        firebaseUser.activityAnimationServiceDelegate = self
        firebaseUser.DownloadUserProfileImage()
        
        //UserProfileImage
        UserProfileImage.layer.cornerRadius = UserProfileImage.frame.width * 0.5
        UserProfileImage.clipsToBounds = true
        UserProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        UserProfileImage.layer.borderWidth = 3
        UserProfileImage.alpha = 0
        UserProfileImage.image = CurrentUserProfileImage
        
        //SetNavigationBar Title
        navigationItem.title = String.DashboardControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.DashboardControllerTitle
        
        //Load all Stores
        firebaseShoppingList = ShoppingList()
        firebaseShoppingList.alertMessageDelegate = self
        firebaseShoppingList.shoppingBuddyListWebServiceDelegate = self
        firebaseShoppingList.ObserveShoppingList()
        
        
        MapView.delegate = self
        MapView.userTrackingMode = .follow
        MapView.showsUserLocation = true
        let rad = UserDefaults.standard.double(forKey: eUserDefaultKey.MonitoredRadius.rawValue)
        radiusToMonitore = CLLocationDistance(exactly: rad)
        mapSpan = UserDefaults.standard.double(forKey: eUserDefaultKey.MapSpan.rawValue)
        
        // MapView.mask = UIImageView(image: #imageLiteral(resourceName: "AddList-US-Logo"))
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = CLLocationDistance(exactly: mapSpan * 0.25)!
        self.RequestGPSAuthorization()
        
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
    func ShowNotification(title:String, message:String) -> Void{
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            content.badge = 1
            content.sound = .default()
            let request = UNNotificationRequest(identifier: "notification", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                //toDo:??
            })
        } else {
            // Fallback on earlier versions
        }
    }
}
extension DashboardController: UNUserNotificationCenterDelegate{
    //Called in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NSLog("NotificationReceived in Foreground")
        
    }
    //Lets you know action decision from Notification
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
}
extension DashboardController: MKMapViewDelegate,IShoppingBuddyListWebService{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        lbl_DebugMonitoredRegions.text = "Current monitored regions: \(locationManager.monitoredRegions.count)"
        self.userLocation = userLocation.coordinate
        mapView.centerCoordinate = userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, CLLocationDistance(exactly: mapSpan)!, CLLocationDistance(exactly: mapSpan)!)
        mapView.setRegion(region, animated: false)
        
        if UserDefaults.standard.bool(forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue) || UserDefaults.standard.bool(forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue){
            
            //Update initial User Position
            UpdateLastUserLocationFromUserDefaults(coordinate: userLocation.coordinate)
            
            // Stop monitoring old regions
            self.StopMonitoringForOldRegions()
            
            //Remove old Geofence Overlays
            self.RemoveOldGeofenceOverlays()
            
            //Search nearby Shops
            PerformLocalShopSearch()
        }
        else if HasUserMovedDistanceGreaterMapSpan(userLocation: userLocation){
            // Stop monitoring old regions
            self.StopMonitoringForOldRegions()
            
            //Remove old Geofence Overlays
            self.RemoveOldGeofenceOverlays()
            
            //Search nearby Shops
            PerformLocalShopSearch()
        }
    }
    //MARK: - IShoppingBuddyListWebService implementation
    func ShoppingBuddyListDataReceived() {
        //firebaseShoppingList.loadImageUsingCacheWithURLString(urlString: <#T##String#>)
    }
    func ShoppingBuddyStoresCollectionReceived() {
        for store in StoresArray {
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = store
            request.region = MapView.region
            let search = MKLocalSearch(request: request)
            search.start { (response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                if response!.mapItems.count == 0 {
                    NSLog("No local search matches found for \(store)")
                    return
                }
                NSLog("Matches found for \(store)")
                
                self.StartMonitoringGeofenceRegions(mapItems: response!.mapItems)
            }
        }
    }
    //MARK: MKMapViewDelegate Helper
    private func PerformLocalShopSearch() -> Void{
        let rad = UserDefaults.standard.double(forKey: eUserDefaultKey.MonitoredRadius.rawValue)
        radiusToMonitore = CLLocationDistance(exactly: rad)
        if radiusToMonitore == 0 { return }
        
        firebaseShoppingList.GetStoresForGeofencing()
    }
    internal func StartMonitoringGeofenceRegions(mapItems: [MKMapItem]){
        if self.userLocation == nil { return }
        var itemsCount = 0
        for mapItem:MKMapItem in mapItems{
            self.SetAnnotations(mapItem: mapItem)
            var possibleRegionsPerStore = Int(round(Double(StoresArray.count / 20)))
            possibleRegionsPerStore = possibleRegionsPerStore < 4 ? 4: possibleRegionsPerStore
            if itemsCount == possibleRegionsPerStore { return }
            let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: userLocation!, location2: mapItem.placemark.coordinate)
            //Monitore nearest stores first
            if locationManager.monitoredRegions.count < 20 && distanceToUser < mapSpan * 0.1 {
                MonitoreCircularRegion(mapItem: mapItem)
                itemsCount += 1
            }
        }
        if itemsCount == 4 { return }
        for mapItem:MKMapItem in mapItems{
            self.SetAnnotations(mapItem: mapItem)
            if itemsCount == 4 { return }
            let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: userLocation!, location2: mapItem.placemark.coordinate)
            //Monitore 2nd nearest stores if regions count still below 20
            if locationManager.monitoredRegions.count < 20 && distanceToUser >= mapSpan * 0.1 && distanceToUser < mapSpan * 0.2 {
                MonitoreCircularRegion(mapItem: mapItem)
                itemsCount += 1
            }
        }
        if itemsCount == 4 { return }
        for mapItem:MKMapItem in mapItems{
            self.SetAnnotations(mapItem: mapItem)
            if itemsCount == 4 { return }
            let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: userLocation!, location2: mapItem.placemark.coordinate)
            //Monitore 3nd nearest stores if regions count still below 20
            if locationManager.monitoredRegions.count < 20 && distanceToUser >= mapSpan * 0.2 && distanceToUser < mapSpan * 0.3 {
                MonitoreCircularRegion(mapItem: mapItem)
                itemsCount += 1
            }
        }
        if itemsCount == 4 { return }
        for mapItem:MKMapItem in mapItems{
            self.SetAnnotations(mapItem: mapItem)
            if itemsCount == 4 { return }
            let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: userLocation!, location2: mapItem.placemark.coordinate)
            //Monitore 4nd nearest stores if regions count still below 20
            if locationManager.monitoredRegions.count < 20 && distanceToUser >= mapSpan * 0.3 && distanceToUser < mapSpan * 0.4 {
                MonitoreCircularRegion(mapItem: mapItem)
                itemsCount += 1
            }
        }
        if itemsCount == 4 { return }
        for mapItem:MKMapItem in mapItems{
            self.SetAnnotations(mapItem: mapItem)
            if itemsCount == 4 { return }
            let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: userLocation!, location2: mapItem.placemark.coordinate)
            //Monitore 5th nearest stores if regions count still below 20
            if locationManager.monitoredRegions.count < 20 && distanceToUser >= mapSpan * 0.4 && distanceToUser <= mapSpan * 0.6 {
                MonitoreCircularRegion(mapItem: mapItem)
                itemsCount += 1
            }
        }
        if itemsCount == 4 { return }
        for mapItem:MKMapItem in mapItems{
            self.SetAnnotations(mapItem: mapItem)
            if itemsCount == 4 { return }
            let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: userLocation!, location2: mapItem.placemark.coordinate)
            //Monitore 6th nearest stores if regions count still below 20
            if locationManager.monitoredRegions.count < 20 && distanceToUser >= mapSpan * 0.6 && distanceToUser <= mapSpan * 3 {
                MonitoreCircularRegion(mapItem: mapItem)
                itemsCount += 1
            }
        }
    }
    private func MonitoreCircularRegion(mapItem: MKMapItem){
        DispatchQueue.main.async {
            let region = CLCircularRegion(center: mapItem.placemark.coordinate, radius: CLLocationDistance(self.radiusToMonitore), identifier: "\(UUID().uuidString)\("SB_")\(mapItem.name!)")
            self.locationManager.startMonitoring(for: region)
            
            NSLog("Monitored Regions: \(self.locationManager.monitoredRegions.count)")
            NSLog("MapSpan: \(self.mapSpan)")
            NSLog("Start monitoring for Region: \(region) with Radius \(region.radius)" )
        }
    }
    private func SetAnnotations(mapItem: MKMapItem){
        DispatchQueue.main.async {
            if !self.MapView.annotations.contains(where: {$0.subtitle! == mapItem.placemark.title}){
                NSLog("Adding Annotation at location: \(String(describing: mapItem.placemark.coordinate))")
                NSLog("Adding Annotation Title: \(String(describing: mapItem.name))")
                NSLog("Adding Annotation Subtitle: \(String(describing: mapItem.placemark.title))")
                let annotation = CustomMapAnnotation()
                annotation.image = #imageLiteral(resourceName: "map-Marker-green")
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                annotation.subtitle = mapItem.placemark.title
                self.MapView.addAnnotation(annotation)
            }
        }
    }
    private func CalculateDistanceBetweenTwoCoordinates(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> CLLocationDistance {
        let coord1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let coord2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return coord1.distance(from: coord2)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else {
            return MKOverlayRenderer()
        }
        NSLog("Drawing Circular Overlay")
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.alpha = 1
        circleRenderer.lineWidth = 1
        circleRenderer.setNeedsDisplay()
        return circleRenderer
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {  return nil }
        
        // try to dequeue an existing pin view first
        let AnnotationIdentifier = "AnnotationIdentifier"
        let myAnnotation = (annotation as! CustomMapAnnotation)
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: AnnotationIdentifier)
        pinView.canShowCallout = true
        //pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        pinView.image =  myAnnotation.image
        return pinView
    }
    //HasUserMovedDistanceGreaterMapSpan
    private func HasUserMovedDistanceGreaterMapSpan(userLocation:MKUserLocation) -> Bool{
        if  let lastUserLocation = ReadLastUserLocationFromUserDefaults(){
            let distance = userLocation.location?.distance(from: lastUserLocation)
            if distance != nil && distance! > mapSpan * 0.25{
                lbl_DebugHasUserMovedDistance.text = "User moved > mapSpan: \(debugcounter += 1)"
                UpdateLastUserLocationFromUserDefaults(coordinate: userLocation.coordinate)
                return true
            }
        }
        return false
    }
    private func ReadLastUserLocationFromUserDefaults() -> CLLocation?{
        let latitude = UserDefaults.standard.double(forKey: eUserDefaultKey.LastUserLatitude.rawValue)
        let longitude = UserDefaults.standard.double(forKey: eUserDefaultKey.LastUserLongitude.rawValue)
        if latitude > 0 && longitude > 0{
            return CLLocation(latitude: CLLocationDegrees(floatLiteral: latitude), longitude: CLLocationDegrees(floatLiteral: longitude))
        }
        else { return nil }
    }
    private func UpdateLastUserLocationFromUserDefaults(coordinate: CLLocationCoordinate2D) -> Void{
        //Set hasUserChangedGeofenceRadius false
        UserDefaults.standard.set(false, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        //Set isInitialLocationUpdate false
        UserDefaults.standard.set(false, forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue)
        //SaveNew position
        UserDefaults.standard.set(coordinate.latitude, forKey: eUserDefaultKey.LastUserLatitude.rawValue)
        UserDefaults.standard.set(coordinate.longitude, forKey: eUserDefaultKey.LastUserLongitude.rawValue)
    }
    private func RemoveOldGeofenceOverlays() -> Void{
        for overlay in self.MapView.overlays{
            if overlay is MKUserLocation{ }
            else { MapView.remove(overlay)}
        }
    }
    func StopMonitoringForOldRegions(){
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
            NSLog("removing Region: " + region.identifier)
            NSLog("Monitored regions \(self.locationManager.monitoredRegions.count)")
        }
    }
}
extension DashboardController: CLLocationManagerDelegate{
    func RequestGPSAuthorization() -> Void{
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        if CLLocationManager.authorizationStatus() == .authorizedAlways{
            locationManager.startUpdatingLocation()
        }
        if CLLocationManager.authorizationStatus() == .denied{
            let title = String.GPSAuthorizationRequestDenied_AlertTitle
            let message = String.GPSAuthorizationRequestDenied_AlertMessage
            self.ShowAlertMessage(title: title, message: message)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            lbl_DebugMonitoredRegions.text = "Current monitored regions: \(locationManager.monitoredRegions.count)"
            userLocation = location.coordinate
            MapView.centerCoordinate = location.coordinate
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let str:[String] = region.identifier.components(separatedBy: "SB_")
        if str.count <= 0 { return }
        
        var regionStr:String = ""
        regionStr = str.last!
        let title = "\(regionStr) \(String.LocationManagerEnteredRegion_AlertTitle)"
        let message = String.LocationManagerEnteredRegion_AlertMessage
        ShowAlertMessage(title: title, message: message)
        ShowNotification(title: title, message: message)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        NSLog("locationManager failed Monitoring for region \(region!.identifier) with error \(error.localizedDescription)")
        locationManager.stopMonitoring(for: region!)
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        lbl_DebugMonitoredRegions.text = "Current monitored regions: \(locationManager.monitoredRegions.count)"
        // Add region overlay circel
        if let circularRegion = region as? CLCircularRegion{
            NSLog("Started monitoring for Region: \(region.identifier) with radius: \(circularRegion.radius)")
            NSLog("Monitored Regions: \(locationManager.monitoredRegions.count)")
            let circle = MKCircle(center: circularRegion.center, radius: circularRegion.radius)
            self.MapView.add(circle)
            NSLog("Adding circular Overlay")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("locationManager failed with error")
        NSLog(error.localizedDescription)
    }
}
