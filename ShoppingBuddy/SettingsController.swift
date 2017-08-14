//
//  StoresController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class SettingsController: UIViewController, UITextFieldDelegate, IValidationService, IFirebaseWebService{
    //MARK: - Outlets
    @IBOutlet var BackgroundView: UIImageView!
    @IBOutlet var GeofenceRadiusSlider: UISlider!
    @IBOutlet var lbl_RadiusZero: UILabel!
    @IBOutlet var lbl_RadiusOne: UILabel!
    @IBOutlet var lbl_RadiusTwo: UILabel!
    @IBOutlet var lbl_RadiusThree: UILabel!
    @IBOutlet var lbl_RadiusFour: UILabel!
    
    
    
    //MARK: - Member
    var firebaseWebService:FirebaseWebService!
    var blurrView:UIVisualEffectView!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
        
        GeofenceRadiusSlider.addTarget(self, action: #selector(GeofenceRadiusSlider_Changed), for: .valueChanged)
        
        let savedSilderValue = UserDefaults.standard.float(forKey: eUserDefaultKey.MonitoredRadius.rawValue) / 1000
        SetGeofenceRadiusSliderValue(value: savedSilderValue)
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
    //MARK: Keyboard Notification Listener targets
    func KeyboardWillShow(sender: Notification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            // AddStorePopUp.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
        }
    }
    func KeyboardWillHide(sender: Notification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            // AddStorePopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
        }
    }
    
    //MARK: IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestStarted() {}
    func FirebaseRequestFinished() {}
    func FirebaseUserLoggedIn() {}
    func FirebaseUserLoggedOut() {}
    
    //MARK: - Wired actions
    func GeofenceRadiusSlider_Changed(sender: UISlider) -> Void {
        let value = roundf(sender.value * 2) / 2
        print(value)
        GeofenceRadiusSlider.value = value
        SetGeofenceRadiusSliderValue(value: value)
        UserDefaults.standard.set(value * 1000, forKey: eUserDefaultKey.MonitoredRadius.rawValue)
    }
    
    //MARK: - Helper Functions
    func ConfigureView() -> Void{
        //FirebaseWebService
        firebaseWebService = FirebaseWebService()
        firebaseWebService.firebaseWebServiceDelegate = self
        firebaseWebService.alertMessageDelegate = self
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

