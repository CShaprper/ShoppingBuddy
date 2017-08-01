//
//  StoresController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class StoresController: UIViewController, UITextFieldDelegate, IValidationService, IFirebaseWebService{
    //MARK: - Outlets
    @IBOutlet var BackgroundView: DesignableUIView!
    @IBOutlet var StoresTableView: UITableView!
    @IBOutlet var AddStoreButton: UIBarButtonItem!
    //Add Store PopUp
    @IBOutlet var AddStorePopUpLogo: UIImageView!
    @IBOutlet var AddStorePopUp: UIView!
    @IBOutlet var txt_AddStore: UITextField!
    @IBOutlet var btn_SaveStore: UIButton!
    
    
    
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
            AddStorePopUp.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
        }
    }
    func KeyboardWillHide(sender: Notification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            AddStorePopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
        }
    }
    
    //MARK: IValidationService implementation
    func ShowValidationAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestStarted() {}
    func FirebaseRequestFinished() {
        HideAddStorePopUp()
        StoresTableView.reloadData()
    }
    func FirebaseUserLoggedIn() {}
    func FirebaseUserLoggedOut() {}
    func AlertFromFirebaseService(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Wired actions
    func BlurrViewTapped(sender: UITapGestureRecognizer) -> Void {
        HideAddStorePopUp()
    }
    @IBAction func AddStoreButton_Pressed(_ sender: Any) {
        ShowAddStorePopUp()
    }
    func btn_SaveStore_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_AddStore.text, delegate: self)
        if isValid {
            firebaseWebService.SaveStoreToFirebaseDatabase(storeName: txt_AddStore.text!)
        }
    }
    
    //MARK: - Helper Functions
    func ShowAddStorePopUp() -> Void {
        if blurrView == nil{
            blurrView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blurrView.bounds = view.bounds
            blurrView.center = view.center
            view.addSubview(blurrView)
            //BlurrView Target
            let blurrViewTap = UITapGestureRecognizer(target: self, action: #selector(BlurrViewTapped))
            blurrView.addGestureRecognizer(blurrViewTap)
            AddStorePopUp.frame.size.width = view.frame.width * 0.8
            AddStorePopUp.center = view.center
            AddStorePopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
            view.addSubview(AddStorePopUp)
        }
    }
    func HideAddStorePopUp() -> Void{
        if blurrView != nil{
            blurrView.removeFromSuperview()
            AddStorePopUp.removeFromSuperview()
            blurrView = nil
        }
    }
    func ConfigureView() -> Void{
        //FirebaseWebService
        firebaseWebService = FirebaseWebService()
        firebaseWebService.delegate = self
        
        //Set Navigation Bar Title
        navigationItem.title = String.SettingsControllerTitle
        
        //Set TabBarItem Title
        tabBarItem.title = String.SettingsControllerTitle   
        
        //AddStore PopUp
        txt_AddStore.layer.borderWidth = 2
        txt_AddStore.layer.borderColor = UIColor.ColorPaletteSecondDarkest().cgColor
        txt_AddStore.textColor = UIColor.ColorPaletteSecondDarkest()
        txt_AddStore.layer.cornerRadius = 10
        txt_AddStore.placeholder = String.txt_AddStore_Placeholder
        
        //btn_SaveStore
        btn_SaveStore.tintColor = UIColor.ColorPaletteSecondDarkest()
        btn_SaveStore.addTarget(self, action: #selector(btn_SaveStore_Pressed), for: .touchUpInside)
        
        //Notification Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        //Stores TableView
        StoresTableView.tintColor = UIColor.ColorPaletteTintColor()
        StoresTableView.reloadData()
    }
}
extension StoresController: UITableViewDelegate, UITableViewDataSource{
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return StoresArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.StoreCell_Identifier, for: indexPath) as! StoreCell
        if StoresArray.count > 0{
            let store = StoresArray[indexPath.row]
            cell.ConfigureCell(store: store)
        }
        return cell
    }
    // conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            firebaseWebService.DeleteStoreFromFirebase(idToDelete: StoresArray[indexPath.row].ID!)
            StoresArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    /*
     // rearranging the table view.
     func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // conditional rearranging of the table view.
     func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
