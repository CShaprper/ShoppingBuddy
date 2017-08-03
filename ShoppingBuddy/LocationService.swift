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
    var alertMessageDelegate: IAlertMessageDelegate?
    
    //Constructor
    init(mapView:MKMapView, alertDelegate: IAlertMessageDelegate) {
        super.init()
        self.alertMessageDelegate  = alertDelegate
        self.delegate = self
        self.allowsBackgroundLocationUpdates = true
        self.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.distanceFilter = CLLocationDistance(exactly: 1000)!
        //self.monitoredRegions
        self.mapView = mapView
        self.mapView.delegate = self
        self.mapView.userTrackingMode = .follow
        self.mapView.showsUserLocation = true
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
        self.mapView.centerCoordinate = locations[0].coordinate
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let title = "\(region.identifier) \(String.LocationManagerEnteredRegion_AlertTitle)"
        let message = String.LocationManagerEnteredRegion_AlertMessage
        if alertMessageDelegate != nil{
            alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
        } else {
            print("Alert message delegate not set from calling class in LocationService")
        }
        ShowNotification(title: title, message: message)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        //toDo: remove monitored region
        print("locationManager failed Monitoring for region \(region!.identifier) with error \(error.localizedDescription)")
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
        var region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpanMake(0.05, 0.05)) //0.01° = 1100 meter
        region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, CLLocationDistance(exactly: 5000)!, CLLocationDistance(exactly: 5000)!)
        mapView.setRegion(region, animated: false)
    }
    
    //MARK: - Helper Functions
    func RequestGPSAuthorization() -> Void{
        if CLLocationManager.authorizationStatus() == .notDetermined{
            self.requestAlwaysAuthorization()
        }
        if CLLocationManager.authorizationStatus() == .authorizedAlways{
            self.startUpdatingLocation()
        }
        if CLLocationManager.authorizationStatus() == .denied{
            let title = String.GPSAuthorizationRequestDenied_AlertTitle
            let message = String.GPSAuthorizationRequestDenied_AlertMessage
            self.ShowAlertMessage(title: title, message: message)
        }
    }
    func GeofenceRegion(coorodinate: CLLocationCoordinate2D, radius: CLLocationDistance) -> Void{
        let region = CLCircularRegion(center: coorodinate, radius: radius, identifier: "geofence region")
        self.startMonitoring(for: region)
        let circle = MKCircle(center: coorodinate, radius: region.radius)
        mapView.add(circle)
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
    func LocalSearchRequest(queryString: String){
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
            for item in response!.mapItems {
                print("Name = \(String(describing: item.name))")
                
                let annotation = CustomMapAnnotation()
                annotation.image = #imageLiteral(resourceName: "map-Marker-green")
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}
