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
    
    
    
    //MARK: - Member
    var firebaseWebService:FirebaseWebService!
    var blurrView:UIVisualEffectView!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
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

    
    //MARK: - Helper Functions
    func ConfigureView() -> Void{
        //FirebaseWebService
        firebaseWebService = FirebaseWebService()
        firebaseWebService.firebaseWebServiceDelegate = self
        firebaseWebService.alertMessageDelegate = self
    }
}

