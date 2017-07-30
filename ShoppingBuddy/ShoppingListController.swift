//
//  ShoppingListController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ShoppingListController: UIViewController, IFirebaseWebService, IValidationService, UIGestureRecognizerDelegate, UITextFieldDelegate {
    //MARK: - Outlets
    @IBOutlet var btn_AddList: UIBarButtonItem!
    @IBOutlet var ShoppingListDetailView: UIView!
    @IBOutlet var ListDetailBackgroundImage: UIImageView!
    //ShoppingListCollectionView
    @IBOutlet var ShoppingListCollectionView: UICollectionView!
    @IBOutlet var ShoppingListCollectionViewBackground: DesignableUIView!
    
    //List Detail PopUp
    @IBOutlet var btn_CloseListDetailView: UIButton!
    @IBOutlet var btn_AddListItem: UIButton!
    @IBOutlet var lbl_ShoppingListDetailTitle: UILabel!
    
    //DetailViewTableView
    @IBOutlet var ShoppingListDetailTableView: UITableView!
    @IBOutlet var CustomRefreshView: UIView!
    @IBOutlet var CustomRefreshControlImage: UIImageView!
    @IBOutlet var CustomAddShoppingListRefreshControl: UIView!
    @IBOutlet var CustomAddShoppingListRefreshControlImage: UIImageView!
    
    //Add Shopping List PopUp
    @IBOutlet var AddShoppingListPopUp: UIView!
    @IBOutlet var AddShoppingListPopUpBackground: DesignableUIView!
    @IBOutlet var lbl_ListName: UITextField!
    @IBOutlet var btn_SaveList: UIButton!
    @IBOutlet var txt_ListName: UITextField!
    @IBOutlet var txt_RelatedStore: UITextField!
    
    //Add Item PopUp
    @IBOutlet var AddItemPopUp: UIView!
    @IBOutlet var AddItemPopUpBackground: DesignableUIView!
    @IBOutlet var txt_ItemName: UITextField!
    @IBOutlet var btn_SaveItem: UIButton!
    @IBOutlet var ShoppingCartImage: UIImageView!
    
    
    
    //MARK:- Member
    var blurrView:UIVisualEffectView?
    var addItemBlurrView:UIVisualEffectView?
    var firebaseWebService:FirebaseWebService!
    var SelectedList:ShoppingList?
    var refreshControl:UIRefreshControl!
    var refreshShoppingListControl:UIRefreshControl!
    var checkedIndex:Int!
    var panRecognizer:UIPanGestureRecognizer!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ShoppingListCollectionView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestStarted() { }
    func FirebaseRequestFinished() {
        ShoppingListCollectionView.reloadData()
        FilterShoppingListTotalItemsArray()
        SortShoppingListItemsArrayBy_isSelected()
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
        ShowListDetailView()
    }
    func BlurrView_Tapped(sender: UITapGestureRecognizer) -> Void {
        HideAddListPopUp()
        ShoppingListDetailView.removeFromSuperview()
    }
    func btn_SaveList_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ListName.text, delegate: self)
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_RelatedStore.text, delegate: self)
        if isValid{
            HideAddListPopUp()
            firebaseWebService.SaveListToFirebaseDatabase(listName: txt_ListName.text!, relatedStore: txt_RelatedStore.text!)
        }
    }
    func btn_AddListItem_Pressed(sender: UIButton) -> Void {
        ShowAddItemPopUp()
    }
    func btn_CloseListDetailView_Pressed(sender: UIButton) -> Void {
        HideBlurrView()
        HideListDetailView()
        ShoppingListDetailView.removeFromSuperview()
    }
    func AddItemBlurrView_Tapped(sender: UITapGestureRecognizer) -> Void {
        addItemBlurrView?.removeFromSuperview()
        addItemBlurrView = nil
        HideAddListPopUp()
    }
    func AddItemPopUp_OutsideTouch(sender: UITapGestureRecognizer) -> Void {
        if view.subviews.contains(AddItemPopUp){
            AddItemPopUp.removeFromSuperview()
        }
    }
    func AddShoppingListPopUp_OutsideTouch(sender: UITapGestureRecognizer) -> Void {
        if view.subviews.contains(AddShoppingListPopUp){
            AddShoppingListPopUp.removeFromSuperview()
        }
    }
    func btn_SaveItem_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ItemName.text, delegate: self)
        if isValid{
            HideAddItemPopUp()
            firebaseWebService.SaveListItemToFirebaseDatabase(shoppingListID: SelectedList!.ID!, itemName: txt_ItemName.text!)
        }
    }
    func HandleShoppingItemPan(sender: UIPanGestureRecognizer) -> Void {
        let swipeLocation = panRecognizer.location(in: self.ShoppingListDetailTableView)
        if let swipedIndexPath = ShoppingListDetailTableView.indexPathForRow(at: swipeLocation) {
            if let swipedCell = self.ShoppingListDetailTableView.cellForRow(at: swipedIndexPath) {              
                let point = sender.translation(in: ShoppingListDetailTableView)
                let xFromCenter = swipedCell.center.x - view.center.x
                let degree:Double = Double(xFromCenter / view.frame.size.width * 0.1)
                swipedCell.transform = CGAffineTransform(translationX: point.x, y: 0).rotated(by: degree.degreesToRadians)
                swipedCell.transform = CGAffineTransform(translationX: point.x, y: 0).rotated(by: degree.degreesToRadians)
                
                
                let swipeLimitLeft = ShoppingListDetailTableView.frame.width * 0.4
                let swipeLimitRight = ShoppingListDetailTableView.frame.width * 0.6
                view.bringSubview(toFront: ShoppingCartImage)
                ShoppingCartImage.alpha =  swipedCell.center.x < swipeLimitLeft ? 0 : 1
                
                if panRecognizer.state == UIGestureRecognizerState.ended {
                    if swipedCell.center.x > swipeLimitLeft{
                        //Drop to cart
                        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                            swipedCell.transform = CGAffineTransform(rotationAngle: Double(-90).degreesToRadians)
                            swipedCell.transform = CGAffineTransform.init(translationX: 0, y: 300)
                        }, completion: { (true) in
                            self.ShoppingCartImage.shakeAndHide()          
                        })
                        return
                    } else if swipedCell.center.x > swipeLimitRight{
                        //Drop to trash
                        return
                    } else {
                    ShoppingCartImage.alpha = 0
                    swipedCell.transform = .identity
                    }
                }
            }
        }
    }
    
    //MARK: - Textfield Delegate implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    //MARK: Keyboard Notification Listener targets
    func KeyboardWillShow(sender: Notification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            AddItemPopUp.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
            AddShoppingListPopUp.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
        }
    }
    func KeyboardWillHide(sender: Notification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            AddItemPopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
            AddShoppingListPopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
        }
    }
    
    //MARK: - Helper Functions
    func ShowAddShoppingListPopUp() -> Void {
        if view.subviews.contains(AddShoppingListPopUp){
            refreshShoppingListControl.endRefreshing()
            return
        }
        AddShoppingListPopUp.frame.size.width = 280
        AddShoppingListPopUp.center = view.center
        view.addSubview(AddShoppingListPopUp)
        AddShoppingListPopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
        refreshShoppingListControl.endRefreshing()
    }
    func ShowAddItemPopUp() -> Void{
        if view.subviews.contains(AddItemPopUp){
            refreshControl.endRefreshing()
            return
        }
        AddItemPopUp.frame.size.width = 280
        AddItemPopUp.center = view.center
        view.addSubview(AddItemPopUp)
        AddItemPopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
        refreshControl.endRefreshing()
    }
    func ShowBlurrView() -> Bool{
        if blurrView == nil{
            blurrView = UIVisualEffectView()
            blurrView!.effect = UIBlurEffect(style: .light)
            blurrView!.bounds = view.bounds
            blurrView!.center = view.center
            let blurrViewTap = UITapGestureRecognizer(target: self, action: #selector(BlurrView_Tapped))
            blurrView!.addGestureRecognizer(blurrViewTap)
            view.addSubview(blurrView!)
            return true
        }
        return false
    }
    func HideListDetailView() -> Void{
        SelectedList = nil
        AddShoppingListPopUp.removeFromSuperview()
    }
    func HideAddListPopUp() -> Void {
        HideBlurrView()
        HideListDetailView()
    }
    func HideAddItemPopUp() -> Void {
        AddItemPopUp.removeFromSuperview()
    }
    func HideBlurrView() -> Void{
        blurrView?.removeFromSuperview()
        blurrView = nil
    }
    func ShowListDetailView(){
        if ShowBlurrView(){
            btn_SaveList.alpha = SelectedList != nil ? 0 : 1
            ShoppingListDetailView.frame.size.width = view.frame.width * 0.9
            ShoppingListDetailView.frame.size.height = view.frame.height * 0.8
            ShoppingListDetailView.center = view.center
            lbl_ShoppingListDetailTitle.text = (SelectedList != nil && SelectedList?.Name != nil) ? SelectedList?.Name! : ""
            view.addSubview(ShoppingListDetailView)
            FilterShoppingListTotalItemsArray()
            SortShoppingListItemsArrayBy_isSelected()
        }
    }
    func FilterShoppingListTotalItemsArray(){
        ShoppingListDetailItemsArray = ShoppingListTotalItemsArray.filter({$0.ShoppingListID == SelectedList!.ID!})
    }
    func SortShoppingListItemsArrayBy_isSelected() -> Void {
        if ShoppingListDetailItemsArray.count > 0{
            ShoppingListDetailItemsArray = ShoppingListDetailItemsArray.sorted {return $0.isSelected! < $1.isSelected!}
            ShoppingListDetailTableView.reloadData()
        }
    }
    func ConfigureView() -> Void {
        //FirebaseWebservice
        firebaseWebService = FirebaseWebService()
        firebaseWebService.delegate = self
        
        //RefreshControl AddListItem
        refreshControl = UIRefreshControl()
        CustomRefreshView.frame.size.width = 150
        CustomRefreshView.frame.size.height = 45
        CustomRefreshView.center.x = refreshControl.center.x
        CustomRefreshControlImage.image = UIImage(named: String.CustomRefreshControlImage)
        refreshControl.addSubview(CustomRefreshView)
        refreshControl.addTarget(self, action: #selector(ShoppingListController.ShowAddItemPopUp), for: UIControlEvents.allEvents)
        
        //RefreshControl Add Shopping List
        refreshShoppingListControl = UIRefreshControl()
        CustomAddShoppingListRefreshControl.frame.size.width = 150
        CustomAddShoppingListRefreshControl.frame.size.height = 40
        CustomAddShoppingListRefreshControl.center.x = refreshShoppingListControl.center.x
        CustomAddShoppingListRefreshControlImage.image = UIImage(named: String.CustomAddShoppingListRefreshControlImage)
        refreshShoppingListControl.addSubview(CustomAddShoppingListRefreshControl)
        refreshShoppingListControl.addTarget(self, action: #selector(ShoppingListController.ShowAddShoppingListPopUp), for: .allEvents)
        
        if #available(iOS 10.0, *){
            ShoppingListDetailTableView.refreshControl = refreshControl
            ShoppingListCollectionView.refreshControl = refreshShoppingListControl
        } else {
            ShoppingListDetailTableView.addSubview(refreshControl)
            ShoppingListCollectionView.addSubview(refreshShoppingListControl)
        }
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(HandleShoppingItemPan))
        ShoppingListDetailTableView.addGestureRecognizer(panRecognizer)
        
        //SetNavigationBar Title
        navigationItem.title = String.ShoppingListControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.ShoppingListControllerTitle
        
        //Notification Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        //Add Shopping List PopUp
        AddShoppingListPopUpBackground.layer.borderWidth = 2
        AddShoppingListPopUpBackground.layer.borderColor = UIColor.black.cgColor
        txt_RelatedStore.delegate = self
        txt_RelatedStore.placeholder = String.txt_RelatedStore_Placeholder
        txt_RelatedStore.textColor = UIColor.ColorPaletteSecondDarkest()
        txt_ListName.delegate = self
        txt_ListName.placeholder = String.txt_ListName_Placeholder
        txt_ListName.textColor = UIColor.ColorPaletteSecondDarkest()
        btn_SaveList.addTarget(self, action: #selector(btn_SaveList_Pressed), for: .touchUpInside)
        let addShoppingListOutsideTap =  UITapGestureRecognizer(target: self, action: #selector(AddShoppingListPopUp_OutsideTouch))
        AddShoppingListPopUp.addGestureRecognizer(addShoppingListOutsideTap)
        
        //Detail ListView
        btn_AddListItem.addTarget(self, action: #selector(btn_AddListItem_Pressed), for: .touchUpInside)
        btn_CloseListDetailView.addTarget(self, action: #selector(btn_CloseListDetailView_Pressed), for: .touchUpInside)
        
        //Add Item PopUp
        AddItemPopUpBackground.layer.borderWidth = 2
        AddItemPopUpBackground.layer.borderColor = UIColor.black.cgColor
        txt_ItemName.delegate = self
        txt_ItemName.placeholder = String.txt_ItemName_Placeholer
        txt_ItemName.textColor = UIColor.ColorPaletteSecondDarkest()
        btn_SaveItem.addTarget(self, action: #selector(btn_SaveItem_Pressed), for: .touchUpInside)
        let outsideAddItemPopUpTouch = UITapGestureRecognizer(target: self, action: #selector(AddItemPopUp_OutsideTouch))
        ShoppingListDetailView.addGestureRecognizer(outsideAddItemPopUpTouch)
        AddItemPopUp.addGestureRecognizer(outsideAddItemPopUpTouch)
        
        ShoppingCartImage.alpha = 0
    }
}
extension Double {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}
extension ShoppingListController:UICollectionViewDelegate, UICollectionViewDataSource{
    // MARK:- UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShoppingListsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.ShoppingListCollectionViewCell_Identifier, for: indexPath) as! ShoppingListCollectionViewCell
        cell.isHighlighted = false
        if ShoppingListsArray.count > 0{
            cell.ConfigureCell(shoppingList: ShoppingListsArray[indexPath.row])
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SelectedList = ShoppingListsArray[indexPath.row]
        ShowListDetailView()
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
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ShoppingListDetailItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.ShoppingListItemTableViewCell_Identifier, for: indexPath) as! ShoppingListItemTableViewCell
        if ShoppingListDetailItemsArray.count > 0 {
            cell.ConfigureCell(shoppingListItem: ShoppingListDetailItemsArray[indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkedIndex = indexPath.row
        if ShoppingListDetailItemsArray.count > 0 {
            ShoppingListDetailItemsArray[indexPath.row].isSelected = ShoppingListDetailItemsArray[indexPath.row].isSelected == "false" ? "true" : "false"
            firebaseWebService.EditIsSelectedOnShoppingListItem(shoppingListItem: ShoppingListDetailItemsArray[indexPath.row])
            ShoppingListDetailItemsArray = ShoppingListDetailItemsArray.sorted {return $0.isSelected! < $1.isSelected!}
            ShoppingListDetailTableView.reloadData()
        }
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
     // conditional rearranging of the table view.
     func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}
