//
//  DashboardController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import MapKit
import FirebaseMessaging
import CoreLocation
import UserNotifications
import FirebaseAuth
import MobileCoreServices
import GoogleMobileAds

var possibleRegionsPerStore:Int = 4

class DashboardController: UIViewController, IAlertMessageDelegate, IActivityAnimationService, UIGestureRecognizerDelegate{
    //MARK: - Outlets
    @IBOutlet var BackgroundView: UIImageView!
    @IBOutlet var MapView: MKMapView!
    @IBOutlet var UserProfileImage: UIImageView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var lbl_ObeservedStores: UILabel!
    @IBOutlet var lbl_ObservedStoresCount: UILabel!
    @IBOutlet var lbl_ObservedLists: UILabel!
    @IBOutlet var lbl_ObservedListsCount: UILabel!
    @IBOutlet var lbl_YourLists: UILabel!
    @IBOutlet var lbl_YourListsCount: UILabel!
    @IBOutlet var btn_IncreaseMapSpan: UIButton!
    @IBOutlet var bnt_DecreaseMapSpan: UIButton!
    @IBOutlet var NoteBook: UIImageView!
    @IBOutlet var lbl_PinnedAddress: UILabel!
    @IBOutlet var lbl_Address: UILabel!
    @IBOutlet var btn_Info: UIBarButtonItem!
    
    //Onboarding Info View
    @IBOutlet var OnboardindInfoView: UIImageView!
    
    
    
    //NotificationView
    @IBOutlet var InvitationNotification: UIView!
    @IBOutlet var lbl_InviteTitle: UILabel!
    @IBOutlet var txt_NotificationMessage: UITextView!
    @IBOutlet var InviteUserImage: UIImageView!
    @IBOutlet var LupeImage: UIImageView!
    @IBOutlet var btn_PinHomePosition: UIButton!
    @IBOutlet var btn_SwitchMapView: UIButton!
    @IBOutlet var UserProfileImageStar: UIImageView!
    
    //MARK: - Member
    var debugcounter:Int = 0 //can be removed in release
    internal var locationManager:CLLocationManager!
    internal var radiusToMonitore:CLLocationDistance!
    internal var mapSpan:Double!
    internal var userLocation:CLLocationCoordinate2D?
    private var isInfoViewVisible:Bool!
    private var sbUserWebservice:ShoppingBuddyUserWebservice!
    private var sbMessagesWebService:ShoppingBuddyMessageWebservice!
    var sbListWebservice:ShoppingBuddyListWebservice!
    var timer:Timer!
    var bannerView:GADBannerView!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
        
        sbUserWebservice.GetCurrentUser()
        lbl_ObservedStoresCount.text = String(locationManager.monitoredRegions.count)
        mapSpan = abs(UserDefaults.standard.double(forKey: eUserDefaultKey.MapSpan.rawValue))
        
        GetReverseGeolocation()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let image = #imageLiteral(resourceName: "Lupe").cgImage
        let maskLayer = CALayer()
        maskLayer.contents = image
        
        // Just some test values. Adjust them to see different results
        let originalPhotoFrame = CGRect(x: 0,y: 0, width: 510, height: 536)
        let backgroundLayerFrame = CGRect(x: 0, y: 0, width: LupeImage.frame.width, height: LupeImage.frame.height)
        
        // Now figure out whether the ScaleAspectFit was horizontally or vertically bound.
        let horizScale = backgroundLayerFrame.width / originalPhotoFrame.width
        let vertScale = backgroundLayerFrame.height / originalPhotoFrame.height
        let myScale = min(horizScale, vertScale)
        
        // So we don't need to do each of these calculations on a separate line, but for ease of explanation…
        // Now we can calculate the size to scale originalPhoto
        let scaledSize = CGSize(width: originalPhotoFrame.size.width * myScale,
                                height: originalPhotoFrame.size.height * myScale)
        // And now we need to center originalPhoto inside backgroundLayerFrame
        let scaledOrigin = CGPoint(x: (backgroundLayerFrame.width - scaledSize.width) / 2,
                                   y: (backgroundLayerFrame.height - scaledSize.height) / 2)
        
        // Put it all together
        let scaledPhotoRect = CGRect(origin: scaledOrigin, size: scaledSize)
        maskLayer.frame = scaledPhotoRect
        MapView.layer.mask = maskLayer
        
        UserProfileImage.layer.cornerRadius = UserProfileImage.frame.width * 0.5
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PerformLocalShopSearch(notification: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        refreshDashboardData()
        
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
        
        // view.addSubview(ActivityIndicator)
        
    }
    func HideActivityIndicator()  -> Void {
        
        if view.subviews.contains(ActivityIndicator) {
            OperationQueue.main.addOperation {
                self.ActivityIndicator.removeFromSuperview()                
            }
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
    
    
    @objc func ShoppingBuddyUserLoggedOut(notification: Notification)  -> Void {
        
        allShoppingLists = []
        allUsers = []
        allMessages = []
        currentUser!.id = nil
        currentUser!.email = nil
        currentUser!.fcmToken = nil
        currentUser!.isFullVersionUser = nil
        currentUser!.localImageLocation = nil
        currentUser!.nickname = nil
        currentUser!.profileImage = nil
        currentUser!.profileImageURL = nil 
        UserDefaults.standard.removeObject(forKey: eUserDefaultKey.HomeLatitude.rawValue)
        UserDefaults.standard.removeObject(forKey: eUserDefaultKey.HomeLongitude.rawValue)
        UserDefaults.standard.removeObject(forKey: eUserDefaultKey.CurrentUserID.rawValue)
        UserDefaults.standard.removeObject(forKey: eUserDefaultKey.MapSpan.rawValue)
        UserDefaults.standard.removeObject(forKey: eUserDefaultKey.MonitoredRadius.rawValue)
        
    }
    /* wird kurioser Weise mehrmals nacheinander aufgerufen
    @objc func ShoppingBuddyUserLoggedIn(notification: Notification)  -> Void {

    }*/
    @objc func CurrentUserCreated(notification: Notification) -> Void {
        
        sbUserWebservice.GetCurrentUser()
        
    }
    
    @objc func UserProfileImageDownloadFinished(notification:Notification)  -> Void {
        
        if let index = allUsers.index(where: { $0.profileImageURL == currentUser!.profileImageURL }) {
            
            OperationQueue.main.addOperation {
                self.UserProfileImage.image = allUsers[index].profileImage
                self.UserProfileImage.alpha = 1
            }
            
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
        
        if let index = allUsers.index(where: { $0.id == Auth.auth().currentUser!.uid }) {
            
            if allUsers[index].isFullVersionUser != nil {
                
                UserProfileImageStar.alpha = allUsers[index].isFullVersionUser! ? 1 : 0
                
            } else {
                
                UserProfileImageStar.alpha = 0
                
            }
            
        }
        
        sbMessagesWebService.ObserveAllMessages()
        sbListWebservice.GetStoresForGeofencing()
        sbListWebservice.ObserveAllList()   
        
    }
    
    @objc func ShoppingBuddyListDataReceived(notification: Notification) -> Void {
        
        refreshDashboardData()
        
    }
    
    private func refreshDashboardData() -> Void {
        
        var ownListsCount:Int = 0
        var observedListCount:Int = 0
        for list in allShoppingLists {
            if currentUser!.id == list.owneruid! { ownListsCount += 1 }
            if currentUser!.id != list.owneruid! { observedListCount += 1 }
        }
        lbl_ObservedListsCount.text = String(observedListCount)
        lbl_YourListsCount.text = String(ownListsCount)
        
    }
    
    
    
    //MARK: - Wired Actions
    @objc func LogOutBarButtonItemPressed(sender: UIBarButtonItem) -> Void {
        
        sbUserWebservice.LogFirebaseUserOut()
        
    }
    @objc func SegueToLoginController(notification: Notification) -> Void {
        
        performSegue(withIdentifier: String.SegueToLoginController_Identifier, sender: nil)
        
    }
    
    @objc func btn_SwitchMapView_Pressed(sender: UIButton) -> Void {
        
        MapView.mapType = MapView.mapType == .standard ? .hybrid : .standard
        
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
        txt_NotificationMessage.text = notificationMessage
        
        if let index = allUsers.index(where: { $0.id == senderID } ) {
            
            guard let image = allUsers[index].profileImage else {
                InviteUserImage.image = #imageLiteral(resourceName: "userPlaceholder")
                displayNotification()
                return
            }
            InviteUserImage.image = image
            
        }
        
        displayNotification()
        
        
    }
    @objc func btn_PinHomePosition_Pressed(sender: UIButton) -> Void {
        
        SaveCurrentLocationAsHomeLocation(coordinate: self.userLocation!)
        GetReverseGeolocation()
        
    }
    
    @objc func btn_IncreaseMapSpan_Pressed(sender: UIButton) -> Void {
        
        var dist = UserDefaults.standard.double(forKey: eUserDefaultKey.MapSpan.rawValue)
        if dist <= 1000 {
            UserDefaults.standard.set(1000, forKey: eUserDefaultKey.MapSpan.rawValue)
            mapSpan = 1000
        } else {
            dist -= 1000
            mapSpan = dist
            guard let location = userLocation else { return }
            UserDefaults.standard.set(dist, forKey: eUserDefaultKey.MapSpan.rawValue)
            let region = MKCoordinateRegionMakeWithDistance(location, CLLocationDistance(exactly: mapSpan)!, CLLocationDistance(exactly: mapSpan)!)
            MapView.setRegion(region, animated: false)
        }
        
    }
    
    @objc func btn_DecreaseMapSpan_Pressed(sender: UIButton) -> Void {
        
        guard let location = userLocation else { return }
        var dist = UserDefaults.standard.double(forKey: eUserDefaultKey.MapSpan.rawValue)
        dist += 1000
        mapSpan = abs(dist)
        UserDefaults.standard.set(dist, forKey: eUserDefaultKey.MapSpan.rawValue)
        //UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
         let region = MKCoordinateRegionMakeWithDistance(location, CLLocationDistance(exactly: abs(mapSpan))!, CLLocationDistance(exactly: abs(mapSpan))!)
        MapView.setRegion(region, animated: false)
        
        
        
    }
    @IBAction func btn_Info_Pressed(_ sender: UIBarButtonItem) {
        
        if isInfoViewVisible { hideInfoView() }
        else { showInfoView() }
        
    }
    
    private func showInfoView() -> Void {
        
        if !isInfoViewVisible {
            
            isInfoViewVisible = true
            
            OnboardindInfoView.image = UIImage(named: String.DashboardOnboardingImage)
            OnboardindInfoView.bounds = BackgroundView.bounds
            OnboardindInfoView.alpha = 0
            OnboardindInfoView.isUserInteractionEnabled = true
            view.addSubview(OnboardindInfoView)
            OnboardindInfoView.center = BackgroundView.center
            OnboardindInfoView.transform = CGAffineTransform(translationX: 0, y: view.frame.height).scaledBy(x: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                
                self.OnboardindInfoView.alpha = 1
                self.OnboardindInfoView.transform = .identity
                
            }, completion: nil)
            
        }
    }
    
    private func hideInfoView() -> Void {
        
        if isInfoViewVisible {
            
            isInfoViewVisible = false
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                
                self.OnboardindInfoView.alpha = 0
                self.OnboardindInfoView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
                
            }, completion: { (true) in
                
                if self.view.subviews.contains(self.OnboardindInfoView) {
                    self.OnboardindInfoView.removeFromSuperview()
                }
                
            })
        }
        
    }
    
    private func displayNotification() -> Void {
        
        //Invite Notification View
        let size = txt_NotificationMessage.sizeThatFits(CGSize(width: txt_NotificationMessage.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        InvitationNotification.frame.size.height = size.height + lbl_InviteTitle.frame.height + 30
        InvitationNotification.center.x = view.center.x
        InvitationNotification.center.y = -InvitationNotification.frame.height
        InvitationNotification.layer.cornerRadius = 30
        InvitationNotification.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        InvitationNotification.layer.borderWidth = 3
        InviteUserImage.layer.cornerRadius = InviteUserImage.frame.width * 0.5
        InviteUserImage.clipsToBounds = true
        InviteUserImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        InviteUserImage.layer.borderWidth = 3
        InvitationNotification.layer.shadowColor  = UIColor.black.cgColor
        InvitationNotification.layer.shadowOffset  = CGSize(width: 30, height:30)
        InvitationNotification.layer.shadowOpacity  = 1
        InvitationNotification.layer.shadowRadius  = 10
        
        view.addSubview(InvitationNotification)
        
        SoundPlayer.PlaySound(filename: "pling", filetype: "wav")
        UIView.animate(withDuration: 2) {
            
            self.InvitationNotification.transform = CGAffineTransform(translationX: 0, y: self.InvitationNotification.frame.size.height * 2 + self.topLayoutGuide.length)
            
        }
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(HideNotification), userInfo: nil, repeats: false)
        
    }
    
    
    
    //MARK: - Helper Functions
    func ConfigureView() -> Void {
        isInfoViewVisible = false
        btn_Info.tintColor = UIColor.ColorPaletteTintColor()
        
        //btn Switch MapView
        btn_SwitchMapView.addTarget(self, action: #selector(btn_SwitchMapView_Pressed), for: .touchUpInside)
        
        //UserProfileImage
        UserProfileImage.layer.cornerRadius = UserProfileImage.frame.width * 0.5
        UserProfileImage.clipsToBounds = true
        UserProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        UserProfileImage.layer.borderWidth = 3
        UserProfileImage.image = #imageLiteral(resourceName: "userPlaceholder")
        UserProfileImage.layer.shadowColor  = UIColor.black.cgColor
        UserProfileImage.layer.shadowOffset  = CGSize(width: 20, height:20)
        UserProfileImage.layer.shadowOpacity  = 1
        UserProfileImage.layer.shadowRadius  = 10
        UserProfileImageStar.alpha = 0
        
        NoteBook.layer.shadowColor  = UIColor.black.cgColor
        NoteBook.layer.shadowOffset  = CGSize(width: 5, height:5)
        NoteBook.layer.shadowOpacity  = 1
        NoteBook.layer.shadowRadius  = 3 
        
        //Dashboard Messages
        lbl_ObservedLists.text = String.lbl_ObservedListsText
        lbl_YourLists.text = String.lbl_YourListsText
        lbl_ObeservedStores.text = String.lbl_ObeservedStoresText
        lbl_PinnedAddress.attributedText = NSAttributedString(string: String.lbl_PinnedAddress, attributes:
            [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        lbl_Address.text = ""
        
        //Notification Listener DahsboardController
        NotificationCenter.default.addObserver(forName: .UserProfileImageDownloadFinished, object: nil, queue: OperationQueue.main, using: UserProfileImageDownloadFinished)
        NotificationCenter.default.addObserver(forName: .CurrentUserReceived, object: nil, queue: OperationQueue.main, using: CurrentUserReceived)
        NotificationCenter.default.addObserver(forName: .SegueToLogInController, object: nil, queue: OperationQueue.main, using: SegueToLoginController)
        NotificationCenter.default.addObserver(forName: .PerformLocalShopSearch, object: nil, queue: OperationQueue.main, using: PerformLocalShopSearch)
        NotificationCenter.default.addObserver(forName: .PushNotificationReceived, object: nil, queue: OperationQueue.main, using: PushNotificationReceived)
        NotificationCenter.default.addObserver(forName: .ShoppingBuddyUserLoggedOut, object: nil, queue: OperationQueue.main, using: ShoppingBuddyUserLoggedOut)
        NotificationCenter.default.addObserver(forName: .ShoppingBuddyStoreReceived, object: nil, queue: OperationQueue.main, using: ShoppingBuddyStoreReceived)
        NotificationCenter.default.addObserver(forName: .CurrentUserCreated, object: nil, queue: OperationQueue.main, using: CurrentUserCreated)
        NotificationCenter.default.addObserver(forName: .ShoppingBuddyListDataReceived, object: nil, queue: OperationQueue.main, using: ShoppingBuddyListDataReceived)
        
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
        
        //Magnifiying glass shadow
        LupeImage.layer.shadowColor  = UIColor.black.cgColor
        LupeImage.layer.shadowOffset  = CGSize(width: 20, height: 20)
        LupeImage.layer.shadowOpacity  = 1
        LupeImage.layer.shadowRadius  = 10
        
        //Increase / Decrease Map Span
        btn_IncreaseMapSpan.layer.shadowColor  = UIColor.black.cgColor
        btn_IncreaseMapSpan.layer.shadowOffset  = CGSize(width: 10, height: 5)
        btn_IncreaseMapSpan.layer.shadowOpacity  = 1
        btn_IncreaseMapSpan.layer.shadowRadius  = 3
        btn_IncreaseMapSpan.addTarget(self, action: #selector(btn_IncreaseMapSpan_Pressed), for: .touchUpInside)
        
        bnt_DecreaseMapSpan.layer.shadowColor  = UIColor.black.cgColor
        bnt_DecreaseMapSpan.layer.shadowOffset  = CGSize(width: 10, height: 5)
        bnt_DecreaseMapSpan.layer.shadowOpacity  = 1
        bnt_DecreaseMapSpan.layer.shadowRadius  = 3
        bnt_DecreaseMapSpan.addTarget(self, action: #selector(btn_DecreaseMapSpan_Pressed), for: .touchUpInside)
        
        //SetNavigationBar Title
        navigationItem.title = String.DashboardControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.DashboardControllerTitle
        
        //Load all Stores
        sbListWebservice = ShoppingBuddyListWebservice()
        sbListWebservice.activityAnimationServiceDelegate = self
        sbListWebservice.alertMessageDelegate = self
        
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
        
        //Pin Home Position Button
        btn_PinHomePosition.addTarget(self, action: #selector(btn_PinHomePosition_Pressed), for: .touchUpInside)
        btn_PinHomePosition.layer.shadowColor  = UIColor.black.cgColor
        btn_PinHomePosition.layer.shadowOffset  = CGSize(width: 10, height: 5)
        btn_PinHomePosition.layer.shadowOpacity  = 1
        btn_PinHomePosition.layer.shadowRadius  = 3
        
        //LogOut Button
        let logoutButton = UIBarButtonItem(title: "log out", style: UIBarButtonItemStyle.plain, target: self, action:#selector(LogOutBarButtonItemPressed))
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset =  CGSize(width: -2, height: -2)
        logoutButton.setTitleTextAttributes([NSAttributedStringKey.shadow:shadow, NSAttributedStringKey.strokeWidth:-1, NSAttributedStringKey.strokeColor:UIColor.black, NSAttributedStringKey.foregroundColor:UIColor.ColorPaletteTintColor(), NSAttributedStringKey.font:UIFont(name: "Courgette-Regular", size: 17)!], for: .normal)
        self.navigationItem.leftBarButtonItem = logoutButton        
      
    }
    
    func GetReverseGeolocation(){
        
        guard let location = ReadUsersPinnedHomeLocationToMonitoreFromUserDefaults() else { return }
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            
            if error != nil {
                self.ShowAlertMessage(title: String.OnlineFetchRequestError, message: error!.localizedDescription)
            }
            
            guard let pms = placemarks else { return }
            
            if pms.count > 0 {
                
                let pm = pms[0] as CLPlacemark
                var street:String = ""
                if pm.thoroughfare != nil { street = pm.thoroughfare! }
                if pm.subThoroughfare != nil { street.append(" " + pm.subThoroughfare!) }
                if pm.postalCode != nil { street.append(", " + pm.postalCode!) }
                if pm.locality != nil { street.append(" " + pm.locality!) }
                self.lbl_Address.text = street
                
            }
        }
        
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
        UIApplication.shared.applicationIconBadgeNumber += 1
        Messaging.messaging().appDidReceiveMessage(notification.request.content.userInfo)
        let pnh = PushNotificationHelper()
        pnh.SendNotificationDependendOnPushNotificationType(userInfo: notification.request.content.userInfo)
        
    }
    //Lets you know action decision from Notification
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let action = response.actionIdentifier
        let request = response.notification.request
        let content = request.content
        
        if action == "startNavigation" {
            
            print("Start navigation from notification")
            
        }
        
        
    }
    
}


extension DashboardController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        mapSpan = UserDefaults.standard.double(forKey: eUserDefaultKey.MapSpan.rawValue)
        self.userLocation = userLocation.coordinate
        mapView.centerCoordinate = userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, CLLocationDistance(exactly: mapSpan)!, CLLocationDistance(exactly: mapSpan)!)
        mapView.setRegion(region, animated: false)
        
        if  UserDefaults.standard.bool(forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue){
            //Search nearby Shops
            PerformLocalShopSearch(notification: nil)
            UserDefaults.standard.set(false, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        }
    }
    
    //MARK: - IShoppingBuddyListWebService implementation
    func ShoppingBuddyStoreReceived(notification: Notification) {
        
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
            OperationQueue.main.addOperation { 
                self.StartMonitoringGeofenceRegions(mapItems: response!.mapItems)
            }
        }
    }
    //MARK: MKMapViewDelegate Helper
    func PerformLocalShopSearch(notification: Notification?) -> Void{
        
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
            
            let locationToMonitore = ReadUsersPinnedHomeLocationToMonitoreFromUserDefaults()
            if locationToMonitore == nil { return 0 }
            let distanceToUser = CalculateDistanceBetweenTwoCoordinates(location1: locationToMonitore!.coordinate, location2: mapItem.placemark.coordinate)
            
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
        
        OperationQueue.main.addOperation {
            
            let region = CLCircularRegion(center: mapItem.placemark.coordinate, radius: CLLocationDistance(self.radiusToMonitore), identifier: "\(UUID().uuidString)\("SB_")\(mapItem.name!)")
            self.locationManager.startMonitoring(for: region)
            self.lbl_ObservedStoresCount.text = String(self.locationManager.monitoredRegions.count)
            
        }
        
    }
    private func SetAnnotations(mapItem: MKMapItem) -> Void {
        
        OperationQueue.main.addOperation {
            
            if !self.MapView.annotations.contains(where: {$0.subtitle! == mapItem.placemark.title}) {
                
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
    
    private func ReadUsersPinnedHomeLocationToMonitoreFromUserDefaults() -> CLLocation? {
        
        guard let _ = UserDefaults.standard.object(forKey: eUserDefaultKey.HomeLatitude.rawValue) else { return nil }
        guard let _ = UserDefaults.standard.object(forKey: eUserDefaultKey.HomeLongitude.rawValue) else { return nil }
        
        let latitude = UserDefaults.standard.double(forKey: eUserDefaultKey.HomeLatitude.rawValue)
        let longitude = UserDefaults.standard.double(forKey: eUserDefaultKey.HomeLongitude.rawValue)
        
        if latitude > 0 && longitude > 0 {
            
            return CLLocation(latitude: CLLocationDegrees(floatLiteral: latitude), longitude: CLLocationDegrees(floatLiteral: longitude))
            
        }
            
        else { return nil }
    }
    
    private func SaveCurrentLocationAsHomeLocation(coordinate: CLLocationCoordinate2D) -> Void {
        
        UserDefaults.standard.set(coordinate.latitude, forKey: eUserDefaultKey.HomeLatitude.rawValue)
        UserDefaults.standard.set(coordinate.longitude, forKey: eUserDefaultKey.HomeLongitude.rawValue)
        UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        
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
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
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
            let region = MKCoordinateRegionMakeWithDistance(userLocation!, CLLocationDistance(exactly: abs(mapSpan))!, CLLocationDistance(exactly: abs(mapSpan))!)
            MapView.setRegion(region, animated: false)
            MapView.centerCoordinate = location.coordinate
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        let str:[String] = region.identifier.components(separatedBy: "SB_")
        if str.count <= 0 { return }
        
        var regionStr:String = ""
        regionStr = str.last!
        let title =  String.localizedStringWithFormat(String.LocationManagerEnteredRegion_AlertTitle, regionStr)
        let message = String.localizedStringWithFormat(String.LocationManagerEnteredRegion_AlertMessage, regionStr)
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
            
            let circle = MKCircle(center: circularRegion.center, radius: circularRegion.radius)
            self.MapView.add(circle)
            
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
extension DashboardController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        UIView.animate(withDuration: 2) {
            self.bannerView.alpha = 1
        }
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
