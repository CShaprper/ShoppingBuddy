//
//  StoresController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class SettingsController: UIViewController, UITextFieldDelegate, IValidationService{
    //MARK: - Outlets
    @IBOutlet var BackgroundView: UIImageView!
    @IBOutlet var GeofenceRadiusSlider: UISlider!
    @IBOutlet var lbl_RadiusZero: UILabel!
    @IBOutlet var lbl_RadiusOne: UILabel!
    @IBOutlet var lbl_RadiusTwo: UILabel!
    @IBOutlet var lbl_RadiusThree: UILabel!
    @IBOutlet var lbl_RadiusFour: UILabel!
    @IBOutlet var btn_GetFullVersion: UIButton!
    @IBOutlet var btn_RestorePurchase: UIButton!
    @IBOutlet var btn_RateMe: UIButton!
    @IBOutlet var btn_ShareMe: UIButton!
    
    //InviatationNotification
    @IBOutlet var InvitationNotification: UIView!
    @IBOutlet var lbl_InviteTitle: UILabel!
    @IBOutlet var txt_InviteMessage: UITextView!
    @IBOutlet var InviteUserImage: UIImageView!
    @IBOutlet var NotificationUserStarImage: UIImageView!
    
    
    //MARK: - Member
    var blurrView:UIVisualEffectView!
    var iapHelper:IAPHelper!
    var bannerView:GADBannerView!
    var timer:Timer!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
        
        timer = Timer()
        iapHelper = IAPHelper()
        iapHelper.alertMessageDelegate = self
        iapHelper.requestProducts()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    //MARK: - Textfield Delegate implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    //MARK: IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Wired actions
    @objc func GeofenceRadiusSlider_Changed(sender: UISlider) -> Void {
        let value = roundf(sender.value * 2) / 2
        print(value)
        GeofenceRadiusSlider.value = value
        SetGeofenceRadiusSliderValue(value: value)
        UserDefaults.standard.set(value * 1000, forKey: eUserDefaultKey.MonitoredRadius.rawValue)
    }
    
    @objc func btn_GetFullVersion_Pressed(sender: UIButton) -> Void {
        
        Analytics.logEvent("UserPressedButton", parameters: [AnalyticsParameterItemID : "btn_GetFullVersion_Pressed" as NSObject] )
        iapHelper.buyProduct(productIdentifier: eIAPIndentifier.SBFullVersion.rawValue)
        
    }
    
    @objc func btn_RestorePurchase_Pressed(sender: UIButton) -> Void {
        
        Analytics.logEvent("UserPressedButton", parameters: [AnalyticsParameterItemID : "btn_RestorePurchase_Pressed" as NSObject] )
        
        iapHelper.restorePurchases()
        
    }
    
    @objc func btn_RateMe_Pressed(sender: UIButton) -> Void {
        
        Analytics.logEvent("UserPressedButton", parameters: [AnalyticsParameterItemID : "btn_RateMe_Pressed" as NSObject] )
        let appDel = AppDelegate()
        appDel.requestReview()
        
    }
    
    @objc func btn_ShareMe_Pressed(sender: UIButton) -> Void {
        
         Analytics.logEvent("UserPressedButton", parameters: [AnalyticsParameterItemID : "btn_ShareMe_Pressed" as NSObject] )
        
        let url = URL(string: "itms-apps://itunes.apple.com/app/id1281336748")!
        
        let activityVC = UIActivityViewController(activityItems: [#imageLiteral(resourceName: "DropShopper_Icon-128"), url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
        
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
        
        return
        guard let info = notification.userInfo else { return }
        
        guard let notificationTitle = info["notificationTitle"] as? String,
            let notificationMessage = info["notificationMessage"] as? String,
            let senderID = info["senderID"] as? String else { return }
        
        lbl_InviteTitle.text = notificationTitle
        txt_InviteMessage.text = notificationMessage
        
        if let index = allUsers.index(where: { $0.id == senderID } ) {
            
            if allUsers[index].profileImage! != #imageLiteral(resourceName: "userPlaceholder") {
                InviteUserImage.image = allUsers[index].profileImage!
                if allUsers[index].isFullVersionUser != nil  {
                    NotificationUserStarImage.alpha = allUsers[index].isFullVersionUser! ? 1 : 0
                } else { NotificationUserStarImage.alpha = 0}
                displayNotification()
                
            }
            
        }
    }
    
    private func displayNotification() -> Void {
        
        //Invite Notification View
         let size = txt_InviteMessage.sizeThatFits(CGSize(width: txt_InviteMessage.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        InvitationNotification.frame.size.height = size.height + lbl_InviteTitle.frame.height + 30
        InvitationNotification.center.x = view.center.x
        InvitationNotification.center.y = -InvitationNotification.frame.height
        InvitationNotification.frame.size.width = view.frame.width * 0.8
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
        UIView.animate(withDuration: 2) {
            
            self.InvitationNotification.transform = CGAffineTransform(translationX: 0, y: self.InvitationNotification.frame.size.height * 2 + self.topLayoutGuide.length)
            
        }
        
        SoundPlayer.PlaySound(filename: "pling", filetype: "wav")
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(HideNotification), userInfo: nil, repeats: false)
        
    }
    
    //MARK: - Helper Functions
    func ConfigureView() -> Void{
        
        //Notification listeners
        NotificationCenter.default.addObserver(forName: .PushNotificationReceived, object: nil, queue: OperationQueue.main, using: PushNotificationReceived)
        
        btn_RestorePurchase.addTarget(self, action: #selector(btn_RestorePurchase_Pressed), for: .touchUpInside)
        
        btn_GetFullVersion.addTarget(self, action: #selector(btn_GetFullVersion_Pressed), for: .touchUpInside)
        
        btn_RateMe.addTarget(self, action: #selector(btn_RateMe_Pressed), for: .touchUpInside)
        
        btn_ShareMe.addTarget(self, action: #selector(btn_ShareMe_Pressed), for: .touchUpInside)
        
        GeofenceRadiusSlider.addTarget(self, action: #selector(GeofenceRadiusSlider_Changed), for: .valueChanged)
        
        let savedSilderValue = UserDefaults.standard.float(forKey: eUserDefaultKey.MonitoredRadius.rawValue) / 1000
        SetGeofenceRadiusSliderValue(value: savedSilderValue)
        
    }
    func SetGeofenceRadiusSliderValue(value: Float) -> Void{
        GeofenceRadiusSlider.value = value
        switch value {
        case 0:
            lbl_RadiusZero.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusOne.textColor = UIColor.lightGray
            lbl_RadiusTwo.textColor = UIColor.lightGray
            lbl_RadiusThree.textColor = UIColor.lightGray
            lbl_RadiusFour.textColor = UIColor.lightGray
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            break
        case 0.5:
            lbl_RadiusOne.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusZero.textColor = UIColor.lightGray
            lbl_RadiusTwo.textColor = UIColor.lightGray
            lbl_RadiusThree.textColor = UIColor.lightGray
            lbl_RadiusFour.textColor = UIColor.lightGray
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            break
        case 1.0:
            lbl_RadiusTwo.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusZero.textColor = UIColor.lightGray
            lbl_RadiusOne.textColor = UIColor.lightGray
            lbl_RadiusThree.textColor = UIColor.lightGray
            lbl_RadiusFour.textColor = UIColor.lightGray
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            break
        case 1.5:
            lbl_RadiusThree.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusZero.textColor = UIColor.lightGray
            lbl_RadiusOne.textColor = UIColor.lightGray
            lbl_RadiusTwo.textColor = UIColor.lightGray
            lbl_RadiusFour.textColor = UIColor.lightGray
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        case 2.0:
            lbl_RadiusFour.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusZero.textColor = UIColor.lightGray
            lbl_RadiusOne.textColor = UIColor.lightGray
            lbl_RadiusTwo.textColor = UIColor.lightGray
            lbl_RadiusThree.textColor = UIColor.lightGray
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        default:
            break
        }
    }
}
