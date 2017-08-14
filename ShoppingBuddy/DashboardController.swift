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

class DashboardController: UIViewController, IFirebaseWebService{
    //MARK: - Outlets
    @IBOutlet var BackgroundView: UIImageView!
    @IBOutlet var MapView: MKMapView!
    @IBOutlet var lbl_DebugMonitoredRegions: UILabel!
    @IBOutlet var lbl_DebugHasUserMovedDistance: UILabel!
    
    
    //MARK: - Member
    //private var locationService:LocationService!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    internal var locationManager:CLLocationManager!
    internal var radiusToMonitore:CLLocationDistance!
    internal var mapSpan:Double!
    var userLocation:CLLocationCoordinate2D?
    private var isMenuOpened:Bool = false
    var firebaseWebService:FirebaseWebService!
    var shoppingList:ShoppingList!
    var listIDs:[ListID]?
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
        
        //Load all Stores
        shoppingList = ShoppingList()
        shoppingList.alertMessageDelegate = self
        shoppingList.firebaseWebServiceDelegate = self
        listIDs = ListID.FetchListID(userID:Auth.auth().currentUser!.uid, context: context)
        if listIDs != nil {
            for id in listIDs!{
                shoppingList.ObserveShoppingList(listID: id.listID!)
            }
        }
        
        // MapView.mask = UIImageView(image: #imageLiteral(resourceName: "AddList-US-Logo"))
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.RequestGPSAuthorization()  
        
        MapView.delegate = self
        MapView.userTrackingMode = .follow
        MapView.showsUserLocation = true
        let rad = UserDefaults.standard.double(forKey: eUserDefaultKey.MonitoredRadius.rawValue)
        radiusToMonitore = CLLocationDistance(exactly: rad)
        mapSpan = UserDefaults.standard.double(forKey: eUserDefaultKey.MapSpan.rawValue)
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
extension DashboardController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        lbl_DebugMonitoredRegions.text = "Current monitored regions: \(locationManager.monitoredRegions.count)" 
        self.userLocation = userLocation.coordinate
        mapView.centerCoordinate = userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, CLLocationDistance(exactly: mapSpan)!, CLLocationDistance(exactly: mapSpan)!)
        mapView.setRegion(region, animated: false)
        
        if UserDefaults.standard.bool(forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue) || UserDefaults.standard.bool(forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue){
            
            //Update initial User Position
            UpdateLastUserLocationFromUserDefaults(coordinate: userLocation.coordinate)
            
            //Set isInitialLocationUpdate false
            UserDefaults.standard.set(false, forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue)
            
            //Set hasUserChangedGeofenceRadius false
            UserDefaults.standard.set(false, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            
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
    //MARK: MKMapViewDelegate Helper
    private func PerformLocalShopSearch() -> Void{
        let rad = UserDefaults.standard.double(forKey: eUserDefaultKey.MonitoredRadius.rawValue)
        radiusToMonitore = CLLocationDistance(exactly: rad)
        if radiusToMonitore == 0 { return }
        
        //Get UserDefaults Array
        listIDs = ListID.FetchListID(userID:Auth.auth().currentUser!.uid, context: context)
        if listIDs == nil { return }
        for id in listIDs!{           
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = id.relatedStore!
            request.region = MapView.region
            let search = MKLocalSearch(request: request)
            
            search.start { (response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                if response!.mapItems.count == 0 {
                    NSLog("No local search matches found")
                    return
                }
                NSLog("Matches found for \(id.relatedStore!)")
                
                var itemsCount = 0
                for mapItem in response!.mapItems{
                    itemsCount += 1
                    //Set map Annotations
                    self.SetAnnotations(mapItem: mapItem)
                    //Start monitoring Geofence regions
                    if itemsCount > 5 { return }
                    self.StartMonitoringGeofenceRegions(mapItem: mapItem)
                }
            }
        }
    }
    private func StartMonitoringGeofenceRegions(mapItem: MKMapItem) -> Void{
        if self.userLocation == nil { return }
        
        let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: userLocation!, location2: mapItem.placemark.coordinate)
        if distanceToUser > mapSpan * 0.6 { return }
        
        //Monitore nearest stores first
        if locationManager.monitoredRegions.count < 20 && distanceToUser < mapSpan * 0.1 {
            MonitoreCircularRegion(mapItem: mapItem)
        }
        //Monitore 2nd nearest stores if regions count still below 20
        if locationManager.monitoredRegions.count < 20 && distanceToUser >= mapSpan * 0.1 && distanceToUser < mapSpan * 0.2 {
            MonitoreCircularRegion(mapItem: mapItem)
        }
        //Monitore 3nd nearest stores if regions count still below 20
        if locationManager.monitoredRegions.count < 20 && distanceToUser >= mapSpan * 0.2 && distanceToUser < mapSpan * 0.3 {
            MonitoreCircularRegion(mapItem: mapItem)
        }
        //Monitore 4nd nearest stores if regions count still below 20
        if locationManager.monitoredRegions.count < 20 && distanceToUser >= mapSpan * 0.3 && distanceToUser < mapSpan * 0.4 {
            MonitoreCircularRegion(mapItem: mapItem)
        }
        //Monitore 4nd nearest stores if regions count still below 20
        if locationManager.monitoredRegions.count < 20 && distanceToUser >= mapSpan * 0.4 && distanceToUser <= mapSpan * 0.6 {
            MonitoreCircularRegion(mapItem: mapItem)
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
    private func HasUserMovedDistanceGreaterMapSpan(userLocation:MKUserLocation) -> Bool{
        if  let lastUserLocation = ReadLastUserLocationFromUserDefaults(){
            let distance = userLocation.location?.distance(from: lastUserLocation)
            if distance != nil && distance! > mapSpan * 0.25{
                lbl_DebugHasUserMovedDistance.text = "User moved > mapSpan: true"
                UpdateLastUserLocationFromUserDefaults(coordinate: userLocation.coordinate)
                return true
            }
            lbl_DebugHasUserMovedDistance.text = "User moved > mapSpan: false"
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
            locationManager.startMonitoringSignificantLocationChanges()
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
