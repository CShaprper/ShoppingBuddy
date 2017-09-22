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
import MobileCoreServices

var possibleRegionsPerStore:Int = 4

class DashboardController: UIViewController, IAlertMessageDelegate, IActivityAnimationService, UIGestureRecognizerDelegate{
    //MARK: - Outlets
    @IBOutlet var BackgroundView: UIImageView!
    @IBOutlet var MapView: MKMapView!
    @IBOutlet var UserProfileImage: UIImageView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    //NotificationView
    @IBOutlet var InvitationNotification: UIView!
    @IBOutlet var lbl_InviteTitle: UILabel!
    @IBOutlet var lbl_InviteMessage: UILabel!
    @IBOutlet var InviteUserImage: UIImageView!     
    
    
    //MARK: - Member
    var debugcounter:Int = 0 //can be removed in release
    internal var locationManager:CLLocationManager!
    internal var radiusToMonitore:CLLocationDistance!
    internal var mapSpan:Double!
    internal var userLocation:CLLocationCoordinate2D?
    private var sbUserWebservice:ShoppingBuddyUserWebservice!
    private var sbMessagesWebService:ShoppingBuddyMessageWebservice!
    var sbListWebservice:ShoppingBuddyListWebservice!
    var timer:Timer!
    
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
        
        if UserDefaults.standard.bool(forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue) {
            
            UserDefaults.standard.set(false, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer != nil { timer.invalidate() }
    }
    
    
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() -> Void {
        
        ActivityIndicator.activityIndicatorViewStyle = .whiteLarge
        ActivityIndicator.center = view.center
        ActivityIndicator.color = UIColor.green
        ActivityIndicator.startAnimating()
        view.addSubview(ActivityIndicator)
        
    }
    func HideActivityIndicator()  -> Void {
        
        if view.subviews.contains(ActivityIndicator) {
            ActivityIndicator.removeFromSuperview()
        }
        
    }
    
    @objc func UserProfileImageTapped(_ sender: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false { return }
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .photoLibrary
        imgPicker.allowsEditing = true
        imgPicker.delegate = self
        self.present(imgPicker, animated: true, completion: nil)

    }
    
    
    @objc func ShoppingBuddyUserLoggedOut()  -> Void {
        
        allShoppingLists = []
        allUsers = []
        allMessages = []
        currentUser = nil
        
    }
    @objc func ShoppingBuddyUserLoggedIn()  -> Void {
        
        sbUserWebservice.GetCurrentUser()
        
    }
    @objc func CurrentUserCreated(notification: Notification) -> Void {
        
        sbUserWebservice.GetCurrentUser()
        
    }
    
    @objc func UserProfileImageDownloadFinished()  -> Void {
        
        if let index = allUsers.index(where: { $0.profileImageURL == currentUser!.profileImageURL }) {
            
            UserProfileImage.image = allUsers[index].profileImage
            UserProfileImage.alpha = 1
            
            UserProfileImage.image = currentUser!.profileImage
            
        }
        HideActivityIndicator()
    }
    
    
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String)  -> Void {
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
    
    
    //MARK: - Notificarion listeners
    @objc func CurrentUserReceived(notification: Notification) -> Void {
        
        sbMessagesWebService.ObserveAllMessages() 
        sbListWebservice.GetStoresForGeofencing()
        
    }
    
    
    
    //MARK: - Wired Actions
    @objc func LogOutBarButtonItemPressed(sender: UIBarButtonItem) -> Void {
        
        sbUserWebservice.LogFirebaseUserOut()
        
    }
    @objc func SegueToLoginController(sender: Notification) -> Void {
        
        performSegue(withIdentifier: String.SegueToLoginController_Identifier, sender: nil)
        
    }
    
    @objc func HideNotification() -> Void {
        
        UIView.animate(withDuration: 1, animations: {
            
            self.InvitationNotification.center.y = -self.InvitationNotification.frame.size.height * 2 - self.topLayoutGuide.length
            
        }) { (true) in
            
            if self.view.subviews.contains(self.InvitationNotification) {
                
                self.InvitationNotification.removeFromSuperview()
                
            }
            
        }
        
    }
    
    @objc func PushNotificationReceived(notification: Notification) -> Void {
        
         guard let info = notification.userInfo else { return }
        
        guard let notificationTitle = info["notificationTitle"] as? String,
        let notificationMessage = info["notificationMessage"] as? String,
            let senderID = info["senderID"] as? String else { return }
        
         lbl_InviteTitle.text = notificationTitle
         lbl_InviteMessage.text = notificationMessage
         
         if let index = allUsers.index(where: { $0.id == senderID } ) {
            
         InviteUserImage.image = allUsers[index].profileImage!
         displayNotification()
         
         } else {         
            
            displayNotification()
         
         }
        
    }
    
    private func ShowSharingInvatationNotificationAfterImageDownload(url:URL) -> Void {
        
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            DispatchQueue.main.async {
                
                if let downloadImage = UIImage(data: data!) {
                    
                    //TODO: take a look at runtime
                    self.InviteUserImage.image = downloadImage
                    self.displayNotification()
                    
                }
            }
        }
        task.resume()
    }
    private func displayNotification() -> Void {
        
        //Invite Notification View
        InvitationNotification.center.x = view.center.x
        InvitationNotification.center.y = -InvitationNotification.frame.height
        InvitationNotification.layer.cornerRadius = 30
        InviteUserImage.layer.cornerRadius = InviteUserImage.frame.width * 0.5
        InviteUserImage.clipsToBounds = true
        InviteUserImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        InviteUserImage.layer.borderWidth = 3
        InvitationNotification.layer.shadowColor  = UIColor.black.cgColor
        InvitationNotification.layer.shadowOffset  = CGSize(width: 30, height:30)
        InvitationNotification.layer.shadowOpacity  = 1
        InvitationNotification.layer.shadowRadius  = 10
        
        view.addSubview(InvitationNotification)
        InviteUserImage.layer.cornerRadius = InviteUserImage.frame.width * 0.5
        
        UIView.animate(withDuration: 1) {
            
            self.InvitationNotification.transform = CGAffineTransform(translationX: 0, y: self.InvitationNotification.frame.size.height * 2 + self.topLayoutGuide.length)
            
        }
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(HideNotification), userInfo: nil, repeats: false)
        
    }
    
    
    
    //MARK: - Helper Functions
    func ConfigureView() -> Void {        
        //UserProfileImage
        UserProfileImage.layer.cornerRadius = UserProfileImage.frame.width * 0.5
        UserProfileImage.clipsToBounds = true
        UserProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        UserProfileImage.layer.borderWidth = 3
        UserProfileImage.image = #imageLiteral(resourceName: "userPlaceholder")
        UserProfileImage.layer.shadowColor  = UIColor.black.cgColor
        UserProfileImage.layer.shadowOffset  = CGSize(width: 30, height:30)
        UserProfileImage.layer.shadowOpacity  = 1
        UserProfileImage.layer.shadowRadius  = 10
        
        let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileImageTapped))
        profileImageGestureRecognizer.delegate = self
    
        UserProfileImage.addGestureRecognizer(profileImageGestureRecognizer)
        
        //Shopping Buddy Message Webservice
        sbMessagesWebService = ShoppingBuddyMessageWebservice()
        sbMessagesWebService.activityAnimationServiceDelegate = self
        sbMessagesWebService.alertMessageDelegate = self
        
        //Firebase User
        sbUserWebservice = ShoppingBuddyUserWebservice()
        sbUserWebservice.alertMessageDelegate = self
        sbUserWebservice.activityAnimationServiceDelegate = self
        sbUserWebservice.GetCurrentUser()
        
        //SetNavigationBar Title
        navigationItem.title = String.DashboardControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.DashboardControllerTitle
        
        //Load all Stores
        sbListWebservice = ShoppingBuddyListWebservice()
        sbListWebservice.activityAnimationServiceDelegate = self
        sbListWebservice.alertMessageDelegate = self
        
        
        //Notification Listener
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileImageDownloadFinished), name: NSNotification.Name.UserProfileImageDownloadFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentUserReceived), name: NSNotification.Name.CurrentUserReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SegueToLoginController), name: NSNotification.Name.SegueToLogInController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PerformLocalShopSearch), name: NSNotification.Name.PerformLocalShopSearch, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PushNotificationReceived), name: NSNotification.Name.PushNotificationReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingBuddyUserLoggedOut), name: NSNotification.Name.ShoppingBuddyUserLoggedOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingBuddyUserLoggedIn), name: NSNotification.Name.ShoppingBuddyUserLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingBuddyStoreReceived), name: NSNotification.Name.ShoppingBuddyStoreReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentUserCreated), name: NSNotification.Name.CurrentUserCreated, object: nil)
        
        
        
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
        logoutButton.setTitleTextAttributes([NSAttributedStringKey.shadow:shadow, NSAttributedStringKey.strokeWidth:-1, NSAttributedStringKey.strokeColor:UIColor.black, NSAttributedStringKey.foregroundColor:UIColor.ColorPaletteTintColor(), NSAttributedStringKey.font:UIFont(name: "Courgette-Regular", size: 17)!], for: .normal)
        self.navigationItem.leftBarButtonItem = logoutButton
    }
    func ShowNotification(title:String, message:String) -> Void {
        
        if #available(iOS 10.0, *) {
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            content.badge = 1
            content.sound = .default()
            let request = UNNotificationRequest(identifier: "notification", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                
                if error != nil{
                    
                    NSLog(error!.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error!.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
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
extension DashboardController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.userLocation = userLocation.coordinate
        mapView.centerCoordinate = userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, CLLocationDistance(exactly: mapSpan)!, CLLocationDistance(exactly: mapSpan)!)
        mapView.setRegion(region, animated: false)
        
        if UserDefaults.standard.bool(forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue){
            //Update initial User Position
            UpdateLastUserLocationFromUserDefaults(coordinate: userLocation.coordinate)
            
            //Search nearby Shops
            PerformLocalShopSearch()
        }
        else if  UserDefaults.standard.bool(forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue){
            //Search nearby Shops
            PerformLocalShopSearch()
            UserDefaults.standard.set(false, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        }
        else if HasUserMovedDistanceGreaterMapSpan(userLocation: userLocation){
            //Search nearby Shops
            PerformLocalShopSearch()
        }
    }
    
    //MARK: - IShoppingBuddyListWebService implementation
    @objc func ShoppingBuddyStoreReceived(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let store = userInfo["store"] as? String else { return }
        
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = store
        request.region = self.MapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            NSLog("Matches found for \(store)")
            DispatchQueue.main.async {
                self.StartMonitoringGeofenceRegions(mapItems: response!.mapItems)
            }
        }
    }
    //MARK: MKMapViewDelegate Helper
    @objc func PerformLocalShopSearch() -> Void{
        // Stop monitoring old regions
        self.StopMonitoringForOldRegions()
        
        //Remove previous Annotations
        self.RemoveOldAnnotations()
        
        //Remove old Geofence Overlays
        self.RemoveOldGeofenceOverlays()
        
        let rad = UserDefaults.standard.double(forKey: eUserDefaultKey.MonitoredRadius.rawValue)
        radiusToMonitore = CLLocationDistance(exactly: rad)
        if radiusToMonitore == 0 { return }
        
        sbListWebservice.GetStoresForGeofencing()
    }
    
    internal func StartMonitoringGeofenceRegions(mapItems: [MKMapItem]) -> Void {
        
        if self.userLocation == nil { return }
        if possibleRegionsPerStore == 0 { return }
        
        possibleRegionsPerStore = Int(round(Double(20 / possibleRegionsPerStore)))
        possibleRegionsPerStore = possibleRegionsPerStore < 4 ? 4: possibleRegionsPerStore
        
        var itemsCount = 0
        itemsCount = TryMonitoreRegion(mapItems: mapItems, possibleRegionsPerStore: possibleRegionsPerStore, itemsCount: itemsCount, minDistance: 0, maxDistance: mapSpan * 0.1)
        
        if itemsCount == possibleRegionsPerStore { return }
        itemsCount = TryMonitoreRegion(mapItems: mapItems, possibleRegionsPerStore: possibleRegionsPerStore, itemsCount: itemsCount, minDistance: mapSpan * 0.1, maxDistance: mapSpan * 0.2)
        
        if itemsCount == possibleRegionsPerStore { return }
        itemsCount = TryMonitoreRegion(mapItems: mapItems, possibleRegionsPerStore: possibleRegionsPerStore, itemsCount: itemsCount, minDistance: mapSpan * 0.2, maxDistance: mapSpan * 0.3)
        
        if itemsCount == possibleRegionsPerStore { return }
        itemsCount = TryMonitoreRegion(mapItems: mapItems, possibleRegionsPerStore: possibleRegionsPerStore, itemsCount: itemsCount, minDistance: mapSpan * 0.3, maxDistance: mapSpan * 0.4)
        
        if itemsCount == possibleRegionsPerStore { return }
        itemsCount = TryMonitoreRegion(mapItems: mapItems, possibleRegionsPerStore: possibleRegionsPerStore, itemsCount: itemsCount, minDistance: mapSpan * 0.4, maxDistance: mapSpan * 0.6)
        
        if itemsCount == possibleRegionsPerStore { return }
        itemsCount = TryMonitoreRegion(mapItems: mapItems, possibleRegionsPerStore: possibleRegionsPerStore, itemsCount: itemsCount, minDistance: mapSpan * 0.6, maxDistance: mapSpan * 3)
        
    }
    private func TryMonitoreRegion(mapItems:[MKMapItem], possibleRegionsPerStore:Int, itemsCount:Int, minDistance:Double, maxDistance:Double) -> Int {
        
        var cnt:Int = itemsCount
        for mapItem:MKMapItem in mapItems {
            
            self.SetAnnotations(mapItem: mapItem)
            if cnt == possibleRegionsPerStore { return cnt }
            let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: userLocation!, location2: mapItem.placemark.coordinate)
            
            //Monitore 6th nearest stores if regions count still below 20
            if locationManager.monitoredRegions.count < 20 && distanceToUser >= minDistance && distanceToUser < maxDistance {
                
                NSLog("Monitoring region: \(mapItem.name!)  \(mapItem.placemark.title!)")
                MonitoreCircularRegion(mapItem: mapItem)
                cnt += 1
                
            }
            
        }
        return cnt
    }
    
    private func MonitoreCircularRegion(mapItem: MKMapItem) -> Void {
        
        DispatchQueue.main.async {
            
            let region = CLCircularRegion(center: mapItem.placemark.coordinate, radius: CLLocationDistance(self.radiusToMonitore), identifier: "\(UUID().uuidString)\("SB_")\(mapItem.name!)")
            self.locationManager.startMonitoring(for: region)
            
            NSLog("Monitored Regions: \(self.locationManager.monitoredRegions.count)")
            NSLog("Start monitoring for Region: \(region) with Radius \(region.radius)" )
            
        }
        
    }
    private func SetAnnotations(mapItem: MKMapItem) -> Void {
        
        DispatchQueue.main.async {
            
            if !self.MapView.annotations.contains(where: {$0.subtitle! == mapItem.placemark.title}) {
                
//                NSLog("Adding Annotation at location: \(String(describing: mapItem.placemark.coordinate))")
//                NSLog("Adding Annotation Title: \(String(describing: mapItem.name))")
//                NSLog("Adding Annotation Subtitle: \(String(describing: mapItem.placemark.title))")
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
        
//        NSLog("Drawing Circular Overlay")
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
    private func HasUserMovedDistanceGreaterMapSpan(userLocation:MKUserLocation) -> Bool {
        
        if  let lastUserLocation = ReadLastUserLocationFromUserDefaults() {
            
            let distance = userLocation.location?.distance(from: lastUserLocation)
            if distance != nil && distance! > mapSpan * 0.25  {
                
                UpdateLastUserLocationFromUserDefaults(coordinate: userLocation.coordinate)
                return true
                
            }
            
        }
        
        return false
    }
    private func ReadLastUserLocationFromUserDefaults() -> CLLocation? {
        
        let latitude = UserDefaults.standard.double(forKey: eUserDefaultKey.LastUserLatitude.rawValue)
        let longitude = UserDefaults.standard.double(forKey: eUserDefaultKey.LastUserLongitude.rawValue)
        
        if latitude > 0 && longitude > 0 {
            
            return CLLocation(latitude: CLLocationDegrees(floatLiteral: latitude), longitude: CLLocationDegrees(floatLiteral: longitude))
            
        }
            
        else { return nil }
    }
    private func UpdateLastUserLocationFromUserDefaults(coordinate: CLLocationCoordinate2D) -> Void {
        
        UserDefaults.standard.set(false, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        UserDefaults.standard.set(false, forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue)
        UserDefaults.standard.set(coordinate.latitude, forKey: eUserDefaultKey.LastUserLatitude.rawValue)
        UserDefaults.standard.set(coordinate.longitude, forKey: eUserDefaultKey.LastUserLongitude.rawValue)
        
    }
    private func RemoveOldGeofenceOverlays() -> Void {
        
        for overlay in self.MapView.overlays {
            
            if overlay is MKUserLocation{ }
            else { MapView.remove(overlay)}
            
        }
        
    }
    private func RemoveOldAnnotations() -> Void {
        
        for annotation in self.MapView.annotations {
            
            if annotation is MKUserLocation{ }
            else { MapView.removeAnnotation(annotation) }
            
        }
        
    }
    func StopMonitoringForOldRegions() -> Void {
        
        for region in locationManager.monitoredRegions {
            
            locationManager.stopMonitoring(for: region)
//            NSLog("removing Region: " + region.identifier)
//            NSLog("Monitored regions \(self.locationManager.monitoredRegions.count)")
            
        }
        
    }
}
extension DashboardController: CLLocationManagerDelegate {
    
    func RequestGPSAuthorization() -> Void {
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            
            locationManager.requestAlwaysAuthorization()
            
        }
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            locationManager.startMonitoringSignificantLocationChanges()
            
        }
        
        if CLLocationManager.authorizationStatus() == .denied {
            
            let title = String.GPSAuthorizationRequestDenied_AlertTitle
            let message = String.GPSAuthorizationRequestDenied_AlertMessage
            self.ShowAlertMessage(title: title, message: message)
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
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
        
        // Add region overlay circel
        if let circularRegion = region as? CLCircularRegion {
            
//            NSLog("Started monitoring for Region: \(region.identifier) with radius: \(circularRegion.radius)")
//            NSLog("Monitored Regions: \(locationManager.monitoredRegions.count)")
            let circle = MKCircle(center: circularRegion.center, radius: circularRegion.radius)
            self.MapView.add(circle)
//            NSLog("Adding circular Overlay")
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        NSLog("locationManager failed with error")
        NSLog(error.localizedDescription)
        
    }
}
extension DashboardController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == kUTTypeImage as String {
            var image : UIImage!
            if let img = info[UIImagePickerControllerEditedImage] as? UIImage
            {
                image = img
                
            }
            else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage
            {
                image = img
            }
            self.UserProfileImage.image = image
            self.UserProfileImage.layer.cornerRadius = self.UserProfileImage.frame.width * 0.5
            self.UserProfileImage.clipsToBounds = true
            
            let sbUserService = ShoppingBuddyUserWebservice()
            sbUserService.alertMessageDelegate = self
            sbUserService.activityAnimationServiceDelegate = self
            sbUserService.changeUserProfileImage(forUserID: Auth.auth().currentUser!.uid, image: image)
            
            }
        self.dismiss(animated: true, completion: nil)
    }
}
