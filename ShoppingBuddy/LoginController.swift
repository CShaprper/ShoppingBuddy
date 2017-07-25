//
//  ViewController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate, IValidationService, IFirebaseWebService {
    //MARK: - Outlets
    @IBOutlet var BackgroundImage: UIImageView!
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
    
    
    //MARK: Member
    var firebaseWebService:FirebaseWebService!
    
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure View Elements
        ConfigureViewElements()
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
        firebaseWebService.AddUserStateListener()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    
    //IvalidationService implementation
    func ShowValidationAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //IFirebaseWebService Implementation
    func FirebaseRequestStarted() {
        
    }
    func FirebaseRequestFinished() {
        
    }
    func AlertFromFirebaseService(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))        
        present(alert, animated: true, completion: nil)
    }
    
    
    //Textfield Delegate implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func txt_Nickname_TetxChanged(sender: DesignableTextField) -> Void {
        let isValid:Bool = ValidationFactory.Validate(type: eValidationType.textField, validationString: sender.text!, delegate: nil)
        txt_Nickname.RightImageVisibility = !isValid
        if isValid == false { txt_Nickname.rightView?.shake() }
        if txt_Nickname.text! == "" { txt_Nickname.RightImageVisibility = false }
    }
    func txt_Email_TextChanged(sender: DesignableTextField) -> Void{
        let isValid:Bool = ValidationFactory.Validate(type: eValidationType.email, validationString: sender.text!, delegate: nil)
        txt_Email.RightImageVisibility = !isValid
        if isValid == false { txt_Email.rightView?.shake() }
        if txt_Email.text! == "" { txt_Email.RightImageVisibility = false }
    }
    func txt_Password_TextChanged(sender: DesignableTextField) -> Void{
        let isValid:Bool = ValidationFactory.Validate(type: eValidationType.password, validationString: sender.text!, delegate: nil)
        txt_Password.RightImageVisibility = !isValid
        if isValid == false { txt_Password.rightView?.shake() }
        if txt_Password.text! == "" { txt_Password.RightImageVisibility = false }
    }
    
    
    //MARK: - Notification Listener targets
    func SegueToDashBoardController(sender: Notification) -> Void{
        performSegue(withIdentifier: String.SegueToDashboardController_Identifier, sender: nil)
    }
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
            })
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.NicknameContainer.transform = CGAffineTransform(translationX: 0, y: -self.NicknameContainer.frame.size.height)
                self.NicknameContainer.alpha = 0
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
        }
    }
    func btn_Login_Pressed(sender: UIButton) -> Void{
        var isValid:Bool = false
        switch LoginSignUpSegmentedControl.selectedSegmentIndex {
        case 0:
            isValid = ValidationFactory.Validate(type: eValidationType.email, validationString: txt_Email.text, delegate: self)
            isValid = ValidationFactory.Validate(type: eValidationType.password, validationString: txt_Password.text, delegate: self)
            if isValid{
                firebaseWebService.LoginFirebaseUser(email: txt_Email.text!, password: txt_Password.text!)
            }
            break
        case 1:
            isValid = ValidationFactory.Validate(type: eValidationType.textField, validationString: txt_Nickname.text, delegate: self)
            isValid = ValidationFactory.Validate(type: eValidationType.email, validationString: txt_Email.text, delegate: self)
            isValid = ValidationFactory.Validate(type: eValidationType.password, validationString: txt_Password.text, delegate: self)
            if isValid{
                firebaseWebService.CreateNewFirebaseUser(nickname: txt_Nickname.text!, email: txt_Email.text!, password: txt_Password.text!)
            }
            break
        default:
            break
        }
    }
    func btn_ResetPassword_Pressed(sender: UIButton) -> Void{
      let isValid = ValidationFactory.Validate(type: .email, validationString: txt_Email.text, delegate: self)
        if isValid{
            firebaseWebService.ResetUserPassword(email: txt_Email.text!)
        }
    }
    
    
    //MARK: - Helper Functions
    func ConfigureViewElements() -> Void{
        //FirebaseWbservice
        firebaseWebService = FirebaseWebService()
        firebaseWebService.delegate = self
        
        //Notification listener
        NotificationCenter.default.addObserver(self, selector: #selector(SegueToDashBoardController), name: NSNotification.Name.SegueToDashboardController, object: nil)
        //BackgroundImage
        BackgroundImage.alpha = 1
        
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
        
        //Reset password Button
        btn_ResetPassword.addTarget(self, action: #selector(btn_ResetPassword_Pressed), for: .touchDown)
        btn_ResetPassword.setTitle(String.LoginResetPassword, for: .normal)
        
        //Login button
        btn_Login.addTarget(self, action: #selector(btn_Login_Pressed), for: .touchUpInside)
        ButtonContainer.clipsToBounds = true
        ButtonContainer.layer.cornerRadius = 25
        ButtonContainer.layer.borderColor = view.tintColor.cgColor
        ButtonContainer.layer.borderWidth = 1
        
        //Notification Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
}

