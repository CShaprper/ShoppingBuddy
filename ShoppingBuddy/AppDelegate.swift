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
import UserNotifications
import CoreData

var ShoppingListsArray:[ShoppingList] = []
var StoresArray:[String] = []
var CurrentUserProfileImage:UIImage? 
var ProfileImageCache:[CacheUserProfileImage] = []

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
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.statusBarBackgroundColor = UIColor.clear
        
        //Set Badegcount to zero
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        let firstAction:UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        firstAction.identifier = "startNavigation"
        firstAction.title = "Start Navigation"
        firstAction.activationMode = UIUserNotificationActivationMode.background
        firstAction.isDestructive = false
        firstAction.isAuthenticationRequired = false
        
        let secondAction:UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        secondAction.identifier = "cancel"
        secondAction.title = "Cancel"
        secondAction.activationMode = UIUserNotificationActivationMode.background
        secondAction.isDestructive = true
        secondAction.isAuthenticationRequired = false
        
        let notificationActions = [firstAction, secondAction]
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "CATEGORY_IDENTIFIER"
        category.setActions(notificationActions, for: .default)
        
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge], categories: [category]) 
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
                if error != nil{ print(error!.localizedDescription); return }
                if granted {
                    application.registerForRemoteNotifications()
                    application.registerUserNotificationSettings(notificationSettings)
                }
                else {
                    application.unregisterForRemoteNotifications() //todo: remove token from firebase
                    application.registerUserNotificationSettings(notificationSettings)
                }
            })
        } else {
            // Fallback on earlier versions
            //If user is not on iOS 10 use the old methods
            let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let setting = UIUserNotificationSettings(types: type, categories: [category])
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        //Set standard Map Zoom
        if UserDefaults.standard.value(forKey: eUserDefaultKey.MonitoredRadius.rawValue) == nil{
            UserDefaults.standard.set(7000, forKey: eUserDefaultKey.MapSpan.rawValue)
        }
        
        //Set standard value
        UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        UserDefaults.standard.set(true, forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
        NSLog("Successfully registered for RemoteNotifications with token")
        print(tokenString(deviceToken))
    }
    func tokenString(_ deviceToken:Data) -> String{
        //code to make a token string
        let bytes = [UInt8](deviceToken)
        var token = ""
        for byte in bytes{
            token += String(format: "%02x",byte)
        }
        return token
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        let token:String = Messaging.messaging().fcmToken!
        print(token)
        let fbUser = FirebaseUser()
        fbUser.SetNewFcmToken(token: token)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
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
        
        //Set Badegcount to zero
        UIApplication.shared.applicationIconBadgeNumber = 0
        UserDefaults.standard.set(true, forKey: eUserDefaultKey.isInitialLocationUpdate.rawValue)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

