//
//  ShoppingListController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import FirebaseAuth

class ShoppingListController: UIViewController, IAlertMessageDelegate, IValidationService, UIGestureRecognizerDelegate, UITextFieldDelegate, IActivityAnimationService {
    //MARK: - Outlets
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var BackgroundImage: UIImageView!
    @IBOutlet var ShoppingListDetailView: UIView!
    @IBOutlet var ListDetailBackgroundImage: UIImageView!
    @IBOutlet var AddShoppingListButton: UIBarButtonItem!
    
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
    
    //Add Item PopUp
    @IBOutlet var AddItemPopUp: UIView!
    @IBOutlet var AddItemPopUpBackground: DesignableUIView!
    @IBOutlet var txt_ItemName: UITextField!
    @IBOutlet var btn_SaveItem: UIButton!
    @IBOutlet var lbl_AddItemPopUpTitle: UILabel!
    
    //Shopping cart and Trash
    @IBOutlet var ShoppingCartImage: UIImageView!
    @IBOutlet var TrashImage: UIImageView!
    
    //Shopping list Card
    @IBOutlet var ShoppingListCard: UIView!
    @IBOutlet var ShoppingListCardImage: UIImageView!
    @IBOutlet var lbl_ShoppingListCardTitle: UILabel!
    @IBOutlet var ShoppingListCardPanRecognizer: UIPanGestureRecognizer!
    @IBOutlet var ShoppingCardTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var ShoppingCardStoreImage: UIImageView!
    @IBOutlet var lbl_ShoppingCardStoreName: UILabel!
    @IBOutlet var lbl_ShoppingCardTotalItemsLabel: UILabel!
    @IBOutlet var lbl_ShoppingCardTotalItems: UILabel!
    @IBOutlet var lbl_ShoppingCardOpenItemsLabel: UILabel!
    @IBOutlet var lbl_ShoppingCardOpenItems: UILabel!
    @IBOutlet var btn_ShoppingCardShareList: UIButton!
    @IBOutlet var ShoppingListOwnerImage: UIImageView!
    
    //Shopping List Card2
    @IBOutlet var ShoppingListCard2: UIView!
    @IBOutlet var ShoppingListCard2Image: UIImageView!
    @IBOutlet var lbl_ShoppingListCard2Title: UILabel!
    @IBOutlet var ShoppingListCard2PanRecognizer: UIPanGestureRecognizer!
    @IBOutlet var ShoppingCard2TapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var ShoppingCard2StoreImage: UIImageView!
    @IBOutlet var lbl_ShoppingCard2StoreName: UILabel!
    @IBOutlet var lbl_ShoppingCard2TotalItemsLabel: UILabel!
    @IBOutlet var lbl_ShoppingCard2TotalItems: UILabel!
    @IBOutlet var lbl_ShoppingCard2OpenItemsLabel: UILabel!
    @IBOutlet var lbl_ShoppingCard2OpenItems: UILabel!
    @IBOutlet var btn_ShoppingCard2ShareList: UIButton!
    @IBOutlet var ShoppingListCard2OwnerImage: UIImageView!
    
    //Share List PopUp
    @IBOutlet var ShareListPopUp: UIView!
    @IBOutlet var lbl_ShareOpponentTitle: UILabel!
    @IBOutlet var txt_ShareListOpponentEmail: UITextField!
    @IBOutlet var btn_ShareListSave: UIButton!
    
    //InviatationNotification
    @IBOutlet var InvitationNotification: UIView!
    @IBOutlet var lbl_InviteTitle: UILabel!
    @IBOutlet var lbl_InviteMessage: UILabel!
    @IBOutlet var InviteUserImage: UIImageView!
    
    
    //MARK:- Member
    var timer:Timer!
    var blurrView:UIVisualEffectView?
    var refreshControl:UIRefreshControl!
    var refreshShoppingListControl:UIRefreshControl!
    var swipedCellIndex:Int!
    var panRecognizer:UIPanGestureRecognizer!
    var currentShoppingListIndex:Int!
    var currentUpperCard:Int!
    var sbListWebservice:ShoppingBuddyListWebservice!
    var sbListItemWebservice: ShoppingBuddyListItemWebservice!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
        
        //Notification Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingBuddyListDataReceived), name: NSNotification.Name.ShoppingBuddyListDataReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListItemSaved), name: NSNotification.Name.ListItemSaved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListItemReceived), name: NSNotification.Name.ListItemReceived, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if allShoppingLists.count == 0 && ShoppingListCard.alpha == 0 {
            sbListWebservice.ObserveAllList()
        }
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubview(toFront: TrashImage)
        RefreshCardView()
    }
    
    //MARK: - IShoppingBuddyListItemWebService implementation
    func ListItemSaved() {
        
        lbl_ShoppingCardTotalItems.text = String(allShoppingLists[currentShoppingListIndex].items.count)
        lbl_ShoppingCardOpenItems.text = String(allShoppingLists[currentShoppingListIndex].items.filter({ $0.isSelected! == false }).count)
        
    }
    
    func ListItemReceived() {
        
        //Sort items and reload TableView
        SortShoppingListItemsArrayBy_isSelected()
        
    }
    
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        
        ActivityIndicator.activityIndicatorViewStyle = .whiteLarge
        ActivityIndicator.center = view.center
        ActivityIndicator.color = UIColor.green
        ActivityIndicator.startAnimating()
        view.addSubview(ActivityIndicator)
        
    }
    
    func HideActivityIndicator() {
        
        if view.subviews.contains(ActivityIndicator) {
            ActivityIndicator.removeFromSuperview()
        }
        
    }
    
    
    //MARK: - IFirebaseListWebService implementation
    func ShoppingBuddyListDataReceived() {
        
        ShoppingListDetailTableView.reloadData()
        SortShoppingListItemsArrayBy_isSelected()
        /*
        for list in allShoppingLists {
            if let index = ProfileImageCache.index(where: { $0.ProfileImageURL == list.ownerImageURL }) {
                if let listindex = allShoppingLists.index(where: { $0.id == list.id }) {
                    allShoppingLists[listindex].ownerImage = ProfileImageCache[index].UserProfileImage!
                }
            }
        }*/
        RefreshCardView()
        
    }
    
    func ShoppingBuddyImageReceived() {
        
        ShoppingListCard2OwnerImage.alpha = 1
        ShoppingListOwnerImage.alpha = 1
        
    }
    
    func ShoppingBuddyNewListSaved(listID:String) {
        
        sbListWebservice.ObserveSingleList(listID: listID)
        UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        
    }
    
    func ShoppingBuddyNewListReceived(listID: String) {
        
        if let index = allShoppingLists.index(where: { $0.id! == listID }) {
            currentShoppingListIndex = index
        }
        RefreshCardView()
        
    }
    
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - Wired Actions
    //Shopping List
    func btn_SaveList_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ListName.text, alertDelegate: self)
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_RelatedStore.text, alertDelegate: self)
        if isValid{
            sbListWebservice.SaveListToFirebaseDatabase(currentUser: currentUser!, listName: txt_ListName.text!, relatedStore: txt_RelatedStore.text!)
            HideAddListPopUp()
        }
    }
    @IBAction func btn_AddShoppingList_Pressed(_ sender: UIBarButtonItem) {
        ShowAddShoppingListPopUp()
    }
    func BlurrView_Tapped(sender: UITapGestureRecognizer) -> Void {
        HideAddListPopUp()
        HideShareListPopUp()
        ShoppingListDetailView.removeFromSuperview()
    }
    func btn_CloseListDetailView_Pressed(sender: UIButton) -> Void {
        NotificationCenter.default.post(name: Notification.Name.PerformLocalShopSearch, object: nil, userInfo: nil)
        HideBlurrView()
        HideListDetailView()
        HideAddItemPopUp()
        RefreshCardView()
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
    //Shopping List Items
    func btn_SaveItem_Pressed(sender: UIButton) -> Void {
        
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ItemName.text, alertDelegate: self)
        
        if isValid{
            
            var newListItem = ShoppingListItem()
            newListItem.itemName = txt_ItemName.text!
            newListItem.listID = allShoppingLists[currentShoppingListIndex].id!
            sbListItemWebservice.SaveListItemToFirebaseDatabase(listItem: newListItem)
            
            HideAddItemPopUp()
            
        }
        
    }
    
    func btn_ShareListSave_Pressed(sender: UIButton) -> Void {
        
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .email, validationString: txt_ShareListOpponentEmail.text, alertDelegate: self)
        
        if isValid {
            
            sbListWebservice.SendFriendSharingInvitation(friendsEmail: txt_ShareListOpponentEmail.text!, list: allShoppingLists[currentShoppingListIndex], listOwner: currentUser!)
            HideShareListPopUp()
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
    
    func btn_ShoppingCardShareList_Pressed(sender: UIButton) -> Void {
        ShowShareListPopUp()
    }
    
    func btn_ShoppingCard2ShareList_Pressed(sender: UIButton) -> Void {
        ShowShareListPopUp()
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
                let isSelected =  allShoppingLists[currentShoppingListIndex].items[self.swipedCellIndex].isSelected
                
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
                if abs(xPercentFromCenter) < leftDropLimit && velocity.x < 0 && isSelected! == false{
                    swipedCell.transform = CGAffineTransform(translationX: point.x, y: 0)
                }
                
                print(xPercentFromCenter)
                //Shopping cart image should bo on top
                view.bringSubview(toFront: ShoppingCartImage)
                ShoppingCartImage.alpha =  xPercentFromCenter < -0.25 && isSelected! == false ? 1 : 0
                
                //Trash can image should bo on top
                view.bringSubview(toFront: TrashImage)
                TrashImage.alpha =  xPercentFromCenter > rightDropLimit ? 1 : 0
                
                //Perform animations on gesture .ended state
                if panRecognizer.state == UIGestureRecognizerState.ended {
                    if xPercentFromCenter <= -0.25 && isSelected! == false{
                        //Shake Cart
                        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                            
                            self.ShoppingCartImage.transform = CGAffineTransform(translationX: 20, y: 0)
                            
                        })
                        //Drop item to cart
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                            
                            swipedCell.transform = CGAffineTransform.init(translationX: -(self.view.frame.width * 0.35), y: dropHeight).rotated(by: -45).scaledBy(x: 0.3, y: 0.3)
                            
                        }, completion: { (true) in
                            
                            if allShoppingLists[self.currentShoppingListIndex].items.count > self.swipedCellIndex {
                                
                                allShoppingLists[self.currentShoppingListIndex].items[self.swipedCellIndex].isSelected = true
                                self.sbListItemWebservice.EditIsSelectedOnShoppingListItem(listItem: allShoppingLists[self.currentShoppingListIndex].items[self.swipedCellIndex])
                                
                            }
                            
                            self.ShoppingCartImage.alpha = 0
                            self.ShoppingCartImage.transform = .identity
                            swipedCell.transform = .identity
                            self.HideActivityIndicator()
                            
                        })
                    }
                    else if xPercentFromCenter >= 0.75{
                        //Shake Trash
                        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                            
                            self.TrashImage.transform = CGAffineTransform(translationX: -20, y: 0)
                            
                        })
                        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                            
                            swipedCell.transform = CGAffineTransform.init(translationX: self.view.frame.width * 0.8, y: dropHeight).rotated(by: 45).scaledBy(x: 0.3, y: 0.3)
                            
                        }, completion: { (true) in
                            
                            if let index = allShoppingLists.index(where: {$0.id == allShoppingLists[self.currentShoppingListIndex].id!}){
                                
                                if allShoppingLists[index].items.isEmpty { return }
                                self.sbListItemWebservice.DeleteShoppingListItemFromFirebase(itemToDelete: allShoppingLists[index].items[self.swipedCellIndex])
                                allShoppingLists[index].items.remove(at: self.swipedCellIndex)
                                self.ShoppingListDetailTableView.deleteRows(at: [swipedIndexPath], with: .none)
                                
                            }
                            
                            self.TrashImage.alpha = 0
                            self.TrashImage.transform = .identity
                            swipedCell.alpha = 0
                            swipedCell.transform = .identity
                            
                        })
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
    
    
    @IBAction func ShoppingListCardPan(_ sender: UIPanGestureRecognizer) {
        let note = sender.view!
        let point = sender.translation(in: view)
        let xFromCenter = note.center.x - view.center.x
        let yFromCenter = note
            .center.y - view.center.y
        let swipeLimitLeft = view.frame.width * 0.4 // left border when the card gets animated off
        let swipeLimitRight = view.frame.width * 0.6 // right border when the card gets animated off
        let swipeLimitTop = view.frame.height * 0.5 // top border when the card gets animated off
        let swipeLimitBottom = view.frame.height * 0.65 // top border when the card gets animated off
        let ySpin:CGFloat = yFromCenter < 0 ? -200 : 200 // gives the card a spin in y direction
        let xSpin:CGFloat = xFromCenter < 0 ? -200 : 200 // gives the card a spin in x direction
        note.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        //Rotate card while drag
        let degree:Double = Double(xFromCenter / ((view.frame.size.width * 0.5) / 40))
        note.transform = CGAffineTransform(rotationAngle: degree.degreesToRadians)
        
        view.bringSubview(toFront: TrashImage)
        TrashImage.alpha = note.center.y > swipeLimitBottom ? 1 : 0
        
        //Animate card after drag ended
        if sender.state == UIGestureRecognizerState.ended{
            let swipeDuration = 0.3
            // Move off to the left side if drag reached swipeLimitLeft
            if note.center.x < swipeLimitLeft{
                
                SwitchCurrentUpperCardIndex()
                SwipeCardOffLeft(swipeDuration: swipeDuration, card: note, ySpin: ySpin)
                return
                
            } else if note.center.x > swipeLimitRight{
                
                SwitchCurrentUpperCardIndex()
                SwipeCardOffRight(swipeDuration: swipeDuration, card: note, ySpin: ySpin)
                return
                
            } else if note.center.y < swipeLimitTop{
                
                SwitchCurrentUpperCardIndex()
                SwipeCardOffTop(swipeDuration: swipeDuration, card: note, xSpin: xSpin)
                return
                
            } else if note.center.y > swipeLimitBottom {
                
                //Move downways if drag reached swipe limit bottom
                SwipeCardOffBottom(swipeDuration: swipeDuration, card: note, xSpin: xSpin)
                return
                
            } else {
                
                // Reset card if no drag limit reached
                self.ResetCardAfterSwipeOff(card: note)
                
            }
        }
    }
    
    @IBAction func ShoppingListCard2Pan(_ sender: UIPanGestureRecognizer) {
        let note = sender.view!
        let point = sender.translation(in: view)
        let xFromCenter = note.center.x - view.center.x
        let yFromCenter = note
            .center.y - view.center.y
        let swipeLimitLeft = view.frame.width * 0.4 // left border when the card gets animated off
        let swipeLimitRight = view.frame.width * 0.6 // right border when the card gets animated off
        let swipeLimitTop = view.frame.height * 0.5 // top border when the card gets animated off
        let swipeLimitBottom = view.frame.height * 0.65 // top border when the card gets animated off
        let ySpin:CGFloat = yFromCenter < 0 ? -200 : 200 // gives the card a spin in y direction
        let xSpin:CGFloat = xFromCenter < 0 ? -200 : 200 // gives the card a spin in x direction
        note.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        //Rotate card while drag
        let degree:Double = Double(xFromCenter / ((view.frame.size.width * 0.5) / 40))
        note.transform = CGAffineTransform(rotationAngle: degree.degreesToRadians)
        view.bringSubview(toFront: TrashImage)
        TrashImage.alpha = note.center.y > swipeLimitBottom ? 1 : 0
        
        
        //Animate card after drag ended
        if sender.state == UIGestureRecognizerState.ended{
            let swipeDuration = 0.3
            if note.center.x < swipeLimitLeft{
                
                SwitchCurrentUpperCardIndex()
                SwipeCardOffLeft(swipeDuration: swipeDuration, card: note, ySpin: ySpin)
                return
                
            } else if note.center.x > swipeLimitRight{
                
                SwitchCurrentUpperCardIndex()
                SwipeCardOffRight(swipeDuration: swipeDuration, card: note, ySpin: ySpin)
                return
                
            } else if note.center.y < swipeLimitTop{
                
                SwitchCurrentUpperCardIndex()
                SwipeCardOffTop(swipeDuration: swipeDuration, card: note, xSpin: xSpin)
                return
                
            } else if note.center.y > swipeLimitBottom {
                
                SwitchCurrentUpperCardIndex()
                SwipeCardOffBottom(swipeDuration: swipeDuration, card: note, xSpin: xSpin)
                return
                
            } else {
                
                self.ResetCardAfterSwipeOff(card: note)
                
            }
        }
    }
    
    @IBAction func CardOneTapped(_ sender: UITapGestureRecognizer) {
        ShowListDetailView()
    }
    @IBAction func CardTwoTapped(_ sender: UITapGestureRecognizer) {
        ShowListDetailView()
    }
    
    
    //MARK: Swipe Helpers
    private func SwitchCurrentUpperCardIndex() -> Void {
        currentUpperCard = currentUpperCard == 1 ? 2 : 1
    }
    private func SwipeCardOffLeft(swipeDuration: TimeInterval, card: UIView, ySpin: CGFloat){
        
        UIView.animate(withDuration: swipeDuration, animations: {
            
            card.center.x = card.center.x - self.view.frame.size.width
            card.center.y = card.center.y + ySpin
            
        }, completion: { (true) in
            
            self.ResetCardAfterSwipeOff(card: card)
            
        })
    }
    private func SwipeCardOffRight(swipeDuration: TimeInterval, card: UIView, ySpin: CGFloat){
        
        UIView.animate(withDuration: swipeDuration, animations: {
            
            card.center.x = card.center.x + self.view.frame.size.width
            card.center.y = card.center.y + ySpin
            
        }, completion: { (true) in
            
            self.ResetCardAfterSwipeOff(card: card)
            
        })
    }
    private func SwipeCardOffTop(swipeDuration: TimeInterval, card: UIView, xSpin: CGFloat){
        
        UIView.animate(withDuration: swipeDuration, animations: {
            
            card.center.y = card.center.y - self.view.frame.size.height
            card.center.x = card.center.x + xSpin
            
        }, completion: { (true) in
            
            self.ResetCardAfterSwipeOff(card: card)
            
        })
    }
    private func SwipeCardOffBottom(swipeDuration: TimeInterval, card: UIView, xSpin: CGFloat) -> Void {
        
        UIView.animate(withDuration: swipeDuration, animations: {
            
            card.center.y = card.center.y + self.view.frame.size.height
            card.center.x = card.center.x + xSpin
            
        }, completion: { (true) in
            
            if allShoppingLists[self.currentShoppingListIndex].owneruid! == currentUser!.id!{
                
                let title = String.ShoppingListDeleteAlertTitle
                let message = String.ShoppingListDeleteAlertMessage
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) -> Void in
                    
                    self.sbListWebservice.DeleteShoppingListFromFirebase(listToDelete: allShoppingLists[self.currentShoppingListIndex])
                    if let index = allShoppingLists.index(where: { $0.id == allShoppingLists[self.currentShoppingListIndex].id }) {
                        
                        allShoppingLists.remove(at: index)
                        self.DecrementCurrentShoppingListIndex()
                        
                    }
                    
                    if allShoppingLists.isEmpty {
                        
                        self.TrashImage.alpha = 0
                        self.TrashImage.transform = .identity
                        self.RefreshCardView()
                        
                    } else {
                        
                        self.ResetCardAfterSwipeOff(card: card)
                        
                    }
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) -> Void in
                    self.ShoppingListCard.transform = .identity
                    self.ShoppingListCard2.transform = .identity
                }))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                let title = "Permission Denied"
                let message = "Your are only allowed to delete your own lists!"
                self.ShowAlertMessage(title: title, message: message)
                self.ResetCardAfterSwipeOff(card: card)
            }
        })
    }
    private func ResetCardAfterSwipeOff(card: UIView) -> Void {
        
        self.SetNewCardValues()
        TrashImage.alpha = 0
        TrashImage.transform = .identity
        card.alpha = 0
        card.center = self.view.center
        card.Arise(duration: 0.7, delay: 0, options: [.allowUserInteraction], toAlpha: 1)
        
        if currentUpperCard == 1{
            
            view.bringSubview(toFront: ShoppingListCard)
            ShoppingListCard2.transform = .identity
            ShoppingListCard2.transform = CGAffineTransform(rotationAngle: Double(8).degreesToRadians)
            RefreshCardView()
            
        } else {
            
            view.bringSubview(toFront: ShoppingListCard2)
            ShoppingListCard.transform = .identity
            ShoppingListCard.transform = CGAffineTransform(rotationAngle: Double(5).degreesToRadians)
            RefreshCardView()
        }
    }
    
    func RefreshCardView(){
        
        if allShoppingLists.isEmpty {
            
            ShoppingListCard.alpha = 0
            ShoppingListCard2.alpha = 0
            return
            
        }
        
        ShoppingListCard.alpha = 1
        ShoppingListCard2.alpha = 1
        
        if allShoppingLists.count == 1{
            
            currentShoppingListIndex = 0
            SetCardOneValues(index: 0)
            SetCardTwoValues(index: 0)
            
        } else {
            
            if currentUpperCard == 1 {
                
                SetCardOneValues(index: currentShoppingListIndex!)
                SetCardTwoValues(index: determineLowerCardIndex(currentUpperListIndex: currentShoppingListIndex))
                
            } else {
                
                SetCardOneValues(index: determineLowerCardIndex(currentUpperListIndex: currentShoppingListIndex))
                SetCardTwoValues(index: currentShoppingListIndex!)
                
            }
        }
    }
    private func SetNewCardValues() -> Void {
        
        if allShoppingLists.count == 0 { return }
        IncrementCurrentShoppingListIndex()
        
        NSLog("Shopping list array Count \(allShoppingLists.count)")
        NSLog("Current Shopping List Index \(currentShoppingListIndex)")
        NSLog("Current List Title \(allShoppingLists[currentShoppingListIndex].name!)")
        
        if allShoppingLists.count == 1 {
            
            SetCardOneValues(index: 0)
            SetCardTwoValues(index: 0)
            return
            
        }
        
        if currentUpperCard == 1 {
            
            SetCardOneValues(index: currentShoppingListIndex)
            SetCardTwoValues(index: determineLowerCardIndex(currentUpperListIndex: currentShoppingListIndex))
            
        } else {
            
            SetCardOneValues(index: determineLowerCardIndex(currentUpperListIndex: currentShoppingListIndex))
            SetCardTwoValues(index: currentShoppingListIndex)
            
        }
        
    }
    
    private func IncrementCurrentShoppingListIndex() -> Void {
        
        currentShoppingListIndex = currentShoppingListIndex >= allShoppingLists.count - 1 ?  0 : currentShoppingListIndex + 1
        
    }
    
    private func DecrementCurrentShoppingListIndex() -> Void {
        
        currentShoppingListIndex = currentShoppingListIndex == 0 ? allShoppingLists.count : currentShoppingListIndex - 1
        
    }
    
    private func determineLowerCardIndex(currentUpperListIndex:Int) -> Int {
        
        let lowerCardIndex = currentUpperListIndex == allShoppingLists.count - 1 ? 1 : currentUpperListIndex + 1
        return lowerCardIndex
        
    }
    
    private func SetCardOneValues(index: Int) -> Void{
        
        lbl_ShoppingListCardTitle.text = allShoppingLists[index].name!
        lbl_ShoppingCardStoreName.text = allShoppingLists[index].relatedStore!
        lbl_ShoppingCardTotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
        lbl_ShoppingCardTotalItems.text = "\(allShoppingLists[index].items.count)"
        lbl_ShoppingCardOpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
        lbl_ShoppingCardOpenItems.text = "\(GetOpenItemsCount(shoppingItems: allShoppingLists[index].items))"
        
        
        if let userIndex = allUsers.index(where: { $0.id == allShoppingLists[index].owneruid }) {
            
            ShoppingListOwnerImage.alpha = 1
            ShoppingListOwnerImage.image = allUsers[userIndex].profileImage
            
        }
        
        HideShareListButtonIfCurrentUserNotIsListOwner()
        
    }
    
    private func SetCardTwoValues(index: Int) -> Void{
        
        lbl_ShoppingListCard2Title.text = allShoppingLists[index].name!
        lbl_ShoppingCard2StoreName.text = allShoppingLists[index].relatedStore!
        lbl_ShoppingCard2TotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
        lbl_ShoppingCard2TotalItems.text = "\(allShoppingLists[index].items.count)"
        lbl_ShoppingCard2OpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
        lbl_ShoppingCard2OpenItems.text = "\(GetOpenItemsCount(shoppingItems: allShoppingLists[index].items))"
        
        if let userIndex = allUsers.index(where: { $0.id == allShoppingLists[index].owneruid }) {
            
            ShoppingListCard2OwnerImage.alpha = 1
            ShoppingListCard2OwnerImage.image = allUsers[userIndex].profileImage
            
        }
        
        HideShareListButtonIfCurrentUserNotIsListOwner()
        
    }
    private func HideShareListButtonIfCurrentUserNotIsListOwner() -> Void {
        
        //Hide share list button
        if allShoppingLists[currentShoppingListIndex].owneruid == nil { return }
        if  allShoppingLists[currentShoppingListIndex].owneruid! != UserDefaults.standard.string(forKey: eUserDefaultKey.CurrentUserID.rawValue) {
            
            if currentUpperCard == 1 {
                
                btn_ShoppingCardShareList.alpha = 0
                
            } else { btn_ShoppingCard2ShareList.alpha = 0 }
            
            return            
        }
        
        if currentUpperCard == 1 {
            
            btn_ShoppingCardShareList.alpha = 1
            
        } else { btn_ShoppingCard2ShareList.alpha = 1 }
        
    }
    
    //MARK: - Notification listener selectors     
    func CurrentUserReceived(notification: Notification) -> Void {
        
        // userdata received so lets observe his lists            
        //    sbListWebservice.ObserveAllList()
        
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
            ShareListPopUp.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
            
        }
        
    }
    func KeyboardWillHide(sender: Notification) -> Void {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            AddItemPopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
            AddShoppingListPopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
            ShareListPopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
            
        }
        
    }
    
    
    //MARK: - Helper Functions
    func ShowAddShoppingListPopUp() -> Void {
        
        AddShoppingListPopUp.frame.size.width = 280
        AddShoppingListPopUp.center = view.center
        view.addSubview(AddShoppingListPopUp)
        AddShoppingListPopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
        
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
    func ShowShareListPopUp() -> Void{
        
        if ShowBlurrView() {
            
            ShareListPopUp.frame.size.width = 280
            ShareListPopUp.center = view.center
            view.addSubview(ShareListPopUp)
            ShareListPopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
            
        }
        
    }
    
    func ShowBlurrView() -> Bool{
        
        if blurrView == nil {
            
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
    
    func HideBlurrView() -> Void{
        
        blurrView?.removeFromSuperview()
        blurrView = nil
        
    }
    
    func HideListDetailView() -> Void {
        
        ShoppingListDetailView.removeFromSuperview()
        
    }
    
    func HideAddListPopUp() -> Void {
        
        HideBlurrView()
        txt_ListName.text = ""
        txt_RelatedStore.text = ""
        AddShoppingListPopUp.removeFromSuperview()
        
    }
    
    func HideShareListPopUp() -> Void {
        
        HideBlurrView()
        ShareListPopUp.removeFromSuperview()
        
    }
    
    func HideAddItemPopUp() -> Void {
        
        txt_ItemName.text = ""
        AddItemPopUp.removeFromSuperview()
        
    }
    
    func ShowListDetailView() -> Void {
        
        if ShowBlurrView() {
            
            ShoppingListDetailView.frame.size.width = view.frame.width * 0.95
            ShoppingListDetailView.frame.size.height = view.frame.height * 0.8
            ShoppingListDetailView.center = view.center
            lbl_ShoppingListDetailTitle.text = allShoppingLists[currentShoppingListIndex].name != nil ? allShoppingLists[currentShoppingListIndex].name : ""
            view.addSubview(ShoppingListDetailView)
            ShoppingListDetailTableView.delegate = self
            ShoppingListDetailTableView.dataSource = self
            SortShoppingListItemsArrayBy_isSelected()
            
        }
        
    }
    
    func SortShoppingListItemsArrayBy_isSelected() -> Void {
        
        if allShoppingLists[currentShoppingListIndex].items.isEmpty {
            
            ShoppingListDetailTableView.reloadData()
            return
            
        }
        
        allShoppingLists[currentShoppingListIndex].items.sort{ !$0.isSelected! && $1.isSelected! }
        ShoppingListDetailTableView.reloadData()
        
    }
    
    func GetOpenItemsCount(shoppingItems: [ShoppingListItem]) -> Int {
        
        return shoppingItems.filter({$0.isSelected! == false}).count
        
    }
    
    func HideSharingInvitationNotification() -> Void {
        UIView.animate(withDuration: 1, animations: {
            self.InvitationNotification.center.y = -self.InvitationNotification.frame.size.height * 2 - self.topLayoutGuide.length
        }) { (true) in
            if self.view.subviews.contains(self.InvitationNotification) {
                self.InvitationNotification.removeFromSuperview()
            }
        }
    }
    
    func ShowSharingInvitationNotification(notification: Notification) -> Void {
        
        guard let info = notification.userInfo else { return }
        let pnh = PushNotificationHelper()
        guard let invite = pnh.createChoppingBuddyIntitationObject(userInfo: info) else { return }
        
        lbl_InviteTitle.text = invite.inviteTitle!
        lbl_InviteMessage.text = invite.inviteMessage!
        
        /*
        if let index = ProfileImageCache.index(where: { $0.ProfileImageURL == invite.sender!.profileImageURL } ) {
            
            invite.sender!.profileImage = ProfileImageCache[index].UserProfileImage!
            InviteUserImage.image = ProfileImageCache[index].UserProfileImage!
            displaySharingInvatationNotification()
            
        } else {
            
            ShowSharingInvatationNotificationAfterImageDownload(url: URL(string: invite.sender!.profileImageURL!)!)
            
        }*/
        
    }
    private func ShowSharingInvatationNotificationAfterImageDownload(url:URL) -> Void {
        
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            DispatchQueue.main.async {
                
                if let downloadImage = UIImage(data: data!) {
                    //TODO: take a look in runtime
                    self.InviteUserImage.image = downloadImage
                    self.displaySharingInvatationNotification()
                    
                }
            }
        }
        task.resume()
    }
    private func displaySharingInvatationNotification() -> Void {        
        
        //Invite Notification View
        InvitationNotification.center.x = view.center.x
        InvitationNotification.center.y = -InvitationNotification.frame.height
        InvitationNotification.layer.cornerRadius = 30
        InviteUserImage.layer.cornerRadius = InviteUserImage.frame.width * 0.5
        InviteUserImage.clipsToBounds = true
        InviteUserImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        InviteUserImage.layer.borderWidth = 3
        
        view.addSubview(InvitationNotification)
        InviteUserImage.layer.cornerRadius = InviteUserImage.frame.width * 0.5
        UIView.animate(withDuration: 1) {
            self.InvitationNotification.transform = CGAffineTransform(translationX: 0, y: self.InvitationNotification.frame.size.height * 2 + self.topLayoutGuide.length)
        }
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(HideSharingInvitationNotification), userInfo: nil, repeats: false)
        
    }
    
    
    
    func ConfigureView() -> Void {        
        //SetNavigationBar Title
        navigationItem.title = String.ShoppingListControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.ShoppingListControllerTitle
        
        //SHoppingBuddyListItemWebService
        sbListItemWebservice = ShoppingBuddyListItemWebservice()
        sbListItemWebservice.activityAnimationServiceDelegate  = self
        sbListItemWebservice.alertMessageDelegate = self
        
        //Firebase Shopping list
        sbListWebservice = ShoppingBuddyListWebservice()
        sbListWebservice.alertMessageDelegate = self
        sbListWebservice.activityAnimationServiceDelegate = self
        
        if allShoppingLists.isEmpty {
            
            ShoppingListCard.alpha = 0
            ShoppingListCard2.alpha = 0
            
        }
        AddShoppingListButton.tintColor = UIColor.ColorPaletteTintColor()
        
        //Datasource & Delegate
        ShoppingListDetailTableView.dataSource = self
        ShoppingListDetailTableView.delegate = self
        
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
        
        if #available(iOS 10.0, *){
            ShoppingListDetailTableView.refreshControl = refreshControl
        } else {
            ShoppingListDetailTableView.addSubview(refreshControl)
        }
        
        //Pan on List Item
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(HandleShoppingItemPan))
        panRecognizer.delegate = self
        ShoppingListDetailTableView.addGestureRecognizer(panRecognizer)
        
        //Notification Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(ShowSharingInvitationNotification), name: NSNotification.Name.SharingInvitationNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
   
        
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
        btn_SaveList.addTarget(self, action: #selector(btn_SaveList_Pressed), for: .touchUpInside)
        let addShoppingListOutsideTap =  UITapGestureRecognizer(target: self, action: #selector(AddShoppingListPopUp_OutsideTouch))
        AddShoppingListPopUp.addGestureRecognizer(addShoppingListOutsideTap)
        
        //Detail ListView
        btn_CloseListDetailView.addTarget(self, action: #selector(btn_CloseListDetailView_Pressed), for: .touchUpInside)
        
        //ShareListPoUp
        lbl_ShareOpponentTitle.text = String.lbl_ShareListTitle
        txt_ShareListOpponentEmail.placeholder = String.txt_ShareOpponentEmailPlaceholder
        ShareListPopUp.layer.shadowColor  = UIColor.black.cgColor
        ShareListPopUp.layer.shadowOffset  = CGSize(width: 30, height:30)
        ShareListPopUp.layer.shadowOpacity  = 1
        ShareListPopUp.layer.shadowRadius  = 10
        btn_ShareListSave.addTarget(self, action: #selector(btn_ShareListSave_Pressed), for: .touchUpInside)
        
        
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
        
        ShoppingListCard.center = view.center
        ShoppingListCard2.center = view.center
        ShoppingListCard.transform = CGAffineTransform(rotationAngle: Double(5).degreesToRadians)
        ShoppingListCard2.transform = CGAffineTransform(rotationAngle: Double(8).degreesToRadians)
        
        //Set initialUpper Card index
        currentShoppingListIndex = 0
        currentUpperCard = 1
        
        btn_ShoppingCardShareList.addTarget(self, action: #selector(btn_ShoppingCardShareList_Pressed), for: .touchUpInside)
        btn_ShoppingCard2ShareList.addTarget(self, action: #selector(btn_ShoppingCard2ShareList_Pressed), for: .touchUpInside)
        
        //Shopping List Cards owner Profile Images
        ShoppingListCard2OwnerImage.layer.cornerRadius = ShoppingListCard2OwnerImage.frame.width * 0.5
        ShoppingListCard2OwnerImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        ShoppingListCard2OwnerImage.layer.borderWidth = 3
        
        ShoppingListOwnerImage.layer.cornerRadius = ShoppingListOwnerImage.frame.width * 0.5
        ShoppingListOwnerImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        ShoppingListOwnerImage.layer.borderWidth = 3
        
        if allShoppingLists.count > 1 {
            
            currentShoppingListIndex = 0
            lbl_ShoppingListCardTitle.text = allShoppingLists[0].name!
            lbl_ShoppingCardStoreName.text = allShoppingLists[0].relatedStore!
            lbl_ShoppingCardTotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
            lbl_ShoppingCardTotalItems.text = "\(allShoppingLists[0].items!.count)"
            lbl_ShoppingCardOpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
            lbl_ShoppingCardOpenItems.text = "\(GetOpenItemsCount(shoppingItems: allShoppingLists[0].items))"
            
            lbl_ShoppingListCard2Title.text = allShoppingLists[1].name!
            lbl_ShoppingCard2StoreName.text = allShoppingLists[1].relatedStore!
            lbl_ShoppingCard2TotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
            lbl_ShoppingCard2TotalItems.text = "\(allShoppingLists[1].items!.count)"
            lbl_ShoppingCard2OpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
            lbl_ShoppingCard2OpenItems.text = "\(GetOpenItemsCount(shoppingItems: allShoppingLists[1].items))"
            
            
        } else if allShoppingLists.count == 1 {
            
            currentShoppingListIndex = 0
            lbl_ShoppingListCardTitle.text = allShoppingLists[0].name!
            lbl_ShoppingCardStoreName.text = allShoppingLists[0].relatedStore!
            lbl_ShoppingCardTotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
            lbl_ShoppingCardTotalItems.text = "\(allShoppingLists[0].items!.count)"
            lbl_ShoppingCardOpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
            lbl_ShoppingCardOpenItems.text = "\(GetOpenItemsCount(shoppingItems: allShoppingLists[0].items))"
            
            lbl_ShoppingListCard2Title.text = allShoppingLists[0].name!
            lbl_ShoppingCard2StoreName.text = allShoppingLists[0].relatedStore!
            lbl_ShoppingCard2TotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
            lbl_ShoppingCard2TotalItems.text = "\(allShoppingLists[0].items!.count)"
            lbl_ShoppingCard2OpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
            lbl_ShoppingCard2OpenItems.text = "\(GetOpenItemsCount(shoppingItems: allShoppingLists[0].items))"
            
        }
    }
}
extension Double {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}
extension ShoppingListController: UITableViewDelegate, UITableViewDataSource{
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allShoppingLists[currentShoppingListIndex].items.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String.ShoppingListItemTableViewCell_Identifier, for: indexPath) as! ShoppingListItemTableViewCell
        cell.selectionStyle = .none
        cell.ConfigureCell(shoppingListItem: allShoppingLists[currentShoppingListIndex].items[indexPath.row])
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if allShoppingLists[currentShoppingListIndex].items.isEmpty { return }
        
        let row = indexPath.row
        if allShoppingLists[currentShoppingListIndex].items[row].isSelected == false { return }
        allShoppingLists[currentShoppingListIndex].items[row].isSelected  = allShoppingLists[currentShoppingListIndex].items[row].isSelected == false ? true : false
        sbListItemWebservice.EditIsSelectedOnShoppingListItem(listItem: allShoppingLists[currentShoppingListIndex].items[row])
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 7
    }
    // conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
}
