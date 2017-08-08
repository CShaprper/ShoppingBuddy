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
    @IBOutlet var BackgroundImage: UIImageView!
    @IBOutlet var ShoppingListDetailView: UIView!
    @IBOutlet var ListDetailBackgroundImage: UIImageView!
    //ShoppingListCollectionView
    @IBOutlet var ShoppingListCollectionView: UICollectionView!
    
    //List Detail PopUp
    @IBOutlet var btn_CloseListDetailView: UIButton!
    @IBOutlet var lbl_ShoppingListDetailTitle: UILabel!
    
    //DetailViewTableView
    @IBOutlet var ShoppingListDetailTableView: UITableView!
    @IBOutlet var CustomRefreshView: UIView!
    @IBOutlet var CustomRefreshControlImage: UIImageView!
    @IBOutlet var CustomAddShoppingListRefreshControl: UIView!
    @IBOutlet var CustomAddShoppingListRefreshControlImage: UIImageView!
    @IBOutlet var DetailTableViewBottomConstraint: NSLayoutConstraint!
    
    //Add Shopping List PopUp
    @IBOutlet var AddShoppingListPopUp: UIView!
    @IBOutlet var AddShoppingListPopUpRoundView: DesignableUIView!
    @IBOutlet var AddShoppingListPopUpBackground: DesignableUIView!
    @IBOutlet var btn_SaveList: UIButton!
    @IBOutlet var txt_ListName: UITextField!
    @IBOutlet var txt_RelatedStore: UITextField!
    @IBOutlet var lbl_AddListPopUpTitle: UILabel!
    @IBOutlet var btn_DeleteList: UIButton!
    
    //Add Item PopUp
    @IBOutlet var AddItemPopUp: UIView!
    @IBOutlet var AddItemPopUpBackground: DesignableUIView!
    @IBOutlet var txt_ItemName: UITextField!
    @IBOutlet var btn_SaveItem: UIButton!
    @IBOutlet var lbl_AddItemPopUpTitle: UILabel!
    
    //Shopping cart and Trash
    @IBOutlet var ShoppingCartImage: UIImageView!
    @IBOutlet var TrashImage: UIImageView!
    
    
    
    
    //MARK:- Member
    var collectionViewItemsPerRow:CGFloat = 2
    let collectionViewSectionsInsets:UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    var blurrView:UIVisualEffectView?
    var firebaseWebService:FirebaseWebService!
    var SelectedList:ShoppingList?
    var refreshControl:UIRefreshControl!
    var refreshShoppingListControl:UIRefreshControl!
    var swipedCellIndex:Int!
    var panRecognizer:UIPanGestureRecognizer!
    var LongPressShoppingList:UILongPressGestureRecognizer!
    
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
        ShoppingListDetailTableView.reloadData()
    }
    func FirebaseUserLoggedIn() { }
    func FirebaseUserLoggedOut() { }
    func AlertFromFirebaseService(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Wired Actions
    func BlurrView_Tapped(sender: UITapGestureRecognizer) -> Void {
        HideAddListPopUp()
        ShoppingListDetailView.removeFromSuperview()
    }
    func btn_SaveList_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ListName.text, alertDelegate: self)
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_RelatedStore.text, alertDelegate: self)
        if isValid{
            firebaseWebService.SaveListToFirebaseDatabase(listName: txt_ListName.text!, relatedStore: txt_RelatedStore.text!)
            HideAddListPopUp()
        }
    }
    func btn_CloseListDetailView_Pressed(sender: UIButton) -> Void {
        HideBlurrView()
        HideListDetailView()
        HideAddItemPopUp()
        ShoppingListCollectionView.reloadData()
    }
    func AddItemBlurrView_Tapped(sender: UITapGestureRecognizer) -> Void {
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
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ItemName.text, alertDelegate: self)
        if isValid{
            firebaseWebService.SaveListItemToFirebaseDatabase(shoppingListID: SelectedList!.ID!, itemName: txt_ItemName.text!)
            HideAddItemPopUp()
        }
    }
    func btn_DeleteList_Pressed(sender: UIButton) -> Void {
        if SelectedList != nil{
            firebaseWebService.DeleteShoppingListFromFirebase(listToDelete: SelectedList!)
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: view)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    func HandleShoppingItemPan(sender: UIPanGestureRecognizer) -> Void {
        let swipeLocation = panRecognizer.location(in: self.ShoppingListDetailTableView)
        if let swipedIndexPath = ShoppingListDetailTableView.indexPathForRow(at: swipeLocation) {
            if let swipedCell = self.ShoppingListDetailTableView.cellForRow(at: swipedIndexPath) {
                
                //remember the index of the swiped cell to reset after animation
                swipedCellIndex = swipedIndexPath.row
                
                //velocity can detect direction of movement
                let velocity = panRecognizer.velocity(in: ShoppingListDetailTableView)
                
                //Get swiped item isSelected value
                let isSelected = SelectedList!.ItemsArray![self.swipedCellIndex].isSelected
                
                //translation of thumb in view
                let point = sender.translation(in: ShoppingListDetailTableView)
                
                //percent of movement according the view size
                let xPercentFromCenter = point.x / view.center.x
                
                //calculate distance to drop item
                let dropHeight = (ShoppingListDetailTableView.frame.height - swipeLocation.y) * 1.5
                
                let rightDropLimit:CGFloat = 0.9
                let leftDropLimit:CGFloat = 0.25
                
                if abs(xPercentFromCenter) < rightDropLimit && velocity.x > 0{
                    swipedCell.transform = CGAffineTransform(translationX: point.x, y: 0)
                }
                
                //Stop translation of cell at 25% movement over view
                //&& allow swipe left only on unselected items
                if abs(xPercentFromCenter) < leftDropLimit && velocity.x < 0 && isSelected! == "false"{
                    swipedCell.transform = CGAffineTransform(translationX: point.x, y: 0)
                }
                
                print(xPercentFromCenter)
                //Shopping cart image should bo on top
                view.bringSubview(toFront: ShoppingCartImage)
                ShoppingCartImage.alpha =  xPercentFromCenter < -0.25 && isSelected! == "false" ? 1 : 0
                
                //Trash can image should bo on top
                view.bringSubview(toFront: TrashImage)
                TrashImage.alpha =  xPercentFromCenter > rightDropLimit ? 1 : 0
                
                //Perform animations on gesture .ended state
                if panRecognizer.state == UIGestureRecognizerState.ended {
                    if xPercentFromCenter <= -0.25 && isSelected! == "false"{
                        //Shake Cart
                        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                            self.ShoppingCartImage.transform = CGAffineTransform(translationX: 20, y: 0)
                        })
                        //Drop item to cart
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                            swipedCell.transform = CGAffineTransform.init(translationX: -(self.view.frame.width * 0.35), y: dropHeight).rotated(by: -45).scaledBy(x: 0.3, y: 0.3)
                        }, completion: { (true) in
                            self.ShoppingCartImage.alpha = 0
                            self.ShoppingCartImage.transform = .identity
                            swipedCell.transform = .identity
                            if let index = ShoppingListsArray.index(where: {$0.ID == self.SelectedList!.ID!}){
                                if ShoppingListsArray[index].ItemsArray!.count > self.swipedCellIndex{
                                    ShoppingListsArray[index].ItemsArray![self.swipedCellIndex].isSelected = "true"
                                    //Edit isSelected in Firebase
                                    self.firebaseWebService.EditIsSelectedOnShoppingListItem(shoppingListItem: ShoppingListsArray[index].ItemsArray![self.swipedCellIndex])
                                    self.SortShoppingListItemsArrayBy_isSelected()
                                }
                            }
                        })
                        return
                    }
                    else if xPercentFromCenter >= 0.75{
                        //Shake Trash
                        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                            self.TrashImage.transform = CGAffineTransform(translationX: -20, y: 0)
                        })
                        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                            swipedCell.transform = CGAffineTransform.init(translationX: self.view.frame.width * 0.8, y: dropHeight).rotated(by: 45).scaledBy(x: 0.3, y: 0.3)
                        }, completion: { (true) in
                            self.TrashImage.alpha = 0
                            self.TrashImage.transform = .identity
                            swipedCell.alpha = 0
                            swipedCell.transform = .identity
                            
                            if self.SelectedList != nil{
                                if let index = ShoppingListsArray.index(where: {$0.ID == self.SelectedList!.ID!}){
                                    if ShoppingListsArray[index].ItemsArray!.count > self.swipedCellIndex{
                                        self.firebaseWebService.DeleteShoppingListItemFromFirebase(itemToDelete: ShoppingListsArray[index].ItemsArray![self.swipedCellIndex])
                                        ShoppingListsArray[index].ItemsArray!.remove(at: self.swipedCellIndex)
                                        self.ShoppingListDetailTableView.deleteRows(at: [swipedIndexPath], with: .none)
                                    }
                                }
                            }
                        })
                        return
                    } else {
                        // reset to initial state
                        TrashImage.alpha = 0
                        ShoppingCartImage.alpha = 0
                        swipedCell.transform = .identity
                    }
                }
            }
        }
    }
    func HandleLongPressShoppingList(sender: UILongPressGestureRecognizer) -> Void {
        let swipeLocation = LongPressShoppingList.location(in: self.ShoppingListCollectionView)
        if let swipedIndexPath = ShoppingListCollectionView.indexPathForItem(at: swipeLocation) {
            if let swipedCell = self.ShoppingListCollectionView.cellForItem(at: swipedIndexPath) {
                
                //remember the index of the swiped cell to reset after animation
                swipedCellIndex = swipedIndexPath.row
                
                //calculate distance to drop item
                let dropHeight = (ShoppingListCollectionView.frame.height - swipeLocation.y) * 1.5
                
                let rightDropLimit:CGFloat = 0.9
                //Trash can image should bo on top
                view.bringSubview(toFront: TrashImage)
                TrashImage.alpha =  1
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
        ShoppingListDetailView.removeFromSuperview()
    }
    func HideAddListPopUp() -> Void {
        HideBlurrView()
        txt_ListName.text = ""
        txt_RelatedStore.text = ""
        AddShoppingListPopUp.removeFromSuperview()
    }
    func HideAddItemPopUp() -> Void {
        txt_ItemName.text = ""
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
            SortShoppingListItemsArrayBy_isSelected()
        }
    }
    func SortShoppingListItemsArrayBy_isSelected() -> Void {
        if SelectedList != nil && SelectedList!.ItemsArray!.count > 0{
            if let index = ShoppingListsArray.index(where: {$0.ID == SelectedList!.ID!}){
                let newitems = ShoppingListsArray[index].ItemsArray!.sorted(by: {return $0.isSelected! < $1.isSelected!})
                ShoppingListsArray[index].ItemsArray = newitems
            }
        }
        ShoppingListDetailTableView.reloadData()
    }
    func ConfigureView() -> Void {
        //FirebaseWebservice
        firebaseWebService = FirebaseWebService()
        firebaseWebService.firebaseWebServiceDelegate = self
        firebaseWebService.alertMessageDelegate = self
        
        //Datasource & Delegate
        ShoppingListDetailTableView.dataSource = self
        ShoppingListDetailTableView.delegate = self
        ShoppingListCollectionView.dataSource = self
        ShoppingListCollectionView.delegate = self
        
        //RefreshControl AddListItem
        refreshControl = UIRefreshControl()
        CustomRefreshView.frame.size.width = 60
        CustomRefreshView.frame.size.height = 60
        CustomRefreshView.layer.shadowColor  = UIColor.black.cgColor
        CustomRefreshView.layer.shadowOffset  = CGSize(width: 30, height:30)
        CustomRefreshView.layer.shadowOpacity  = 1
        CustomRefreshView.layer.shadowRadius  = 10
        CustomRefreshView.center.x = view.center.x
        refreshControl.addSubview(CustomRefreshView)
        refreshControl.alpha = 0
        refreshControl.addTarget(self, action: #selector(ShoppingListController.ShowAddItemPopUp), for: UIControlEvents.allEvents)
        
        //RefreshControl Add Shopping List
        refreshShoppingListControl = UIRefreshControl()
        CustomAddShoppingListRefreshControl.layer.shadowColor  = UIColor.black.cgColor
        CustomAddShoppingListRefreshControl.layer.shadowOffset  = CGSize(width: 30, height:30)
        CustomAddShoppingListRefreshControl.layer.shadowOpacity  = 1
        CustomAddShoppingListRefreshControl.layer.shadowRadius  = 10
        CustomAddShoppingListRefreshControl.frame.size.width = 60
        CustomAddShoppingListRefreshControl.frame.size.height = 60
        CustomAddShoppingListRefreshControl.center.x = view.center.x
        refreshShoppingListControl.addSubview(CustomAddShoppingListRefreshControl)
        refreshShoppingListControl.alpha = 0
        refreshShoppingListControl.addTarget(self, action: #selector(ShoppingListController.ShowAddShoppingListPopUp), for: .allEvents)
        
        if #available(iOS 10.0, *){
            ShoppingListDetailTableView.refreshControl = refreshControl
            ShoppingListCollectionView.refreshControl = refreshShoppingListControl
        } else {
            ShoppingListDetailTableView.addSubview(refreshControl)
            ShoppingListCollectionView.addSubview(refreshShoppingListControl)
        }
        
        //Pan on List Item
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(HandleShoppingItemPan))
        panRecognizer.delegate = self
        ShoppingListDetailTableView.addGestureRecognizer(panRecognizer)
        
        //Pan on List
        LongPressShoppingList = UILongPressGestureRecognizer(target: self, action: #selector(HandleLongPressShoppingList))
        LongPressShoppingList.delegate = self
        ShoppingListCollectionView.addGestureRecognizer(LongPressShoppingList)
        
        
        //SetNavigationBar Title
        navigationItem.title = String.ShoppingListControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.ShoppingListControllerTitle
        
        //Notification Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        //Add Shopping List PopUp
        AddShoppingListPopUp.layer.shadowColor  = UIColor.black.cgColor
        AddShoppingListPopUp.layer.shadowOffset  = CGSize(width: 30, height:30)
        AddShoppingListPopUp.layer.shadowOpacity  = 1
        AddShoppingListPopUp.layer.shadowRadius  = 10
        AddShoppingListPopUp.bringSubview(toFront: btn_SaveList)
        lbl_AddListPopUpTitle.text = String.lbl_AddListPopUpTitle
        txt_RelatedStore.delegate = self
        txt_RelatedStore.placeholder = String.txt_RelatedStore_Placeholder
        txt_RelatedStore.textColor = UIColor.black
        txt_ListName.delegate = self
        txt_ListName.placeholder = String.txt_ListName_Placeholder
        txt_ListName.textColor = UIColor.black
        btn_DeleteList.addTarget(self, action: #selector(btn_DeleteList_Pressed), for: .touchUpInside)
        btn_SaveList.addTarget(self, action: #selector(btn_SaveList_Pressed), for: .touchUpInside)
        let addShoppingListOutsideTap =  UITapGestureRecognizer(target: self, action: #selector(AddShoppingListPopUp_OutsideTouch))
        AddShoppingListPopUp.addGestureRecognizer(addShoppingListOutsideTap)
        
        //Detail ListView
        btn_CloseListDetailView.addTarget(self, action: #selector(btn_CloseListDetailView_Pressed), for: .touchUpInside)
        
        //Add Item PopUp
        AddItemPopUp.layer.shadowColor  = UIColor.black.cgColor
        AddItemPopUp.layer.shadowOffset  = CGSize(width: 30, height:30)
        AddItemPopUp.layer.shadowOpacity  = 1
        AddItemPopUp.layer.shadowRadius  = 10
        lbl_AddItemPopUpTitle.text = String.lbl_AddItemPopUpTitle
        txt_ItemName.delegate = self
        txt_ItemName.placeholder = String.txt_ItemName_Placeholer
        txt_ItemName.tintColor = UIColor.black
        btn_SaveItem.addTarget(self, action: #selector(btn_SaveItem_Pressed), for: .touchUpInside)
        let outsideAddItemPopUpTouch = UITapGestureRecognizer(target: self, action: #selector(AddItemPopUp_OutsideTouch))
        ShoppingListDetailView.addGestureRecognizer(outsideAddItemPopUpTouch)
        AddItemPopUp.addGestureRecognizer(outsideAddItemPopUpTouch)
        
        ShoppingCartImage.alpha = 0
        TrashImage.alpha = 0
        
        //Set Detailtableview bottom constraint
        DetailTableViewBottomConstraint.constant = view.frame.height * 0.115
    }
}
extension ShoppingListController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = collectionViewSectionsInsets.left * (collectionViewItemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / collectionViewItemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionViewSectionsInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewSectionsInsets.left
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
        if SelectedList != nil && SelectedList!.ItemsArray != nil{
            if let index = ShoppingListsArray.index(where: {$0.ID == SelectedList!.ID!}){
                return ShoppingListsArray[index].ItemsArray!.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.ShoppingListItemTableViewCell_Identifier, for: indexPath) as! ShoppingListItemTableViewCell
        if SelectedList != nil && SelectedList!.ItemsArray != nil{
            if let index = ShoppingListsArray.index(where: {$0.ID == SelectedList!.ID!}){
                cell.selectionStyle = .none
                cell.ConfigureCell(shoppingListItem: ShoppingListsArray[index].ItemsArray![indexPath.row])
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SelectedList != nil{
            if let index = ShoppingListsArray.index(where: {$0.ID == SelectedList!.ID!}){
                if ShoppingListsArray[index].ItemsArray!.count > 0 {
                    //Allow only select on checked items => unchecked must be dropped to basket
                    if ShoppingListsArray[index].ItemsArray![indexPath.row].isSelected == "false" { return }
                    ShoppingListsArray[index].ItemsArray![indexPath.row].isSelected  = ShoppingListsArray[index].ItemsArray![indexPath.row].isSelected == "false" ? "true" : "false"
                    firebaseWebService.EditIsSelectedOnShoppingListItem(shoppingListItem: ShoppingListsArray[index].ItemsArray![indexPath.row])
                    SortShoppingListItemsArrayBy_isSelected()
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 7
    }
    /*
     // conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }*/
    
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
