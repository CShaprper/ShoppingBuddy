//
//  ViewController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import MobileCoreServices

class LoginController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, IValidationService, IActivityAnimationService {
    //MARK: - Outlets
    @IBOutlet var BackgroundView: DesignableUIView!
    //Segmented Control
    @IBOutlet var LoginSignUpSegmentedControl: UISegmentedControl!
    //LoginContainer
    @IBOutlet var LoginContainer: UIView!
    @IBOutlet var NicknameContainer: UIView!
    @IBOutlet var txt_Nickname: DesignableTextField!
    @IBOutlet var Textfieldseparator: UIView!
    @IBOutlet var EmailContainer: UIView!
    @IBOutlet var txt_Email: DesignableTextField!
    @IBOutlet var EmailSeperator: UIView!
    @IBOutlet var PasswordContainer: UIView!
    @IBOutlet var txt_Password: DesignableTextField!
    @IBOutlet var ButtonContainer: UIVisualEffectView!
    @IBOutlet var btn_Login: UIButton!
    @IBOutlet var LoginContainerHeight: NSLayoutConstraint!
    @IBOutlet var LoginContainerBackground: UIView!
    @IBOutlet var LoginContainerHolder: UIView!
    @IBOutlet var btn_ResetPassword: UIButton!
    //Activity Indicator
    @IBOutlet var ActivityIndicatior: UIActivityIndicatorView!
    @IBOutlet var LogInLogoImage: UIImageView!
    
    
    //MARK: Member
    var sbUserWebservice:ShoppingBuddyUserWebservice!
    private var BlurrView:UIVisualEffectView?
    
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure View Elements
        ConfigureViewElements()
        
        //Notification Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingBuddyUserLoggedIn), name: NSNotification.Name.ShoppingBuddyUserLoggedIn, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar so it will be there on other view controllers
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sbUserWebservice.AddUserStateListener()
        view.tintColor = UIColor.ColorPaletteSecondDarkest()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    //IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - IShoppingBuddyUserWebservice Implementation
    func FirebaseRequestStarted() { ShowActivityIndicator() }
    func FirebaseRequestFinished() { HideActivityIndicator() }
    func ShoppingBuddyUserLoggedOut() {}
    func ShoppingBuddyUserLoggedIn() {
        performSegue(withIdentifier: String.SegueToDashboardController_Identifier, sender: nil)
    }
    
    
    //MARK: - IShoppingBuddyUserWebservice Impementation
    func ShowActivityIndicator() -> Void {
        if BlurrView == nil{
            BlurrView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            BlurrView!.bounds = view.bounds
            BlurrView!.center = view.center
            view.addSubview(BlurrView!)
            ActivityIndicatior.activityIndicatorViewStyle = .whiteLarge
            
            ActivityIndicatior.color = UIColor.ColorPaletteMiddle()
            ActivityIndicatior.center = view.center
            ActivityIndicatior.transform = CGAffineTransform(scaleX: 2, y: 2)
            BlurrView!.addSubview(ActivityIndicatior)
            ActivityIndicatior.startAnimating()
        }
    }
    func HideActivityIndicator() -> Void {
        if BlurrView != nil{
            BlurrView!.removeFromSuperview()
            BlurrView = nil
            
            ActivityIndicatior.stopAnimating()
            ActivityIndicatior.removeFromSuperview()
        }
    }
    
    
    
    //MARK: - Textfield Delegate implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func txt_Nickname_TetxChanged(sender: DesignableTextField) -> Void {
        let isValid:Bool = ValidationFactory.Validate(type: eValidationType.textField, validationString: sender.text!, alertDelegate: nil)
        txt_Nickname.RightImageVisibility = !isValid
        if isValid == false { txt_Nickname.rightView?.shake() }
        if txt_Nickname.text! == "" { txt_Nickname.RightImageVisibility = false }
    }
    func txt_Email_TextChanged(sender: DesignableTextField) -> Void{
        let isValid:Bool = ValidationFactory.Validate(type: eValidationType.email, validationString: sender.text!, alertDelegate: nil)
        txt_Email.RightImageVisibility = !isValid
        if isValid == false { txt_Email.rightView?.shake() }
        if txt_Email.text! == "" { txt_Email.RightImageVisibility = false }
    }
    func txt_Password_TextChanged(sender: DesignableTextField) -> Void{
        let isValid:Bool = ValidationFactory.Validate(type: eValidationType.password, validationString: sender.text!, alertDelegate: nil)
        txt_Password.RightImageVisibility = !isValid
        if isValid == false { txt_Password.rightView?.shake() }
        if txt_Password.text! == "" { txt_Password.RightImageVisibility = false }
    }
    
    
    //MARK: - Notification Listener targets
    func KeyboardWillShow(sender: Notification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            LoginContainerHolder.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
        }
    }
    func KeyboardWillHide(sender: Notification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            LoginContainerHolder.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
        }
    }
    
    //MARK: - Wired targets
    func LoginSignUpSegmentedControl_Changed(sender: UISegmentedControl) -> Void{
        if sender.selectedSegmentIndex == 0{
            //Hide Nickname Container
            UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.EmailContainer.transform = CGAffineTransform(translationX: 0, y: -self.EmailContainer.frame.size.height)
                self.PasswordContainer.transform = CGAffineTransform(translationX: 0, y: -self.PasswordContainer.frame.size.height)
                self.LoginContainerHeight.constant = 62
                self.LogInLogoImage.image = #imageLiteral(resourceName: "ShoppingBuddy-Logo")
            })
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.NicknameContainer.transform = CGAffineTransform(translationX: 0, y: -self.NicknameContainer.frame.size.height)
                self.NicknameContainer.alpha = 0
            })
                self.LogInLogoImage.alpha = 0
            UIView.animate(withDuration: 0.8, delay: 0, options: .allowUserInteraction, animations: {
                self.LogInLogoImage.alpha = 1
                self.LogInLogoImage.image = #imageLiteral(resourceName: "ShoppingBuddy-Logo")
            })
        } else {
            //Show Nickname Container
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.EmailContainer.transform = .identity
                self.PasswordContainer.transform = .identity
                self.LoginContainerHeight.constant = 93
            })
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .allowUserInteraction, animations: {
                self.NicknameContainer.alpha = 1
                self.NicknameContainer.transform = .identity
            })
            self.LogInLogoImage.alpha = 0
            UIView.animate(withDuration: 0.8, delay: 0, options: .allowUserInteraction, animations: {
                self.LogInLogoImage.alpha = 1
                self.LogInLogoImage.image = #imageLiteral(resourceName: "userPlaceholder")
            })
        }
    }
    func btn_Login_Pressed(sender: UIButton) -> Void{
        var isValid:Bool = false
        switch LoginSignUpSegmentedControl.selectedSegmentIndex {
        case 0:
            isValid = ValidationFactory.Validate(type: eValidationType.email, validationString: txt_Email.text, alertDelegate: self)
            isValid = ValidationFactory.Validate(type: eValidationType.password, validationString: txt_Password.text, alertDelegate: self)
            if isValid{
                sbUserWebservice.LoginFirebaseUser(email: txt_Email.text!, password: txt_Password.text!)
            }
            break
        case 1:
            isValid = ValidationFactory.Validate(type: eValidationType.textField, validationString: txt_Nickname.text, alertDelegate: self)
            isValid = ValidationFactory.Validate(type: eValidationType.email, validationString: txt_Email.text, alertDelegate: self)
            isValid = ValidationFactory.Validate(type: eValidationType.password, validationString: txt_Password.text, alertDelegate: self)
            if isValid{
                sbUserWebservice.CreateNewFirebaseUser(profileImage:LogInLogoImage.image!, nickname: txt_Nickname.text!, email: txt_Email.text!, password: txt_Password.text!)
            }
            break
        default:
            break
        }
    }
    @IBAction func LoginLOGO_Pressed(_ sender: Any) {
        if LoginSignUpSegmentedControl.selectedSegmentIndex == 0 { return }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false { return }
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .photoLibrary
        imgPicker.allowsEditing = true
        imgPicker.delegate = self
        self.present(imgPicker, animated: true, completion: nil)
    }
    func btn_ResetPassword_Pressed(sender: UIButton) -> Void{
        let isValid = ValidationFactory.Validate(type: .email, validationString: txt_Email.text, alertDelegate: self)
        if isValid{
            sbUserWebservice.ResetUserPassword(email: txt_Email.text!)
        }
    }
    
    
    
    func ConfigureViewElements() -> Void{
        //sbUserWebservice
        sbUserWebservice = ShoppingBuddyUserWebservice()
        sbUserWebservice.activityAnimationServiceDelegate = self
        sbUserWebservice.alertMessageDelegate = self
        
        view.tintColor = UIColor.ColorPaletteSecondDarkest()
        
        // BackgroundView Gradient
        BackgroundView.TopColor = UIColor.ColorPaletteSecondBrightest()
        BackgroundView.BottomColor = UIColor.ColorPaletteDarkest()
        
        //LoginContainer
        LoginContainer.clipsToBounds = true
        LoginContainer.layer.cornerRadius = 5
        LoginContainer.layer.borderWidth = 1
        LoginContainer.layer.borderColor = view.tintColor.cgColor
        LoginContainerBackground.layer.cornerRadius = 20
        LoginContainerBackground.alpha = 1
        
        //LoginSignUpSegmentedcontrol
        LoginSignUpSegmentedControl.setTitle(String.LogInSegmentedControll_SegmentOne, forSegmentAt: 0)
        LoginSignUpSegmentedControl.setTitle(String.LogInSegmentedControll_SegmentTwo, forSegmentAt: 1)
        LoginSignUpSegmentedControl.selectedSegmentIndex = 0
        LoginSignUpSegmentedControl.addTarget(self, action: #selector(LoginSignUpSegmentedControl_Changed), for: .valueChanged)
        
        //Textfields appearance
        NicknameContainer.backgroundColor = UIColor.clear
        txt_Nickname.placeholder = String.txt_Nickname_Placeholder
        txt_Nickname.layer.borderColor = UIColor.clear.cgColor
        Textfieldseparator.backgroundColor = view.tintColor
        txt_Nickname.backgroundColor = UIColor.clear
        txt_Nickname.textColor = view.tintColor
        EmailContainer.backgroundColor = UIColor.clear
        txt_Email.placeholder = String.txt_Email_Placeholder
        txt_Email.layer.borderColor = UIColor.clear.cgColor
        EmailSeperator.backgroundColor = view.tintColor
        txt_Email.backgroundColor = UIColor.clear
        txt_Email.textColor = view.tintColor
        PasswordContainer.backgroundColor = UIColor.clear
        txt_Password.placeholder = String.txt_Password_Placeholer
        txt_Password.layer.borderColor = UIColor.clear.cgColor
        txt_Password.backgroundColor = UIColor.clear
        txt_Password.textColor = view.tintColor
        
        //Textfield Targets
        txt_Nickname.addTarget(self, action: #selector(txt_Nickname_TetxChanged), for: .editingChanged)
        txt_Email.addTarget(self, action: #selector(txt_Email_TextChanged), for: .editingChanged)
        txt_Password.addTarget(self, action: #selector(txt_Password_TextChanged), for: .editingChanged)
        
        //Textfield Intitial positions
        NicknameContainer.transform = CGAffineTransform(translationX: 0, y: -NicknameContainer.frame.size.height)
        NicknameContainer.alpha = 0
        EmailContainer.transform = CGAffineTransform(translationX: 0, y: -EmailContainer.frame.size.height)
        PasswordContainer.transform = CGAffineTransform(translationX: 0, y: -PasswordContainer.frame.size.height)
        LoginContainerHeight.constant = 62
        LoginContainerBackground.layer.shadowColor = UIColor.ColorPaletteDarkest().cgColor
        LoginContainerBackground.layer.shadowOffset = CGSize.zero
        LoginContainerBackground.layer.shadowRadius = 10
        LoginContainerBackground.layer.shadowOpacity = 1
        LoginContainerBackground.layer.shadowPath = UIBezierPath(rect: LoginContainerBackground.bounds).cgPath
        LoginContainerBackground.layer.borderColor = UIColor.black.cgColor
        LoginContainerBackground.layer.borderWidth = 2
        
        
        //Reset password Button
        btn_ResetPassword.addTarget(self, action: #selector(btn_ResetPassword_Pressed), for: .touchDown)
        btn_ResetPassword.setTitle(String.LoginResetPassword, for: .normal)
        
        //Login button
        btn_Login.addTarget(self, action: #selector(btn_Login_Pressed), for: .touchUpInside)
        ButtonContainer.clipsToBounds = true
        ButtonContainer.layer.cornerRadius = 25
        ButtonContainer.layer.borderColor = view.tintColor.cgColor
        ButtonContainer.layer.borderWidth = 1
    }
}
//Image Compression
extension UIImage
{
    var highestQualityJPEGNSData: NSData? { return UIImageJPEGRepresentation(self, 1.0)! as NSData }
    var highQualityJPEGNSData: NSData?    { return UIImageJPEGRepresentation(self, 0.75)! as NSData}
    var mediumQualityJPEGNSData: NSData?  { return UIImageJPEGRepresentation(self, 0.5)! as NSData }
    var lowQualityJPEGNSData: NSData?     { return UIImageJPEGRepresentation(self, 0.25)! as NSData}
    var lowestQualityJPEGNSData: NSData?  { return UIImageJPEGRepresentation(self, 0.0)! as NSData }
}
extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            self.LogInLogoImage.image = image
            self.LogInLogoImage.layer.cornerRadius = self.LogInLogoImage.frame.width * 0.5
            self.LogInLogoImage.clipsToBounds = true
        }
        self.dismiss(animated: true, completion: nil)
    }
}
