//
//  AppDelegate.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Google places
        GMSPlacesClient.provideAPIKey("AIzaSyAg3-8DEQUWdWXznwU7OkIGVFL05f44xLg")
        
        //Firebase
        FirebaseApp.configure()
        Messaging.messaging().shouldEstablishDirectChannel = true
        Messaging.messaging().delegate = self
        
        //Global StatusBar Style
        UIApplication.shared.statusBarStyle = .default
        UIApplication.statusBarBackgroundColor = UIColor.ColorPaletteBrightest()
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        let token:[String:AnyObject] = [Messaging.messaging().fcmToken!:Messaging.messaging().fcmToken as AnyObject]
        print(token)
        //Refresh Token for Push Notification
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference()
            ref.child("users").child(uid).child(Messaging.messaging().fcmToken!).setValue(token)
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

