//
//  ShoppingListController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleMobileAds

class ShoppingListController: UIViewController, IAlertMessageDelegate, IValidationService, UIGestureRecognizerDelegate, UITextFieldDelegate, IActivityAnimationService, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
    @IBOutlet var CardOneMembersCollectionView: UICollectionView!
    @IBOutlet var btn_CancelSharingCardOne: UIButton!
    
    
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
    @IBOutlet var CardTwoMembersCollectionView: UICollectionView!
    @IBOutlet var btn_CancelSharingCardTwo: UIButton!
    
    
    //Share List PopUp
    @IBOutlet var ShareListPopUp: UIView!
    @IBOutlet var lbl_ShareOpponentTitle: UILabel!
    @IBOutlet var txt_ShareListOpponentEmail: UITextField!
    @IBOutlet var btn_ShareListSave: UIButton!
    
    
    //InviatationNotification
    @IBOutlet var InvitationNotification: UIView!
    @IBOutlet var lbl_InviteTitle: UILabel!
    @IBOutlet var txt_InviteMessage: UITextView!
    @IBOutlet var InviteUserImage: UIImageView!
    
    //Cancel Sharing PopUp
    @IBOutlet var CancelSharingPopUp: UIView!
    @IBOutlet var CancelSharingMemberCollectionView: UICollectionView!
    @IBOutlet var lbl_CancelSharing: UILabel!
    
    
    
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
    var bannerView:GADBannerView!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
//        
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//        bannerView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
//        bannerView.alpha = 0
//        bannerView.adUnitID = "ca-app-pub-6831541133910222/1418042316"
//        bannerView.rootViewController = self
//        let request = GADRequest()
//        request.testDevices = [kGADSimulatorID,"faff03ee8b3c887a15d0f375da4ceb0daad26b1e"]
//        bannerView.load(request)
//        bannerView.delegate = self
//        bannerView.rootViewController = self
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        bannerView.center.x = view.center.x
//        view.addSubview(bannerView)
//        bannerView.bottomAnchor.constraint(equalTo: BackgroundImage.bottomAnchor).isActive = true
//        bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
    @objc func ListItemSaved() {
        
        lbl_ShoppingCardTotalItems.text = String(allShoppingLists[currentShoppingListIndex].items.count)
        lbl_ShoppingCardOpenItems.text = String(allShoppingLists[currentShoppingListIndex].items.filter({ $0.isSelected! == false }).count)
        
    }
    
    @objc func ListItemReceived() {
        
        //Sort items and reload TableView
        SortShoppingListItemsArrayBy_isSelected()
        
    }
    
    @objc func UserProfileImageDownloadFinished(notification: Notification) -> Void {
        OperationQueue.main.addOperation {
            
            self.CardOneMembersCollectionView.reloadData()
            self.CardTwoMembersCollectionView.reloadData()
            self.RefreshCardView()
            
        }
        
    }
    
    
    //MARK: - IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
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
    @objc func ShoppingBuddyListDataReceived() {
        
        //download user if unknown
        for list in allShoppingLists{
            
            if let _ = allUsers.index(where: { $0.id == list.owneruid }) {}
            else {
                
                //download user
                let sbUserService = ShoppingBuddyUserWebservice()
                sbUserService.alertMessageDelegate = self
                sbUserService.activityAnimationServiceDelegate = self
                sbUserService.ObserveUser(userID: list.owneruid!)
                
            }
            
            for member in list.members {
                
                if let _ = allUsers.index(where: { $0.id == member.memberID }) {}
                else {
                    
                    //download user
                    let sbUserService = ShoppingBuddyUserWebservice()
                    sbUserService.alertMessageDelegate = self
                    sbUserService.activityAnimationServiceDelegate = self
                    sbUserService.ObserveUser(userID: member.memberID!)
                    
                }
                
            }
            
        }
        
        RefreshCardView()
        
    }
    
    func ShoppingBuddyImageReceived() {
        
        ShoppingListCard2OwnerImage.alpha = 1
        ShoppingListOwnerImage.alpha = 1
        RefreshCardView()
        
    }
    
    func ShoppingBuddyNewListSaved(listID:String) {
        
        sbListWebservice.ObserveAllList()
        UserDefaults.standard.set(true, forKey: eUserDefaultKey.NeedToUpdateGeofence.rawValue)
        
    }
    
    func ShoppingBuddyNewListReceived(listID: String) {
        
        if let index = allShoppingLists.index(where: { $0.id! == listID }) {
            currentShoppingListIndex = index
        }
        RefreshCardView()
        
    }
    
    
    //MARK: - Wired Actions
    //MARK: Buttons
    @objc func btn_CancelSharingCardOne_Pressed(sender: UIButton) -> Void {
        
        cancelSharing()
        CardOneMembersCollectionView.reloadData()
        
    }
    
    @objc func btn_CancelSharingCardTwo_Pressed(sender: UIButton) -> Void {
        
        cancelSharing()
        CardOneMembersCollectionView.reloadData()
        
    }
    
    private func cancelSharing() -> Void {
        
        if allShoppingLists[currentShoppingListIndex].members.count == 0 {
            
            let title = String.ListCurrentlyNotSharedTitle
            let message = String.ListCurrentlyNotSharedMessage
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
        
        if ShowBlurrView() {
            
            lbl_CancelSharing.text = String.lbl_CancelSharing
            CancelSharingPopUp.layer.shadowColor  = UIColor.black.cgColor
            CancelSharingPopUp.layer.shadowOffset  = CGSize(width: 30, height:30)
            CancelSharingPopUp.layer.shadowOpacity  = 1
            CancelSharingPopUp.layer.shadowRadius  = 10
            CancelSharingPopUp.frame.size.width = 300
            CancelSharingPopUp.center = view.center
            CancelSharingMemberCollectionView.reloadData()
            view.addSubview(CancelSharingPopUp)
            CancelSharingPopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
            
        }
        
    }
    
    @objc func btn_SaveList_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ListName.text, alertDelegate: self)
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_RelatedStore.text, alertDelegate: self)
        if isValid{
            sbListWebservice.SaveListToFirebaseDatabase(currentUser: currentUser!, listName: txt_ListName.text!, relatedStore: txt_RelatedStore.text!)
            HideAddListPopUp()
        }
    }
    //Shopping List Items
    @objc func btn_SaveItem_Pressed(sender: UIButton) -> Void {
        
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ItemName.text, alertDelegate: self)
        
        if isValid{
            
            var newListItem = ShoppingListItem()
            newListItem.itemName = txt_ItemName.text!
            newListItem.listID = allShoppingLists[currentShoppingListIndex].id!
            sbListItemWebservice.SaveListItemToFirebaseDatabase(listItem: newListItem, currentShoppingListIndex: currentShoppingListIndex)
            
            HideAddItemPopUp()
            
        }
        
    }
    
    @objc func btn_ShareListSave_Pressed(sender: UIButton) -> Void {
        
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .email, validationString: txt_ShareListOpponentEmail.text, alertDelegate: self)
        
        if isValid {
            
            let sbMessageService = ShoppingBuddyMessageWebservice()
            sbMessageService.alertMessageDelegate = self
            sbMessageService.activityAnimationServiceDelegate = self
            sbMessageService.SendFriendSharingInvitation(friendsEmail: txt_ShareListOpponentEmail.text!, list: allShoppingLists[currentShoppingListIndex], listOwner: currentUser!)
            HideShareListPopUp()
            
        }
        
    }
    
    @objc func btn_ShoppingCardShareList_Pressed(sender: UIButton) -> Void {
        ShowShareListPopUp()
    }
    
    @objc func btn_ShoppingCard2ShareList_Pressed(sender: UIButton) -> Void {
        ShowShareListPopUp()
    }
    
    @IBAction func btn_AddShoppingList_Pressed(_ sender: UIBarButtonItem) {
        ShowAddShoppingListPopUp()
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //MARK: Gesture Recognizers
    @objc func BlurrView_Tapped(sender: UITapGestureRecognizer) -> Void {
        HideAddListPopUp()
        HideShareListPopUp()
        CancelSharingPopUp.removeFromSuperview()
        ShoppingListDetailView.removeFromSuperview()
    }
    @objc func btn_CloseListDetailView_Pressed(sender: UIButton) -> Void {
        NotificationCenter.default.post(name: Notification.Name.PerformLocalShopSearch, object: nil, userInfo: nil)
        HideBlurrView()
        HideListDetailView()
        HideAddItemPopUp()
        RefreshCardView()
    }
    func AddItemBlurrView_Tapped(sender: UITapGestureRecognizer) -> Void {
        HideAddListPopUp()
    }
    @objc func AddItemPopUp_OutsideTouch(sender: UITapGestureRecognizer) -> Void {
        if view.subviews.contains(AddItemPopUp){
            AddItemPopUp.removeFromSuperview()
        }
    }
    @objc func AddShoppingListPopUp_OutsideTouch(sender: UITapGestureRecognizer) -> Void {
        if view.subviews.contains(AddShoppingListPopUp){
            AddShoppingListPopUp.removeFromSuperview()
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
    @objc func HandleShoppingItemPan(sender: UIPanGestureRecognizer) -> Void {
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
                let dropHeight = abs((ShoppingListDetailTableView.frame.height - swipeLocation.y) * 2.5)
                
                let rightDropLimit:CGFloat = 0.45
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
                TrashImage.alpha =  xPercentFromCenter >= rightDropLimit ? 1 : 0
                
                //Perform animations on gesture .ended state
                if panRecognizer.state == UIGestureRecognizerState.ended {
                    if xPercentFromCenter <= -leftDropLimit && isSelected! == false{
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
                    else if xPercentFromCenter >= rightDropLimit{
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
                    
                    self.RefreshCardView()
                    if allShoppingLists.isEmpty {
                        
                        self.TrashImage.alpha = 0
                        self.TrashImage.transform = .identity
                        
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
                
                let title = String.CancelSharingTitle
                let message = String.CancelSharingMessage
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
                
            }
        })
    }
    private func ResetCardAfterSwipeOff(card: UIView) -> Void {
        
        IncrementCurrentShoppingListIndex()
        self.RefreshCardView()
        
        TrashImage.alpha = 0
        TrashImage.transform = .identity
        card.alpha = 0
        card.center = self.view.center
        card.Arise(duration: 0.7, delay: 0, options: [.allowUserInteraction], toAlpha: 1)
        
        if currentUpperCard == 1{
            
            view.bringSubview(toFront: ShoppingListCard)
            ShoppingListCard2.transform = .identity
            ShoppingListCard2.transform = CGAffineTransform(rotationAngle: Double(8).degreesToRadians)
            
        } else {
            
            view.bringSubview(toFront: ShoppingListCard2)
            ShoppingListCard.transform = .identity
            ShoppingListCard.transform = CGAffineTransform(rotationAngle: Double(5).degreesToRadians)
            
        }
    }
    
    func RefreshCardView(){
        
        if currentShoppingListIndex >= allShoppingLists.count { currentShoppingListIndex = 0 }
        
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
    
    private func IncrementCurrentShoppingListIndex() -> Void {
        
        currentShoppingListIndex = currentShoppingListIndex >= allShoppingLists.count - 1 ?  0 : currentShoppingListIndex + 1
        
    }
    
    private func DecrementCurrentShoppingListIndex() -> Void {
        
        currentShoppingListIndex = currentShoppingListIndex == 0 ? allShoppingLists.count : currentShoppingListIndex - 1
        
    }
    
    internal func determineLowerCardIndex(currentUpperListIndex:Int) -> Int {
        
        var lowerCardIndex:Int = 0
        if allShoppingLists.count > 1 {
            
            lowerCardIndex = currentUpperListIndex == allShoppingLists.count - 1 ? 1 : currentUpperListIndex + 1
            
        } else {
            
            lowerCardIndex = currentUpperListIndex == allShoppingLists.count - 1 ? 0 : currentUpperListIndex + 1
            
        }
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
            
            OperationQueue.main.addOperation({
                self.ShoppingListOwnerImage.alpha = 1
                self.ShoppingListOwnerImage.image = allUsers[userIndex].profileImage
            })
            
        }
        OperationQueue.main.addOperation({
        self.CardOneMembersCollectionView.reloadData()
        self.SortShoppingListItemsArrayBy_isSelected()
        })
    }
    
    private func SetCardTwoValues(index: Int) -> Void{
        
        
        lbl_ShoppingListCard2Title.text = allShoppingLists[index].name!
        lbl_ShoppingCard2StoreName.text = allShoppingLists[index].relatedStore!
        lbl_ShoppingCard2TotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
        lbl_ShoppingCard2TotalItems.text = "\(allShoppingLists[index].items.count)"
        lbl_ShoppingCard2OpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
        lbl_ShoppingCard2OpenItems.text = "\(GetOpenItemsCount(shoppingItems: allShoppingLists[index].items))"
        
        if let userIndex = allUsers.index(where: { $0.id == allShoppingLists[index].owneruid }) {
            
            OperationQueue.main.addOperation({
                self.ShoppingListCard2OwnerImage.alpha = 1
                self.ShoppingListCard2OwnerImage.image = allUsers[userIndex].profileImage
            })
            
        }
        
        OperationQueue.main.addOperation({
            self.SortShoppingListItemsArrayBy_isSelected()
            self.CardTwoMembersCollectionView.reloadData()
        })
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
    @objc func KeyboardWillShow(sender: Notification) -> Void {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            AddItemPopUp.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
            AddShoppingListPopUp.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
            ShareListPopUp.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height * 0.33)
            
        }
        
    }
    @objc func KeyboardWillHide(sender: Notification) -> Void {
        
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
    
    @objc func ShowAddItemPopUp() -> Void{
        
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
        
        if allShoppingLists[currentShoppingListIndex].owneruid! != currentUser!.id! {
            let title = String.NotAllowedToShareListAlertTitle
            let message = String.NotAllowedToShareListAlertMessage
            self.ShowAlertMessage(title: title, message: message)
            return
        }
        
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
    
    func hideCanceSharingPopUp() -> Void {
        
        HideBlurrView()
        CancelSharingPopUp.removeFromSuperview()
        
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
        
        if allShoppingLists.isEmpty { return }
        
        if allShoppingLists[currentShoppingListIndex].items.isEmpty {
            
            self.ShoppingListDetailTableView.reloadData()
            return
            
        }
        
        allShoppingLists[self.currentShoppingListIndex].items.sort{ !$0.isSelected! && $1.isSelected! }
        self.ShoppingListDetailTableView.reloadData()
        
        
    }
    
    func GetOpenItemsCount(shoppingItems: [ShoppingListItem]) -> Int {
        
        return shoppingItems.filter({$0.isSelected! == false}).count
        
    }
    
    @objc func HideSharingInvitationNotification() -> Void {
        UIView.animate(withDuration: 1, animations: {
            self.InvitationNotification.center.y = -self.InvitationNotification.frame.size.height * 2 - self.topLayoutGuide.length
        }) { (true) in
            if self.view.subviews.contains(self.InvitationNotification) {
                self.InvitationNotification.removeFromSuperview()
            }
        }
    }
    
    @objc func PushNotificationReceived(notification: Notification) -> Void {
        
        guard let info = notification.userInfo else { return }
        
        guard let notificationTitle = info["notificationTitle"] as? String,
            let notificationMessage = info["notificationMessage"] as? String,
            let senderID = info["senderID"] as? String else { return }
        
        lbl_InviteTitle.text = notificationTitle
        txt_InviteMessage.text = notificationMessage
        
        if let index = allUsers.index(where: { $0.id == senderID } ) {
            
            if allUsers[index].profileImage! != #imageLiteral(resourceName: "userPlaceholder") {
                InviteUserImage.image = allUsers[index].profileImage!
                displayNotification()
            } else {
                
                let dpGroup = DispatchGroup()
                dpGroup.enter()
                
                let sbuserService = ShoppingBuddyUserWebservice()
                sbuserService.activityAnimationServiceDelegate = self
                sbuserService.alertMessageDelegate = self
                sbuserService.ObserveUser(userID: senderID)
                
                ShowSharingInvatationNotificationAfterImageDownload(url: URL(string: senderID)!)
                
                dpGroup.leave()
            }
            
        } else {
            
            let dpGroup = DispatchGroup()
            dpGroup.enter()
            
            let sbuserService = ShoppingBuddyUserWebservice()
            sbuserService.activityAnimationServiceDelegate = self
            sbuserService.alertMessageDelegate = self
            sbuserService.ObserveUser(userID: senderID)
            
            ShowSharingInvatationNotificationAfterImageDownload(url: URL(string: senderID)!)
            
            dpGroup.leave()
        }
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
            if let downloadImage = UIImage(data: data!) {
                self.InviteUserImage.image = downloadImage
                self.displayNotification()
                
            }
        }
        task.resume()
    }
    private func displayNotification() -> Void {
        
        //Invite Notification View
        InvitationNotification.center.x = view.center.x
        InvitationNotification.center.y = -InvitationNotification.frame.height
        InvitationNotification.layer.cornerRadius = 30
        InviteUserImage.layer.cornerRadius = InviteUserImage.frame.width * 0.5
        InviteUserImage.clipsToBounds = true
        InviteUserImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        InviteUserImage.layer.borderWidth = 3
        InvitationNotification.layer.shadowColor  = UIColor.black.cgColor
        InvitationNotification.layer.shadowOffset  = CGSize(width: 30, height:30)
        InvitationNotification.layer.shadowOpacity  = 1
        InvitationNotification.layer.shadowRadius  = 10
        
        let size = txt_InviteMessage.sizeThatFits(CGSize(width: txt_InviteMessage.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        InvitationNotification.frame.size.height = size.height + 50
        
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
        CardOneMembersCollectionView.delegate = self
        CardOneMembersCollectionView.dataSource = self
        CardTwoMembersCollectionView.delegate = self
        CardTwoMembersCollectionView.dataSource = self
        CancelSharingMemberCollectionView.dataSource = self
        CancelSharingMemberCollectionView.delegate = self
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileImageDownloadFinished), name: .UserProfileImageDownloadFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingBuddyListDataReceived), name: .ShoppingBuddyListDataReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListItemSaved), name: .ListItemSaved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListItemReceived), name: .ListItemReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PushNotificationReceived), name: .PushNotificationReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        
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
        btn_CancelSharingCardOne.addTarget(self, action: #selector(btn_CancelSharingCardOne_Pressed), for: .touchUpInside)
        btn_CancelSharingCardTwo.addTarget(self, action: #selector(btn_CancelSharingCardTwo_Pressed), for: .touchUpInside)
        
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
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.CardOneMembersCollectionView {
            
            let myCell = cell as! ListMembersCell
            myCell.MemberProfileImage.layer.cornerRadius = myCell.MemberProfileImage.frame.size.width * 0.5
            
        } else if collectionView == self.CardTwoMembersCollectionView{
            
            let myCell = cell as! ListMembersTwoCell
            myCell.MemberProfileImageTwo.layer.cornerRadius = myCell.MemberProfileImageTwo.frame.size.width * 0.5
            
        } else if collectionView == self.CancelSharingMemberCollectionView {
            
            let myCell = cell as! CancelSharingMemberCell
            myCell.MemberProfileImage.layer.cornerRadius = myCell.MemberProfileImage.frame.size.width * 0.5
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if allShoppingLists.isEmpty { return 0 }
        
        return allShoppingLists[currentShoppingListIndex].members.count
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.CardOneMembersCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.ListMemberCell_Identifier, for: indexPath) as! ListMembersCell
            
            if let index = allUsers.index(where: { $0.id == allShoppingLists[currentShoppingListIndex].members[indexPath.row].memberID }){
                
                cell.ConfigureCell(user: allUsers[index], member: allShoppingLists[currentShoppingListIndex].members[indexPath.row])
                
            } else {
                
                cell.MemberProfileImage.image = #imageLiteral(resourceName: "userPlaceholder")
                
            }
            
            return cell
            
        } else if collectionView == self.CardTwoMembersCollectionView {
            
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: String.ListMemberCell2_Identifier, for: indexPath) as! ListMembersTwoCell
            
            if let index = allUsers.index(where: { $0.id == allShoppingLists[currentShoppingListIndex].members[indexPath.row].memberID  }){
                
                cell2.ConfigureCell(user: allUsers[index], member: allShoppingLists[currentShoppingListIndex].members[indexPath.row])
                
            } else {
                
                cell2.MemberProfileImageTwo.image = #imageLiteral(resourceName: "userPlaceholder")
                
            }
            
            return cell2
            
        } else {
            
            let cell3 = collectionView.dequeueReusableCell(withReuseIdentifier: String.CancelSharingMemberCell_Identifier, for: indexPath) as! CancelSharingMemberCell
            
            if let index = allUsers.index(where: { $0.id == allShoppingLists[currentShoppingListIndex].members[indexPath.row].memberID  }){
                
                cell3.ConfigureCell(user: allUsers[index], member: allShoppingLists[currentShoppingListIndex].members[indexPath.row])
                
            } else {
                
                cell3.MemberProfileImage.image = #imageLiteral(resourceName: "userPlaceholder")
                
            }
            
            return cell3
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var widthPerItem:CGFloat
        var heightPerItem:CGFloat
        if collectionView == self.CardOneMembersCollectionView {
            
            widthPerItem = CardOneMembersCollectionView.frame.width / round(CardOneMembersCollectionView.frame.width / 60)
            heightPerItem = CardOneMembersCollectionView.frame.height / round(CardOneMembersCollectionView.frame.height / 60)
            
        } else {
            
            widthPerItem = CardTwoMembersCollectionView.frame.width / round(CardTwoMembersCollectionView.frame.width / 60)
            heightPerItem = CardTwoMembersCollectionView.frame.height / round(CardTwoMembersCollectionView.frame.height / 60)
            
        }
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.CancelSharingMemberCollectionView {
            
            
            var selectedUser:ShoppingBuddyUser
            if let index = allUsers.index(where: { $0.id! == allShoppingLists[currentShoppingListIndex].members[indexPath.row].memberID  } ){
                
                selectedUser = allUsers[index]
                
            } else { return }
            
            if isCurrentUserShoppingListOwner() {
                //Cancel Sharing By List Owner
                
                let title = String.CancelSharingSelectedMemberAlertTitle
                let message = String.CancelSharingSelectedMemberAlertMessage + selectedUser.nickname!
                let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
                    
                    self.sbListWebservice.CancelSharingByOwnerForUser(userToDelete:selectedUser, listToCancel: allShoppingLists[self.currentShoppingListIndex])
                    allShoppingLists[self.currentShoppingListIndex].members.remove(at: indexPath.row)
                    //collectionView.deleteItems(at: [indexPath])
                    self.CardOneMembersCollectionView.reloadData()
                    self.CardTwoMembersCollectionView.reloadData()
                    self.hideCanceSharingPopUp()
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
                    
                    self.hideCanceSharingPopUp()
                    
                }))
                
                present(alert, animated: true, completion: nil)
                
                
            }
            
        }
        
    }
    
    private func isCurrentUserShoppingListOwner() -> Bool {
        
        if allShoppingLists[currentShoppingListIndex].owneruid! == Auth.auth().currentUser!.uid { return true }
        else { return false }
        
    }
    
    private func isSelectedUserToCancelListOwner(indexPath: IndexPath) -> Bool {
        
        if allShoppingLists[currentShoppingListIndex].members[indexPath.row].memberID!  == Auth.auth().currentUser!.uid { return true }
        else { return false }
        
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
        
        if allShoppingLists.isEmpty { return 0 }
        
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
extension ShoppingListController: GADBannerViewDelegate {
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
