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
        self.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.distanceFilter = CLLocationDistance(exactly: 5000)!
        self.mapView = mapView
        self.mapView.delegate = self
        self.mapView.userTrackingMode = .follow
        self.mapView.showsUserLocation = true
        mapSpan = UserDefaults.standard.integer(forKey: eUserDefaultKey.MapSpan.rawValue)
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
        self.stopUpdatingLocation() //Battery saving
        self.userLocation = locations[0].coordinate
        self.mapView.centerCoordinate = userLocation
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let regionStr = region.identifier.replacingOccurrences(of: "SB_", with: "")
        let title = "\(regionStr) \(String.LocationManagerEnteredRegion_AlertTitle)"
        let message = String.LocationManagerEnteredRegion_AlertMessage
        if alertMessageDelegate != nil
        {
            alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
        }
        else
        {
            print("Alert message delegate not set from calling class in LocationService")
        }
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
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager failed with error \(error.localizedDescription)")
    }
    
    //MARK: - MKMapViewDelegate implementation
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else {
            return MKOverlayRenderer()   }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = UIColor.ColorPaletteorange()
        circleRenderer.alpha = 0.5
        circleRenderer.lineWidth = 2
        return circleRenderer
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
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
        self.StopMonitoringForRegions()
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, CLLocationDistance(exactly: mapSpan)!, CLLocationDistance(exactly: mapSpan)!)
        mapView.setRegion(region, animated: false)
        //Search nearby Shops
        PerformLocalShopSearch()
    }
    //MARK: MKMapViewDelegate Helper
    func PerformLocalShopSearch() -> Void{
        if ShoppingListsArray.count > 0 {
            for item in ShoppingListsArray{
                let store = item.RelatedStore != nil ? item.RelatedStore! : ""
                if store != "" { PerformLocalSearchRequest(queryString: store) }
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
    private func GeofenceRegions(response: MKLocalSearchResponse) -> Void{
        if UserDefaults.standard.float(forKey: eUserDefaultKey.MonitoredRadius.rawValue) > 0{
            let radius = UserDefaults.standard.float(forKey: eUserDefaultKey.MonitoredRadius.rawValue)
            if radius == 0 { StopMonitoringForRegions(); return }
            for item in response.mapItems {
                let coord1 = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                let coord2 = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let distanceInMeters = coord1.distance(from: coord2)
                if distanceInMeters <= Double(mapSpan){
                    let region = CLCircularRegion(center: item.placemark.coordinate, radius: CLLocationDistance(radius) * 1000, identifier: "\("SB_")\(item.name!)")
                    self.startMonitoring(for: region)
                    let circle = MKCircle(center: item.placemark.coordinate, radius: region.radius)
                    mapView.add(circle)
                }
            }
        }
    }
    func StopMonitoringForRegions(){
        for region in self.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                print(circularRegion.identifier)
                if circularRegion.identifier.contains("SB_"){
                    self.stopMonitoring(for: circularRegion)
                } 
            }
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
                //toDo:??
            })
        } else {
            // Fallback on earlier versions
        }
    }
    func PerformLocalSearchRequest(queryString: String){
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = queryString
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
            self.SetMapAnnotations(response: response!)
            
            self.GeofenceRegions(response: response!)
        }
    }
    
    private func SetMapAnnotations(response: MKLocalSearchResponse){
        for item in response.mapItems {
            print("Name = \(String(describing: item.name))")
            
            let annotation = CustomMapAnnotation()
            annotation.image = #imageLiteral(resourceName: "map-Marker-green")
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            self.mapView.addAnnotation(annotation)
        }
    }
}
