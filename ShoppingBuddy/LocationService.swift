//
//  LocationService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 02.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import UserNotifications

class LocationService:CLLocationManager, CLLocationManagerDelegate, MKMapViewDelegate, IAlertMessageDelegate {
    private var mapView:MKMapView!
    private var mapSpan:Int!
    var alertMessageDelegate: IAlertMessageDelegate?
    private var userLocation:CLLocationCoordinate2D!
    
    //Constructor
    init(mapView:MKMapView, alertDelegate: IAlertMessageDelegate) {
        super.init()
        self.alertMessageDelegate  = alertDelegate
        self.delegate = self
        self.allowsBackgroundLocationUpdates = true
        self.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.distanceFilter = CLLocationDistance(exactly: 5000)!
        self.mapView = mapView
        self.mapView.delegate = self
        self.mapView.userTrackingMode = .follow
        self.mapView.showsUserLocation = true
        mapSpan = UserDefaults.standard.integer(forKey: eUserDefaultKey.MapSpan.rawValue)
        UserDefaults.standard.set(true, forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue)
    }
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil{
            alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
        } else {
            print("Alert message delegate not set from calling class in LocationService")
        }
    }
    
    //MARK: - LocationManagerDelegate implementation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            self.userLocation = location.coordinate
            self.mapView.centerCoordinate = location.coordinate
            
            let latitude = UserDefaults.standard.double(forKey: eUserDefaultKey.LastUserLatitude.rawValue)
            let longitude = UserDefaults.standard.double(forKey: eUserDefaultKey.LastUserLongitude.rawValue)
            if latitude > 0 && longitude > 0{
                let coord1 = CLLocation(latitude: CLLocationDegrees(floatLiteral: latitude), longitude: CLLocationDegrees(floatLiteral: longitude))
                let distance = coord1.distance(from: location)
                if distance > Double(mapSpan) * 0.6{
                    SaveNewValueAsLastUserPosition(location: location)
                }
            } else {
                SaveNewValueAsLastUserPosition(location: location)
            }
        }
    }
    private func SaveNewValueAsLastUserPosition(location: CLLocation) -> Void{
        UserDefaults.standard.set(location.coordinate.latitude, forKey: eUserDefaultKey.LastUserLatitude.rawValue)
        UserDefaults.standard.set(location.coordinate.longitude, forKey: eUserDefaultKey.LastUserLongitude.rawValue)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let regionStr = region.identifier.replacingOccurrences(of: "SB_", with: "")
        let title = "\(regionStr) \(String.LocationManagerEnteredRegion_AlertTitle)"
        let message = String.LocationManagerEnteredRegion_AlertMessage
        if alertMessageDelegate != nil { alertMessageDelegate?.ShowAlertMessage(title: title, message: message)}
        else { print("AlertMessage delegate not set from calling class in LocationService") }
        ShowNotification(title: title, message: message)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("locationManager failed Monitoring for region \(region!.identifier) with error \(error.localizedDescription)")
        for reg in self.monitoredRegions{
            if reg.identifier == region!.identifier{
                self.stopMonitoring(for: reg)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if let reg = region as? CLCircularRegion{
            let circle = MKCircle(center: reg.center, radius: reg.radius)
            self.mapView.add(circle)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager failed with error")
        print(error.localizedDescription)
    }
    
    //MARK: - MKMapViewDelegate implementation
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else {
            return MKOverlayRenderer()
        }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = UIColor.ColorPaletteorange()
        circleRenderer.alpha = 1
        circleRenderer.lineWidth = 1
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
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, CLLocationDistance(exactly: mapSpan)!, CLLocationDistance(exactly: mapSpan)!)
        mapView.setRegion(region, animated: false)
        
        if UserDefaults.standard.bool(forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue) || UserDefaults.standard.bool(forKey: eUserDefaultKey.hasUserChangedGeofenceRadius.rawValue){
            
            //Set isInitialLocationUpdate false
            UserDefaults.standard.set(false, forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue)
            
            //Set hasUserChangedGeofenceRadius false
            UserDefaults.standard.set(false, forKey: eUserDefaultKey.hasUserChangedGeofenceRadius.rawValue)
            
            //Remove old Overlays from Map
            self.RemoveOldGeofenceOverlays()
            
            // Stop monitoring old regions
            self.StopMonitoringForRegions()
            
            //Search nearby Shops
            PerformLocalShopSearch()
        } else if HasUserMovedDistanceGreaterMapSpan(userLocation: userLocation){
            //Remove old Overlays from Map
            self.RemoveOldGeofenceOverlays()
            
            // Stop monitoring old regions
            self.StopMonitoringForRegions()
            
            //Search nearby Shops
            PerformLocalShopSearch()
        }
    }
    private func ReadLastUserLocationFromUserDefaults() -> CLLocation?{
        let latitude = UserDefaults.standard.double(forKey: eUserDefaultKey.LastUserLatitude.rawValue)
        let longitude = UserDefaults.standard.double(forKey: eUserDefaultKey.LastUserLongitude.rawValue)
        if latitude > 0 && longitude > 0{
            return CLLocation(latitude: CLLocationDegrees(floatLiteral: latitude), longitude: CLLocationDegrees(floatLiteral: longitude))
        }
        else { return nil }
    }
    private func HasUserMovedDistanceGreaterMapSpan(userLocation:MKUserLocation) -> Bool{
        if  let lastUserLocation = ReadLastUserLocationFromUserDefaults(){
            let distance = userLocation.location?.distance(from: lastUserLocation)
            if distance != nil && distance! > Double(mapSpan) * 0.6{
                return true
            }
        }
        return false
    }
    //MARK: MKMapViewDelegate Helper
    func PerformLocalShopSearch() -> Void{
        //Get UserDefaults Array
        let savedStores = UserDefaults.standard.object(forKey: eUserDefaultKey.StoresArray.rawValue) as? [String] ?? [String]()
        for store in savedStores{
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = store
            request.region = mapView.region
            let search = MKLocalSearch(request: request)
            
            search.start { (response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                if response!.mapItems.count == 0 {
                    print("No local search matches found")
                    return
                }
                print("Matches found")
                
                //Start monitoring Geofence regions
                self.GeofenceRegions(response: response)
                
                //Set map Annotations
                self.SetMapAnnotations(response: response)
            }
        }
    }
    
    //MARK: - Helper Functions
    func RequestGPSAuthorization() -> Void{
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.requestAlwaysAuthorization()
        }
        if CLLocationManager.authorizationStatus() == .authorizedAlways{
            self.startMonitoringSignificantLocationChanges()
        }
        if CLLocationManager.authorizationStatus() == .denied{
            let title = String.GPSAuthorizationRequestDenied_AlertTitle
            let message = String.GPSAuthorizationRequestDenied_AlertMessage
            self.ShowAlertMessage(title: title, message: message)
        }
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
    func StopMonitoringForRegions(){
        for region in self.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                print("removing Region: " + circularRegion.identifier)
                if circularRegion.identifier.contains("SB_"){
                    self.stopMonitoring(for: circularRegion)
                }
            }
        }
    }
    private func CalculateDistanceBetweenTwoCoordinates(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> CLLocationDistance {
        let coord1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let coord2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return coord1.distance(from: coord2)
    }
    private func GeofenceRegions(response: MKLocalSearchResponse?) -> Void{
        if response == nil { return }
        if UserDefaults.standard.float(forKey: eUserDefaultKey.MonitoredRadius.rawValue) > 0{
            let radius = UserDefaults.standard.float(forKey: eUserDefaultKey.MonitoredRadius.rawValue) * 1000
            if radius == 0 { StopMonitoringForRegions(); return }
            for item in response!.mapItems {
                let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: userLocation, location2: item.placemark.coordinate)
                if distanceToUser <= Double(mapSpan) * 0.6{
                    let region = CLCircularRegion(center: item.placemark.coordinate, radius: CLLocationDistance(radius), identifier: "\("SB_")\(item.name!)")
                    self.startMonitoring(for: region)
                    print("Start monitoring for region: \(region.identifier)")
                }
            }
        }
    }
    private func RemoveOldGeofenceOverlays() -> Void{
        self.mapView.overlays.forEach{
            if !($0 is MKUserLocation){
                self.mapView.remove($0)
            }
        }
    }
    private func SetMapAnnotations(response: MKLocalSearchResponse?){
        if response == nil { return }
        for item in response!.mapItems {
            print("Adding Annotation: \(String(describing: item.name!))")
            let annotation = CustomMapAnnotation()
            annotation.image = #imageLiteral(resourceName: "map-Marker-green")
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            self.mapView.addAnnotation(annotation)
        }
    }
}
