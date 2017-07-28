//
//  ShoppingListController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ShoppingListController: UIViewController, IFirebaseWebService, IValidationService, UITextFieldDelegate {
    //MARK: - Outlets
    @IBOutlet var btn_AddList: UIBarButtonItem!
    @IBOutlet var ListDetailView: UIView!
    @IBOutlet var ListDetailBackgroundImage: UIImageView!
    //ShoppingListCollectionView
    @IBOutlet var ShoppingListCollectionView: UICollectionView!
    //DetailViewTableView
    @IBOutlet var ListDetailTableView: UITableView!
    //Add Shopping List PopUp
    @IBOutlet var AddShoppingListPopUp: UIView!
    @IBOutlet var lbl_ListName: UITextField!
    @IBOutlet var btn_SaveList: UIButton!
    @IBOutlet var txt_ListName: UITextField!
    
    //MARK:- Member
    var blurrView:UIVisualEffectView?
    var firebaseWebService:FirebaseWebService!
    var SelectedList:ShoppingList?
    
    
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //FirebaseWebservice
        firebaseWebService = FirebaseWebService()
        firebaseWebService.delegate = self
        
        //SetNavigationBar Title
        navigationItem.title = String.ShoppingListControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.ShoppingListControllerTitle
        
        //Notification Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        //btn_SaveShoppingList
        btn_SaveList.addTarget(self, action: #selector(btn_SaveList_Pressed), for: .touchUpInside)
        txt_ListName.delegate = self
        
        ShoppingListCollectionView.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestStarted() { }
    func FirebaseRequestFinished() {
        ShoppingListCollectionView.reloadData()
    }
    func FirebaseUserLoggedIn() { }
    func FirebaseUserLoggedOut() { }
    func AlertFromFirebaseService(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - IValidationService implementation
    func ShowValidationAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Wired Actions
    @IBAction func btn_AddList_Pressed(_ sender: UIBarButtonItem) {
        ShowAddListPopUp()
    }
    func BlurrView_Tapped(sender: UITapGestureRecognizer) -> Void {
        HideAddListPopUp()
    }
    func btn_SaveList_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ListName.text, delegate: self)
        if isValid{
            firebaseWebService.SaveListTiForebaseDatabase(listName: txt_ListName.text!)
        }
    }
    
    //MARK: - Notification Listener targets
    func KeyboardWillShow(sender: Notification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            AddShoppingListPopUp.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
        }
    }
    func KeyboardWillHide(sender: Notification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            AddShoppingListPopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
        }
    }
    
    //MARK: - Helper Functions
    func ShowAddListPopUp() -> Void {
        if blurrView == nil{
            blurrView = UIVisualEffectView()
            blurrView!.effect = UIBlurEffect(style: .light)
            blurrView!.bounds = view.bounds
            blurrView!.center = view.center
            let blurrViewTap = UITapGestureRecognizer(target: self, action: #selector(BlurrView_Tapped))
            blurrView!.addGestureRecognizer(blurrViewTap)
            view.addSubview(blurrView!)
            
            AddShoppingListPopUp.frame.size.width = view.frame.width * 0.8
            AddShoppingListPopUp.center = view.center
            view.addSubview(AddShoppingListPopUp)
            AddShoppingListPopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
        }
    }
    func HideAddListPopUp() -> Void {
        if blurrView != nil{
            blurrView?.removeFromSuperview()
            blurrView = nil
            AddShoppingListPopUp.removeFromSuperview()
        }
    }
}
extension ShoppingListController:UICollectionViewDelegate, UICollectionViewDataSource{
    // MARK:- UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShoppingListsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.ShoppingListCollectionViewCell_Identifier, for: indexPath) as! ShoppingListCollectionViewCell
        if ShoppingListsArray.count > 0{
            //Configure Cell
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SelectedList = ShoppingListsArray[indexPath.row]
        ListDetailView.frame.size.width = view.frame.width * 0.9
        ListDetailView.frame.size.height = view.frame.height * 0.9
        ListDetailView.center = view.center
        view.addSubview(ListDetailView)
    }
    
    // MARK: UICollectionViewDelegate
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    /*
     func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }*/
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
}

extension ShoppingListController: UITableViewDelegate, UITableViewDataSource{
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ShoppingListDetailsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.ShoppingListItemTableViewCell_Identifier, for: indexPath) as! ShoppingListItemTableViewCell
        if ShoppingListDetailsArray.count > 0 {
            cell.ConfigureCell(shoppingList: ShoppingListsArray[indexPath.row])
        }
        return cell
    }
    /*
     // conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
}
