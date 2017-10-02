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
    @IBOutlet var btn_HalfYearSubscription: UIButton!
    
    
    
    //MARK: - Member
    var blurrView:UIVisualEffectView!
    var iapHelper:IAPHelper!
    var bannerView:GADBannerView!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
        
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
    @objc func btn_HalfYearSubscription_Pressed(sender: UIButton) -> Void {
        
        Analytics.logEvent("UserPressedBuyButton", parameters: [AnalyticsParameterItemID : "BuyFullVersion" as NSObject] )
        iapHelper.buyProduct(productIdentifier: eIAPIndentifier.SBFullVersion.rawValue)
        
    }
    
    //MARK: - Helper Functions
    func ConfigureView() -> Void{
        
        btn_HalfYearSubscription.addTarget(self, action: #selector(btn_HalfYearSubscription_Pressed), for: .touchUpInside)
        
        GeofenceRadiusSlider.addTarget(self, action: #selector(GeofenceRadiusSlider_Changed), for: .valueChanged)
        
        let savedSilderValue = UserDefaults.standard.float(forKey: eUserDefaultKey.MonitoredRadius.rawValue) / 1000
        SetGeofenceRadiusSliderValue(value: savedSilderValue)
        
    }
    func SetGeofenceRadiusSliderValue(value: Float) -> Void{
        GeofenceRadiusSlider.value = value
        switch value {
        case 0:
            lbl_RadiusZero.textColor = UIColor.white
            lbl_RadiusOne.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusTwo.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusThree.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusFour.textColor = UIColor.ColorPaletteTintColor()
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            break
        case 0.5:
            lbl_RadiusOne.textColor = UIColor.white
            lbl_RadiusZero.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusTwo.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusThree.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusFour.textColor = UIColor.ColorPaletteTintColor()
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            break
        case 1.0:
            lbl_RadiusTwo.textColor = UIColor.white
            lbl_RadiusZero.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusOne.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusThree.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusFour.textColor = UIColor.ColorPaletteTintColor()
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
            break
        case 1.5:
            lbl_RadiusThree.textColor = UIColor.white
            lbl_RadiusZero.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusOne.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusTwo.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusFour.textColor = UIColor.ColorPaletteTintColor()
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        case 2.0:
            lbl_RadiusFour.textColor = UIColor.white
            lbl_RadiusZero.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusOne.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusTwo.textColor = UIColor.ColorPaletteTintColor()
            lbl_RadiusThree.textColor = UIColor.ColorPaletteTintColor()
            UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        default:
            break
        }
    }
}
extension SettingsController: GADBannerViewDelegate {
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
