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

class ShoppingListController: UIViewController, IAlertMessageDelegate, IValidationService, UIGestureRecognizerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: - Outlets
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var BackgroundImage: UIImageView!
    @IBOutlet var ShoppingListDetailView: UIView!
    @IBOutlet var ListDetailBackgroundImage: UIImageView!
    @IBOutlet var AddShoppingListButton: UIBarButtonItem!
    @IBOutlet var btn_info: UIBarButtonItem!
    
    //List Detail PopUp
    @IBOutlet var btn_CloseListDetailView: UIButton!
    @IBOutlet var lbl_ShoppingListDetailTitle: UILabel!
    
    //DetailViewTableView
    @IBOutlet var ShoppingListDetailTableView: UITableView!
    @IBOutlet var CustomAddShoppingListRefreshControl: UIView!
    @IBOutlet var CustomAddShoppingListRefreshControlImage: UIImageView!
    @IBOutlet var DetailTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var EditListItemsTableViewRows: UIButton!
    @IBOutlet var txt_AddArticle: UITextField!
    
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
    @IBOutlet var lbl_ShoppingCardStoreName: UILabel!
    @IBOutlet var lbl_ShoppingCardTotalItemsLabel: UILabel!
    @IBOutlet var lbl_ShoppingCardTotalItems: UILabel!
    @IBOutlet var lbl_ShoppingCardOpenItemsLabel: UILabel!
    @IBOutlet var lbl_ShoppingCardOpenItems: UILabel!
    @IBOutlet var btn_ShoppingCardShareList: UIButton!
    @IBOutlet var ShoppingListOwnerImage: UIImageView!
    @IBOutlet var CardOneMembersCollectionView: UICollectionView!
    @IBOutlet var btn_CancelSharingCardOne: UIButton!
    @IBOutlet var btn_StoreCardOne: UIButton!
    @IBOutlet var CardOneListOwnerStarImage: UIImageView!
    @IBOutlet var btn_CardOneMessage: UIButton!
    
    
    //Shopping List Card2
    @IBOutlet var ShoppingListCard2: UIView!
    @IBOutlet var ShoppingListCard2Image: UIImageView!
    @IBOutlet var lbl_ShoppingListCard2Title: UILabel!
    @IBOutlet var ShoppingListCard2PanRecognizer: UIPanGestureRecognizer!
    @IBOutlet var ShoppingCard2TapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var lbl_ShoppingCard2StoreName: UILabel!
    @IBOutlet var lbl_ShoppingCard2TotalItemsLabel: UILabel!
    @IBOutlet var lbl_ShoppingCard2TotalItems: UILabel!
    @IBOutlet var lbl_ShoppingCard2OpenItemsLabel: UILabel!
    @IBOutlet var lbl_ShoppingCard2OpenItems: UILabel!
    @IBOutlet var btn_ShoppingCard2ShareList: UIButton!
    @IBOutlet var ShoppingListCard2OwnerImage: UIImageView!
    @IBOutlet var CardTwoMembersCollectionView: UICollectionView!
    @IBOutlet var btn_CancelSharingCardTwo: UIButton!
    @IBOutlet var btn_StoreCardTwo: UIButton!
    @IBOutlet var CardTwoListOwnerStarImage: UIImageView!
    @IBOutlet var btn_CardTwoMessage: UIButton!
    
    
    //Share List PopUp
    @IBOutlet var ShareListPopUp: UIView!
    @IBOutlet var lbl_ShareOpponentTitle: UILabel!
    @IBOutlet var txt_ShareListOpponentEmail: UITextField!
    @IBOutlet var btn_ShareListSave: UIButton!
    
    //Send Message Popup
    @IBOutlet var SendMessagePopUp: UIView!
    @IBOutlet var btn_SendMessagePopUp_HeadingToStore: UIButton!
    @IBOutlet var btn_SendMessagePopUp_ListChanged: UIButton!
    @IBOutlet var btn_SendMessagePopUp_DidTheShopping: UIButton!
    @IBOutlet var SendMessagePopUp_HeadingToStore_ProfileImage: UIImageView!
    @IBOutlet var SendMessagePopUp_HeadingToStore_StarImage: UIImageView!
    @IBOutlet var SendMessagePopUp_ListChanged_ProfileImage: UIImageView!
    @IBOutlet var SendMessagePopUp_ListChanged_StarImage: UIImageView!
    @IBOutlet var SendMessagePopUp_DidTheShopping_ProfileImage: UIImageView!
    @IBOutlet var SendMessagePopUp_DidTheShopping_StarImage: UIImageView!
    @IBOutlet var HeadingToStoreBubble: DesignableUIView!
    @IBOutlet var ListChangedBubble: DesignableUIView!
    @IBOutlet var txt_SendMessagePopUp_CustomMessage: UITextField!
    @IBOutlet var lbl_SendMessagePopUp: UILabel!
    
    
    //InviatationNotification
    @IBOutlet var InvitationNotification: UIView!
    @IBOutlet var lbl_InviteTitle: UILabel!
    @IBOutlet var txt_InviteMessage: UITextView!
    @IBOutlet var InviteUserImage: UIImageView!
    @IBOutlet var NotificationUserStarImage: UIImageView!
    
    //Cancel Sharing PopUp
    @IBOutlet var CancelSharingPopUp: UIView!
    @IBOutlet var CancelSharingMemberCollectionView: UICollectionView!
    @IBOutlet var lbl_CancelSharing: UILabel!
    
    //Onboarding image
    @IBOutlet var OnboardindInfoView: UIImageView!
    @IBOutlet var btn_LeftOnboarding: UIButton!
    
    
    
    //MARK:- Member
    var lastContentOffset:CGFloat = 0
    private var isInfoViewVisible:Bool!
    var timer:Timer!
    var blurrView:UIVisualEffectView?
    var blurrViewListItem:UIVisualEffectView?
    var blurrViewSendMessage:UIVisualEffectView?
    var refreshControl:UIRefreshControl!
    var swipedCellIndex:Int!
    var panRecognizer:UIPanGestureRecognizer!
    var currentShoppingListIndex:Int!
    var currentUpperCard:Int!
    var sbListWebservice:ShoppingBuddyListWebservice!
    var sbListItemWebservice: ShoppingBuddyListItemWebservice!
    var sbMessageWebService: ShoppingBuddyMessageWebservice!
    var bannerView:GADBannerView!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
        
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
    
    
    //MARK: - Notification listener selectors
    @objc func ShoppingBuddyListDataReceived() {
        
        //download user if unknown
        for list in allShoppingLists{
            
            if let _ = allUsers.index(where: { $0.id == list.owneruid }) {}
            else {
                
                //download user
                let sbUserService = ShoppingBuddyUserWebservice()
                sbUserService.alertMessageDelegate = self
                sbUserService.ObserveUser(userID: list.owneruid!, dlType: .DownloadForShoppingList)
                
            }
            
            for member in list.members {
                
                if let _ = allUsers.index(where: { $0.id == member.memberID }) {}
                else {
                    
                    //download user
                    let sbUserService = ShoppingBuddyUserWebservice()
                    sbUserService.alertMessageDelegate = self
                    sbUserService.ObserveUser(userID: member.memberID!, dlType: .DownloadForShoppingList)
                    
                }
                
            }
            
        }
        
        RefreshCardView()
        
    }
    
    
    func CurrentUserReceived(notification: Notification) -> Void {
        
        // userdata received so lets observe his lists
        //    sbListWebservice.ObserveAllList()
        
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
    //MARK: OnboardingView Pan
    @objc func OnboardingView_Pan(sender: UIPanGestureRecognizer) -> Void {
        let infoView = sender.view!
        let point = sender.translation(in: view)
        let xFromCenter = infoView.center.x - view.center.x
        let yFromCenter = infoView
            .center.y - view.center.y
        let swipeLimitLeft = view.frame.width * 0.4 // left border when the card gets animated off
        let swipeLimitRight = view.frame.width * 0.6 // right border when the card gets animated off
        let swipeLimitTop = view.frame.height * 0.5 // top border when the card gets animated off
        let swipeLimitBottom = view.frame.height * 0.65 // top border when the card gets animated off
        let ySpin:CGFloat = yFromCenter < 0 ? -200 : 200 // gives the card a spin in y direction
        let xSpin:CGFloat = xFromCenter < 0 ? -200 : 200 // gives the card a spin in x direction
        infoView.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        //Rotate card while drag
        let degree:Double = Double(xFromCenter / ((view.frame.size.width * 0.5) / 40))
        infoView.transform = CGAffineTransform(rotationAngle: degree.degreesToRadians)
        
      
        //Animate card after drag ended
        if sender.state == UIGestureRecognizerState.ended{
            let swipeDuration = 0.3
            // Move off to the left side if drag reached swipeLimitLeft
            if infoView.center.x < swipeLimitLeft{
                
                SwipeCardOffLeft(swipeDuration: swipeDuration, card: infoView, ySpin: ySpin)
                return
                
            } else if infoView.center.x > swipeLimitRight{
                
                SwipeCardOffRight(swipeDuration: swipeDuration, card: infoView, ySpin: ySpin)
                return
                
            } else if infoView.center.y < swipeLimitTop{
                
                SwipeCardOffTop(swipeDuration: swipeDuration, card: infoView, xSpin: xSpin)
                return
                
            } else if infoView.center.y > swipeLimitBottom {
                
                //Move downways if drag reached swipe limit bottom
                SwipeInfoViewOffBottom(swipeDuration: swipeDuration, card: infoView, xSpin: xSpin)
                return
                
            } else {
                
                // Reset card if no drag limit reached
                self.ResetInfoViewAfterSwipeOff(card: infoView as! UIImageView)
                
            }
        }
        
    }
    
    
    //MARK: - Wired Actions
    //MARK: Buttons
    @objc func btn_LeftOnboarding_Pressed(sender: UIButton) -> Void {
        print("predeeede")
    }
    @IBAction func btn_Info_Pressed(_ sender: UIBarButtonItem) {
        
        if isInfoViewVisible { hideInfoView() }
        else { showInfoView() }
        
    }
    private func showInfoView() -> Void {
        
        if !isInfoViewVisible {
            
            isInfoViewVisible = true
            
            OnboardindInfoView.image = UIImage(named: String.ShoppingListsOnboardiongImage)
            OnboardindInfoView.bounds = BackgroundImage.bounds
            OnboardindInfoView.alpha = 0
            OnboardindInfoView.isUserInteractionEnabled = true
            view.addSubview(OnboardindInfoView)
            OnboardindInfoView.center = BackgroundImage.center
            OnboardindInfoView.transform = CGAffineTransform(translationX: 0, y: view.frame.height).scaledBy(x: 0.1, y: 0.1)
            let onboardingPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(OnboardingView_Pan))
            OnboardindInfoView.addGestureRecognizer(onboardingPanRecognizer)
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                
                self.OnboardindInfoView.alpha = 1
                self.OnboardindInfoView.transform = .identity
                
            }, completion: nil )
            
        }
    }
    
    private func hideInfoView() -> Void {
        
        if isInfoViewVisible {
            
            isInfoViewVisible = false
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                
                self.OnboardindInfoView.alpha = 0
                self.OnboardindInfoView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
                
            }, completion: { (true) in
                
                if self.view.subviews.contains(self.OnboardindInfoView) {
                    self.OnboardindInfoView.removeFromSuperview()
                }
                
            })
        }
        
    }
    @objc func btn_CancelSharingCardOne_Pressed(sender: UIButton) -> Void {
        
        cancelSharing()
        CardOneMembersCollectionView.reloadData()
        
    }
    
    @objc func btn_CancelSharingCardTwo_Pressed(sender: UIButton) -> Void {
        
        cancelSharing()
        CardOneMembersCollectionView.reloadData()
        
    }
    
    private func cancelSharing() -> Void {
        
        //No members to cancel sharing
        if allShoppingLists[currentShoppingListIndex].members.count == 0 {
            
            let title = String.ListCurrentlyNotSharedTitle
            let message = String.ListCurrentlyNotSharedMessage
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
        
        //Cancel sharing directly in not list owner
        if allShoppingLists[currentShoppingListIndex].owneruid! != Auth.auth().currentUser!.uid {
            
            //Cancel sharing by list member - list member leaves group list
            
            // Ask user if user wants to leave the group list
            let title = String.LeaveGroupListAlertTitle
            let message = String.localizedStringWithFormat(String.LeaveGroupListAlertMessage , allShoppingLists[self.currentShoppingListIndex].name!)
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
                
                SoundPlayer.PlaySound(filename: "MailSent", filetype: "wav")
                self.sbListWebservice.CancelSharingBySharedUserForMember(member: currentUser!, listToCancel: allShoppingLists[self.currentShoppingListIndex])
                
                if let index = allShoppingLists[self.currentShoppingListIndex].members.index(where: { $0.memberID == currentUser!.id }) {
                    
                    allShoppingLists[self.currentShoppingListIndex].members.remove(at: index)
                    
                }
               
                //collectionView.deleteItems(at: [indexPath])
                self.CardOneMembersCollectionView.reloadData()
                self.CardTwoMembersCollectionView.reloadData()
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
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
    
    //MARK: Message Buttons
    @objc func btn_CardOneMessage_Pressed(sender: UIButton) -> Void {
        
        ShowSendMessagePopUp()
        
    }
    @objc func btn_CardTwoMessage_Pressed(sender: UIButton) -> Void {
        
        ShowSendMessagePopUp()
        
    }
    @objc func btn_SendMessagePopUp_HeadingToStore_Pressed(sender: UIButton) -> Void {
        
        guard let user = currentUser else { return }
        if !user.isFullVersionUser! {
            
            let title = String.FullVersionNeededAlertTitle
            let message = String.FullVersionNeededMessagesAlertMessage
            self.ShowAlertMessage(title: title, message: message)
            return
                
        }
        
        if allShoppingLists[currentShoppingListIndex].members.isEmpty {
            
            let title = String.MesageNotPossibleAlertTitle
            let message = String.MesageNotPossibleAlertMessage
            ShowAlertMessage(title: title, message: message)
            return
            
        }
        
        SoundPlayer.PlaySound(filename: "MailSent", filetype: "wav")
        sbMessageWebService.SendWillGoToStoreMessage(list: allShoppingLists[currentShoppingListIndex])
        HideSendMessageBlurrView()
        HideSendMessagePopUp()
        
    }
    @objc func btn_SendMessagePopUp_ListChanged_Pressed(sender: UIButton) -> Void {
        
        guard let user = currentUser else { return }
        if !user.isFullVersionUser! {
            
            let title = String.FullVersionNeededAlertTitle
            let message = String.FullVersionNeededMessagesAlertMessage
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
        
        if allShoppingLists[currentShoppingListIndex].members.isEmpty {
            
            let title = String.MesageNotPossibleAlertTitle
            let message = String.MesageNotPossibleAlertMessage
            ShowAlertMessage(title: title, message: message)
            return
            
        }
        
        SoundPlayer.PlaySound(filename: "MailSent", filetype: "wav")
        sbMessageWebService.SendChangedTheListMessage(list: allShoppingLists[currentShoppingListIndex])
        HideSendMessageBlurrView()
        HideSendMessagePopUp()
        
    }
    @objc func btn_SendMessagePopUp_DidTheShopping_Pressed(sender: UIButton) -> Void {
        
        guard let user = currentUser else { return }
        if !user.isFullVersionUser! {
            
            let title = String.FullVersionNeededAlertTitle
            let message = String.FullVersionNeededMessagesAlertMessage
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
        
        if allShoppingLists[currentShoppingListIndex].members.isEmpty {
            
            let title = String.MesageNotPossibleAlertTitle
            let message = String.MesageNotPossibleAlertMessage
            ShowAlertMessage(title: title, message: message)
            return
            
        }
        
        SoundPlayer.PlaySound(filename: "MailSent", filetype: "wav")
        sbMessageWebService.SendErrandsCompletedMessage(list: allShoppingLists[currentShoppingListIndex])
        HideSendMessageBlurrView()
        HideSendMessagePopUp()
        
    }
    
    //MARK: List actions
    @objc func btn_SaveList_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        
        //Validate FullVersion
        isValid = ValidationFactory.Validate(type: .fullVersionUser, validationString: "", alertDelegate: self)
        if !isValid && allShoppingLists.count >= 1 {
            let title = String.FullVersionNeededAlertTitle
            let message = String.FullVersionNeededListCountAlertMessage
            ShowAlertMessage(title: title, message: message)
            return
        }
        
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
        
        //Validate FullVersion
        isValid = ValidationFactory.Validate(type: .fullVersionUser, validationString: "", alertDelegate: self)
        if !isValid && allShoppingLists[currentShoppingListIndex].items.count >= 15 {
            let title = String.FullVersionNeededAlertTitle
            let message = String.FullVersionNeededArticleAlertMessage
            ShowAlertMessage(title: title, message: message)
            return
        }
        
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_AddArticle.text, alertDelegate: self)
        if isValid{
             
            var newListItem = ShoppingListItem()
            newListItem.itemName = txt_AddArticle.text!
            newListItem.listID = allShoppingLists[currentShoppingListIndex].id!
            sbListItemWebservice.SaveListItemToFirebaseDatabase(listItem: newListItem, currentShoppingListIndex: currentShoppingListIndex)
            
            HideAddItemPopUp()
            
        }
        
    }
    
    @objc func btn_ShareListSave_Pressed(sender: UIButton) -> Void {
        
        var isValid:Bool = false
        
        //Validate FullVersion
        isValid = ValidationFactory.Validate(type: .fullVersionUser, validationString: "", alertDelegate: self)
        if !isValid && allShoppingLists[currentShoppingListIndex].members.count >= 1 {
            let title = String.FullVersionNeededAlertTitle
            let message = String.FullVersionNeededSharingAlertMessage
            ShowAlertMessage(title: title, message: message)
            return
        }
        
        isValid = ValidationFactory.Validate(type: .email, validationString: txt_ShareListOpponentEmail.text, alertDelegate: self)
        if isValid {
            
            SoundPlayer.PlaySound(filename: "MailSent", filetype: "wav")
            let sbMessageService = ShoppingBuddyMessageWebservice()
            sbMessageService.alertMessageDelegate = self
            sbMessageService.SendFriendSharingInvitation(friendsEmail: txt_ShareListOpponentEmail.text!, list: allShoppingLists[currentShoppingListIndex], listOwner: currentUser!)
            HideShareListPopUp()
            
        }
        
    }
    
    @objc func btn_CloseListDetailView_Pressed(sender: UIButton) -> Void {
        
        NotificationCenter.default.post(name: Notification.Name.PerformLocalShopSearch, object: nil, userInfo: nil)
        HideBlurrView()
        HideListDetailView()
        HideAddItemPopUp()
        RefreshCardView()
        ShoppingListDetailTableView.isEditing = false
        
    }
    
    @objc func EditListItemsTableViewRows_Pressed(sender: UIButton) -> Void {
        
        if ShoppingListDetailTableView.isEditing {
            ShoppingListDetailTableView.isEditing  = false
            //Todo: edit lisitems sortnumber
            sbListWebservice.OrderShoppingListItems(list: allShoppingLists[currentShoppingListIndex])
        } else {
            ShoppingListDetailTableView.isEditing  = true
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
    
    @objc func btn_Store_Pressed(sender: UIButton) -> Void {
        /* not in use
        let sbMessageService = ShoppingBuddyMessageWebservice()
        sbMessageService.alertMessageDelegate = self
        sbMessageService.activityAnimationServiceDelegate = self
        sbMessageService.SendWillGoToStoreMessage(list: allShoppingLists[currentShoppingListIndex])
     */
        
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
    @objc func blurrViewListItem_Tapped(sender: UITapGestureRecognizer) -> Void {
        
        HideAddItemPopUp()
        
    }
    @objc func blurrViewSendMessage_Tapped(sender: UITapGestureRecognizer) -> Void {
        
        HideSendMessagePopUp()
        HideSendMessageBlurrView()
        
    }
    private func HideSendMessagePopUp() -> Void {
        
        txt_SendMessagePopUp_CustomMessage.text = ""
        SendMessagePopUp.removeFromSuperview()
        
        
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
                
                //Stop translation of cell at 25% movement over view
                //&& allow swipe left only on unselected items
                if abs(xPercentFromCenter) < rightDropLimit && velocity.x > 0 && isSelected! == false{
                    swipedCell.transform = CGAffineTransform(translationX: point.x, y: 0)
                }
                
                if abs(xPercentFromCenter) < leftDropLimit && velocity.x < 0 {
                    swipedCell.transform = CGAffineTransform(translationX: point.x, y: 0)
                }
                
                print(xPercentFromCenter)
                //image should be on top
                view.bringSubview(toFront: TrashImage)
                TrashImage.alpha =  xPercentFromCenter < -0.25 ? 1 : 0
                
                //image should be on top
                view.bringSubview(toFront: ShoppingCartImage)
                ShoppingCartImage.alpha =  xPercentFromCenter >= rightDropLimit && isSelected! == false ? 1 : 0
                
                //Perform animations on gesture .ended state
                if panRecognizer.state == UIGestureRecognizerState.ended {
                    if xPercentFromCenter <= -leftDropLimit {
                        //Shake Trash
                        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                            
                            self.TrashImage.transform = CGAffineTransform(translationX: -20, y: 0)
                            
                        })
                        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                            
                            swipedCell.transform = CGAffineTransform.init(translationX: -(self.view.frame.width * 0.35), y: dropHeight).rotated(by: -45).scaledBy(x: 0.3, y: 0.3)
                            
                        }, completion: { (true) in
                            
                            if let index = allShoppingLists.index(where: {$0.id == allShoppingLists[self.currentShoppingListIndex].id!}){
                                
                                if allShoppingLists[index].items.isEmpty { return }
                                SoundPlayer.PlaySound(filename: "pom", filetype: "wav")
                                self.sbListItemWebservice.DeleteShoppingListItemFromFirebase(itemToDelete: allShoppingLists[index].items[self.swipedCellIndex])
                                allShoppingLists[index].items.remove(at: self.swipedCellIndex)
                                self.ShoppingListDetailTableView.deleteRows(at: [swipedIndexPath], with: .none)
                                
                            }
                            
                            self.TrashImage.alpha = 0
                            self.TrashImage.transform = .identity
                            swipedCell.alpha = 0
                            swipedCell.transform = .identity
                            
                        })
                    } else if xPercentFromCenter >= rightDropLimit && isSelected! == false{
                        //Shake Cart
                        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                            
                            self.ShoppingCartImage.transform = CGAffineTransform(translationX: 20, y: 0)
                            
                        })
                        //Drop item to cart
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                            
                            swipedCell.transform = CGAffineTransform.init(translationX: self.view.frame.width * 0.8, y: dropHeight).rotated(by: 45).scaledBy(x: 0.3, y: 0.3)
                            
                        }, completion: { (true) in
                            
                            if allShoppingLists[self.currentShoppingListIndex].items.count > self.swipedCellIndex {
                                
                                SoundPlayer.PlaySound(filename: "drip", filetype: "wav")
                                allShoppingLists[self.currentShoppingListIndex].items[self.swipedCellIndex].isSelected = true
                                self.sbListItemWebservice.EditIsSelectedOnShoppingListItem(listItem: allShoppingLists[self.currentShoppingListIndex].items[self.swipedCellIndex])
                                
                            }
                            
                            self.ShoppingCartImage.alpha = 0
                            self.ShoppingCartImage.transform = .identity
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
        
        SoundPlayer.PlaySound(filename: "swoosh", filetype: "wav")
        
        UIView.animate(withDuration: swipeDuration, animations: {
            
            card.center.x = card.center.x - self.view.frame.size.width
            card.center.y = card.center.y + ySpin
            
        }, completion: { (true) in
            
            if card == self.OnboardindInfoView {
                
                self.ResetInfoViewAfterSwipeOff(card: card as! UIImageView)
                
            } else {
            
                self.ResetCardAfterSwipeOff(card: card)
                
            }
            
        })
    }
    private func SwipeCardOffRight(swipeDuration: TimeInterval, card: UIView, ySpin: CGFloat){
        
        SoundPlayer.PlaySound(filename: "swoosh", filetype: "wav")
        
        UIView.animate(withDuration: swipeDuration, animations: {
            
            card.center.x = card.center.x + self.view.frame.size.width
            card.center.y = card.center.y + ySpin
            
        }, completion: { (true) in
            
            if card == self.OnboardindInfoView {
                
                self.ResetInfoViewAfterSwipeOff(card: card as! UIImageView)
                
            } else {
                
                self.ResetCardAfterSwipeOff(card: card)
                
            }
            
        })
    }
    private func SwipeCardOffTop(swipeDuration: TimeInterval, card: UIView, xSpin: CGFloat){
        
        SoundPlayer.PlaySound(filename: "swoosh", filetype: "wav")
        
        UIView.animate(withDuration: swipeDuration, animations: {
            
            card.center.y = card.center.y - self.view.frame.size.height
            card.center.x = card.center.x + xSpin
            
        }, completion: { (true) in
            
            if card == self.OnboardindInfoView {
                
                self.ResetInfoViewAfterSwipeOff(card: card as! UIImageView)
                
            } else {
                
                self.ResetCardAfterSwipeOff(card: card)
                
            }
            
        })
    }
    private func SwipeInfoViewOffBottom(swipeDuration: TimeInterval, card: UIView, xSpin: CGFloat) -> Void{
        
         SoundPlayer.PlaySound(filename: "swoosh", filetype: "wav")
        
        
        UIView.animate(withDuration: swipeDuration, animations: {
            
            card.center.y = card.center.y + self.view.frame.size.height
            card.center.x = card.center.x + xSpin
            
        }, completion: { (true) in
            
            self.ResetInfoViewAfterSwipeOff(card: card as! UIImageView)
            
        })
    }
    private func SwipeCardOffBottom(swipeDuration: TimeInterval, card: UIView, xSpin: CGFloat) -> Void {
        
        SoundPlayer.PlaySound(filename: "swoosh", filetype: "wav")
        
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
                
                let title = String.ListDeleteNotAllowedAlertTitle
                let message = String.ListDeleteNotAllowedAlertMessage
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                self.TrashImage.alpha = 0
                self.TrashImage.transform = .identity
                
            }
        })
    }
    var infoviewCounter:Int = 0
    private func ResetInfoViewAfterSwipeOff(card: UIImageView) -> Void {
        
        if infoviewCounter == 0{
            
            infoviewCounter += 1
            card.image = UIImage(named: String.OnboardingListView)
            
        } else {
            
            infoviewCounter = 0
            card.image = UIImage(named: String.ShoppingListsOnboardiongImage)
            
        }
        
        card.alpha = 0
        card.transform = .identity
        card.center = view.center
        card.Arise(duration: 0.7, delay: 0, options:  [.allowUserInteraction], toAlpha: 1)
        
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
            
            if allUsers[userIndex].isFullVersionUser != nil {
                CardOneListOwnerStarImage.alpha = allUsers[userIndex].isFullVersionUser! ? 1 : 0
            } else {
                CardOneListOwnerStarImage.alpha = 0
            }
            
            OperationQueue.main.addOperation({
                self.ShoppingListOwnerImage.alpha = 1
                self.ShoppingListOwnerImage.layer.cornerRadius = self.ShoppingListOwnerImage.frame.width * 0.5
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
            
            if allUsers[userIndex].isFullVersionUser != nil {
                CardTwoListOwnerStarImage.alpha = allUsers[userIndex].isFullVersionUser! ? 1 : 0
            } else {
                CardTwoListOwnerStarImage.alpha = 0
            }
            
            OperationQueue.main.addOperation({
                self.ShoppingListCard2OwnerImage.alpha = 1
                self.ShoppingListCard2OwnerImage.layer.cornerRadius = self.ShoppingListCard2OwnerImage.frame.width * 0.5
                self.ShoppingListCard2OwnerImage.image = allUsers[userIndex].profileImage
            })
            
        }
        
        OperationQueue.main.addOperation({
            self.SortShoppingListItemsArrayBy_isSelected()
            self.CardTwoMembersCollectionView.reloadData()
        })
    }
    
    //MARK: - Textfield Delegate implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == UIReturnKeyType.done {
            
            var isValid:Bool = false
            //Validate FullVersion
            isValid = ValidationFactory.Validate(type: .fullVersionUser, validationString: "", alertDelegate: self)
            if !isValid && allShoppingLists[currentShoppingListIndex].items.count >= 15 {
                
                let title = String.FullVersionNeededAlertTitle
                let message = String.FullVersionNeededArticleAlertMessage
                ShowAlertMessage(title: title, message: message)
                self.view.endEditing(true)
                return true
                
            }
            
            isValid = ValidationFactory.Validate(type: .textField, validationString: txt_AddArticle.text, alertDelegate: self)
            if isValid{
                
                var newListItem = ShoppingListItem()
                newListItem.itemName = txt_AddArticle.text!
                newListItem.listID = allShoppingLists[currentShoppingListIndex].id!
                sbListItemWebservice.SaveListItemToFirebaseDatabase(listItem: newListItem, currentShoppingListIndex: currentShoppingListIndex)
                txt_AddArticle.text = ""
                self.view.endEditing(true)
                
            }
        }
        
        
        if textField.returnKeyType == UIReturnKeyType.send {
            
            guard let user = currentUser else { return true }
            if !user.isFullVersionUser! {
                
                let title = String.FullVersionNeededAlertTitle
                let message = String.FullVersionNeededMessagesAlertMessage
                self.ShowAlertMessage(title: title, message: message)
                self.view.endEditing(true)
                return true
                
            }
            
            if allShoppingLists[currentShoppingListIndex].members.isEmpty {
                
                let title = String.MesageNotPossibleAlertTitle
                let message = String.MesageNotPossibleAlertMessage
                ShowAlertMessage(title: title, message: message)
                self.view.endEditing(true)
                return true
                
            }
            
            if txt_SendMessagePopUp_CustomMessage == nil {
                return true
            }
            
            SoundPlayer.PlaySound(filename: "MailSent", filetype: "wav")
            sbMessageWebService.SendCustomMessage(message: txt_SendMessagePopUp_CustomMessage.text!, list: allShoppingLists[currentShoppingListIndex])
            HideSendMessageBlurrView()
            HideSendMessagePopUp()
            
        }
        
        self.view.endEditing(true)
        return true
        
    }
    
    //MARK: Keyboard Notification Listener targets
    @objc func KeyboardWillShow(sender: Notification) -> Void {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            var height = keyboardSize.height
            if height == 0 { height = 275 }
            
            AddItemPopUp.transform = CGAffineTransform(translationX: 0, y: -height * 0.33)
            AddShoppingListPopUp.transform = CGAffineTransform(translationX: 0, y: -height * 0.33)
            ShareListPopUp.transform = CGAffineTransform(translationX: 0, y: -height * 0.33)
            SendMessagePopUp.transform = CGAffineTransform(translationX: 0, y: -height * 0.33)
            
        }
        
    }
    @objc func KeyboardWillHide(sender: Notification) -> Void {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            AddItemPopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
            AddShoppingListPopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
            ShareListPopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
            SendMessagePopUp.transform = CGAffineTransform(translationX: 0, y: keyboardSize.height * 0.33)
        }
        
    }
    
    
    //MARK: - Helper Functions
    func ShowAddShoppingListPopUp() -> Void {
        
        if ShowBlurrView() {
            
            AddShoppingListPopUp.frame.size.width = 280
            AddShoppingListPopUp.center = view.center
            view.addSubview(AddShoppingListPopUp)
            AddShoppingListPopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
            
        }
        
    }
    
    @objc func ShowAddItemPopUp() -> Void{
        
        if showListItemBlurrView()  {
            
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
    
    func showListItemBlurrView() -> Bool {
        
        if blurrViewListItem == nil {
            
            blurrViewListItem = UIVisualEffectView()
            blurrViewListItem!.effect = UIBlurEffect(style: .light)
            blurrViewListItem!.bounds = view.bounds
            blurrViewListItem!.center = view.center
            let blurrViewListItemTap = UITapGestureRecognizer(target: self, action: #selector(blurrViewListItem_Tapped))
            blurrViewListItem!.addGestureRecognizer(blurrViewListItemTap)
            view.addSubview(blurrViewListItem!)
            return true
            
        }
        
        return false
    }
    
    func ShowSendMessagePopUp() -> Void {
        
        if showSendMessageBlurrView() {
            
            SendMessagePopUp_HeadingToStore_ProfileImage.image = currentUser?.profileImage != nil ? currentUser?.profileImage! : #imageLiteral(resourceName: "userPlaceholder")
            SendMessagePopUp_ListChanged_ProfileImage.image = currentUser?.profileImage != nil ? currentUser?.profileImage! : #imageLiteral(resourceName: "userPlaceholder")
            SendMessagePopUp_DidTheShopping_ProfileImage.image = currentUser?.profileImage != nil ? currentUser?.profileImage! : #imageLiteral(resourceName: "userPlaceholder")
            SendMessagePopUp_HeadingToStore_StarImage.alpha = currentUser!.isFullVersionUser! ? 1 :0
            SendMessagePopUp_ListChanged_StarImage.alpha = currentUser!.isFullVersionUser! ? 1 :0
            SendMessagePopUp_DidTheShopping_StarImage.alpha = currentUser!.isFullVersionUser! ? 1 :0
            
            SendMessagePopUp.frame.size.width = 300
            SendMessagePopUp.center = view.center
            view.addSubview(SendMessagePopUp)
            SendMessagePopUp.bringSubview(toFront:SendMessagePopUp_HeadingToStore_StarImage)
            SendMessagePopUp.bringSubview(toFront:SendMessagePopUp_ListChanged_StarImage)
            SendMessagePopUp.bringSubview(toFront:SendMessagePopUp_DidTheShopping_ProfileImage)
            SendMessagePopUp.bringSubview(toFront:SendMessagePopUp_DidTheShopping_StarImage)
            SendMessagePopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
            
        }
        
    }
    
    func showSendMessageBlurrView() -> Bool {
        
        if blurrViewSendMessage == nil {
            
            blurrViewSendMessage = UIVisualEffectView()
            blurrViewSendMessage!.effect = UIBlurEffect(style: .light)
            blurrViewSendMessage!.bounds = view.bounds
            blurrViewSendMessage!.center = view.center
            let blurrViewListItemTap = UITapGestureRecognizer(target: self, action: #selector(blurrViewSendMessage_Tapped))
            blurrViewSendMessage!.addGestureRecognizer(blurrViewListItemTap)
            view.addSubview(blurrViewSendMessage!)
            return true
            
        }
        
        return false
    }
    
    func HideSendMessageBlurrView() -> Void {
        
        blurrViewSendMessage?.removeFromSuperview()
        blurrViewSendMessage = nil
        
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
        
        //refreshControl.endRefreshing()
        if blurrViewListItem != nil {
            blurrViewListItem!.removeFromSuperview()
            blurrViewListItem = nil
        }
        
        txt_ItemName.text = ""
        AddItemPopUp.removeFromSuperview()
        
    }
    
    func ShowListDetailView() -> Void {
        
        if ShowBlurrView() {
            
            ShoppingListDetailView.frame.size.width = BackgroundImage.frame.width * 0.95
            ShoppingListDetailView.frame.size.height = BackgroundImage.frame.height
            ShoppingListDetailView.center = BackgroundImage.center 
            ShoppingListDetailTableView.delegate = self
            ShoppingListDetailTableView.dataSource = self
            
            lbl_ShoppingListDetailTitle.text = allShoppingLists[currentShoppingListIndex].name != nil ? allShoppingLists[currentShoppingListIndex].name : ""
            view.addSubview(ShoppingListDetailView)
            SortShoppingListItemsArrayBy_isSelected()
            
        }
        
    }
    
    func SortShoppingListItemsArrayBy_isSelected() -> Void {
        
        if allShoppingLists.isEmpty { return }
        
        if allShoppingLists[currentShoppingListIndex].items.isEmpty {
            
            self.ShoppingListDetailTableView.reloadData()
            return
            
        }
        
        allShoppingLists[self.currentShoppingListIndex].items.sort{ $0.sortNumber! < $1.sortNumber! }
        allShoppingLists[self.currentShoppingListIndex].items.sort{ !$0.isSelected! && $1.isSelected! } //&& $0.sortNumber! > $1.sortNumber!
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
                if allUsers[index].isFullVersionUser != nil  {
                    NotificationUserStarImage.alpha = allUsers[index].isFullVersionUser! ? 1 : 0
                } else { NotificationUserStarImage.alpha = 0}
                displayNotification()
                
            }
            
        }
    }
    
    private func displayNotification() -> Void {
        
        OperationQueue.main.addOperation {
            
            //Invite Notification View
            let size = self.txt_InviteMessage.sizeThatFits(CGSize(width: self.txt_InviteMessage.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            self.InvitationNotification.frame.size.height = size.height + self.lbl_InviteTitle.frame.height + 20
            self.InvitationNotification.center.x = self.view.center.x
            self.InvitationNotification.center.y = -self.InvitationNotification.frame.height
            self.InvitationNotification.layer.cornerRadius = 30
            self.InvitationNotification.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
            self.InvitationNotification.layer.borderWidth = 3
            self.InviteUserImage.layer.cornerRadius = self.InviteUserImage.frame.width * 0.5
            self.InviteUserImage.clipsToBounds = true
            self.InviteUserImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
            self.InviteUserImage.layer.borderWidth = 3
            self.InvitationNotification.layer.shadowColor  = UIColor.black.cgColor
            self.InvitationNotification.layer.shadowOffset  = CGSize(width: 30, height:30)
            self.InvitationNotification.layer.shadowOpacity  = 1
            self.InvitationNotification.layer.shadowRadius  = 10
            
            
            self.view.addSubview(self.InvitationNotification)
            self.InviteUserImage.layer.cornerRadius = self.InviteUserImage.frame.width * 0.5
            SoundPlayer.PlaySound(filename: "pling", filetype: "wav")
            UIView.animate(withDuration: 2) {
                
                self.InvitationNotification.transform = CGAffineTransform(translationX: 0, y: self.InvitationNotification.frame.size.height * 2 + self.topLayoutGuide.length)
                
            }
            
            self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.HideSharingInvitationNotification), userInfo: nil, repeats: false)
        }
        
    }
    
    
    
    func ConfigureView() -> Void {
        isInfoViewVisible = false
        currentShoppingListIndex = 0
        btn_info.tintColor = UIColor.ColorPaletteTintColor()
        
        //SetNavigationBar Title
        navigationItem.title = String.ShoppingListControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.ShoppingListControllerTitle
        
        //SHoppingBuddyListItemWebService
        sbListItemWebservice = ShoppingBuddyListItemWebservice()
        sbListItemWebservice.alertMessageDelegate = self
        
        //Firebase Shopping list
        sbListWebservice = ShoppingBuddyListWebservice()
        sbListWebservice.alertMessageDelegate = self
        
        if allShoppingLists.isEmpty {
            
            ShoppingListCard.alpha = 0
            ShoppingListCard2.alpha = 0
            
        }
        AddShoppingListButton.tintColor = UIColor.ColorPaletteTintColor()
        
        txt_AddArticle.placeholder = String.txt_AddArticle_PlaceHolder
        txt_AddArticle.delegate = self
        
        //Datasource & Delegate
        ShoppingListDetailTableView.dataSource = self
        ShoppingListDetailTableView.delegate = self
        ShoppingListDetailTableView.isEditing = false
        CardOneMembersCollectionView.delegate = self
        CardOneMembersCollectionView.dataSource = self
        CardTwoMembersCollectionView.delegate = self
        CardTwoMembersCollectionView.dataSource = self
        CancelSharingMemberCollectionView.dataSource = self
        CancelSharingMemberCollectionView.delegate = self
        
        /*
        //RefreshControl AddListItem
        refreshControl = UIRefreshControl() 
        refreshControl.alpha = 0
        refreshControl.addTarget(self, action: #selector(ShoppingListController.ShowAddItemPopUp), for: UIControlEvents.allEvents)
 
        
        if #available(iOS 10.0, *){
            ShoppingListDetailTableView.refreshControl = refreshControl
        } else {
            ShoppingListDetailTableView.addSubview(refreshControl)
        }*/
        
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
        AddShoppingListPopUp.layer.shadowOffset = CGSize(width: 30, height:30)
        AddShoppingListPopUp.layer.shadowOpacity  = 1
        AddShoppingListPopUp.layer.shadowRadius  = 10
        AddShoppingListPopUp.bringSubview(toFront: btn_SaveList)
        lbl_AddListPopUpTitle.text = String.lbl_AddListPopUpTitle
        
        //btn Message on Cards
        btn_CardOneMessage.addTarget(self, action: #selector(btn_CardOneMessage_Pressed), for: .touchUpInside)
        btn_CardTwoMessage.addTarget(self, action: #selector(btn_CardTwoMessage_Pressed), for: .touchUpInside)
        
        //txt Related STore
        txt_RelatedStore.delegate = self
        txt_RelatedStore.placeholder = String.txt_RelatedStore_Placeholder
        txt_RelatedStore.textColor = UIColor.black
        
        //txt List Name
        txt_ListName.delegate = self
        txt_ListName.placeholder = String.txt_ListName_Placeholder
        txt_ListName.textColor = UIColor.black
        btn_SaveList.addTarget(self, action: #selector(btn_SaveList_Pressed), for: .touchUpInside)
        
        //Detail ListView
        btn_CloseListDetailView.addTarget(self, action: #selector(btn_CloseListDetailView_Pressed), for: .touchUpInside)
        EditListItemsTableViewRows.tintColor = UIColor.ColorPaletteTintColor()
        EditListItemsTableViewRows.addTarget(self, action: #selector(EditListItemsTableViewRows_Pressed), for: .touchUpInside)
        
        //Shopping list Cards Shadows
        ShoppingListCard.layer.shadowColor  = UIColor.black.cgColor
        ShoppingListCard.layer.shadowOffset  = CGSize(width: 5, height:5)
        ShoppingListCard.layer.shadowOpacity  = 1
        ShoppingListCard.layer.shadowRadius  = 3
        
        
        ShoppingListCard2.layer.shadowColor  = UIColor.black.cgColor
        ShoppingListCard2.layer.shadowOffset  = CGSize(width: 5, height:5)
        ShoppingListCard2.layer.shadowOpacity  = 1
        ShoppingListCard2.layer.shadowRadius  = 3
        
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
        
        //Shopping bag image
        ShoppingCartImage.alpha = 0
        ShoppingCartImage.layer.shadowColor  = UIColor.black.cgColor
        ShoppingCartImage.layer.shadowOffset  = CGSize(width: 5, height:5)
        ShoppingCartImage.layer.shadowOpacity  = 1
        ShoppingCartImage.layer.shadowRadius  = 3
        
        //Trash image
        TrashImage.alpha = 0
        TrashImage.layer.shadowColor  = UIColor.black.cgColor
        TrashImage.layer.shadowOffset  = CGSize(width: 5, height:5)
        TrashImage.layer.shadowOpacity  = 1
        TrashImage.layer.shadowRadius  = 3
        
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
        CardOneListOwnerStarImage.alpha = 0
        
        ShoppingListOwnerImage.layer.cornerRadius = ShoppingListOwnerImage.frame.width * 0.5
        ShoppingListOwnerImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        ShoppingListOwnerImage.layer.borderWidth = 3
        CardTwoListOwnerStarImage.alpha = 0
        
        //Card One/Two Store Buttons
        btn_StoreCardOne.addTarget(self, action: #selector(btn_Store_Pressed), for: .touchUpInside)
        btn_StoreCardTwo.addTarget(self, action: #selector(btn_Store_Pressed), for: .touchUpInside)
        
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
        
        sbMessageWebService = ShoppingBuddyMessageWebservice()
        sbMessageWebService.alertMessageDelegate = self
        
        SendMessagePopUp.layer.shadowColor  = UIColor.black.cgColor
        SendMessagePopUp.layer.shadowOffset  = CGSize(width: 30, height:30)
        SendMessagePopUp.layer.shadowOpacity  = 1
        SendMessagePopUp.layer.shadowRadius  = 10
        
        lbl_SendMessagePopUp.text = String.lbl_SendMessagePopUp
        
        SendMessagePopUp_HeadingToStore_ProfileImage.layer.cornerRadius = SendMessagePopUp_HeadingToStore_ProfileImage.frame.width * 0.5
        SendMessagePopUp_HeadingToStore_ProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        SendMessagePopUp_HeadingToStore_ProfileImage.layer.borderWidth = 3
        SendMessagePopUp_HeadingToStore_StarImage.alpha = 0
        
        SendMessagePopUp_ListChanged_ProfileImage.layer.cornerRadius = SendMessagePopUp_ListChanged_ProfileImage.frame.width * 0.5
        SendMessagePopUp_ListChanged_ProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        SendMessagePopUp_ListChanged_ProfileImage.layer.borderWidth = 3
        SendMessagePopUp_ListChanged_StarImage.alpha = 0
        
        SendMessagePopUp_DidTheShopping_ProfileImage.layer.cornerRadius = SendMessagePopUp_DidTheShopping_ProfileImage.frame.width * 0.5
        SendMessagePopUp_DidTheShopping_ProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        SendMessagePopUp_DidTheShopping_ProfileImage.layer.borderWidth = 3
        SendMessagePopUp_DidTheShopping_StarImage.alpha = 0
        
        HeadingToStoreBubble.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        HeadingToStoreBubble.layer.borderWidth = 3
        
        ListChangedBubble.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        ListChangedBubble.layer.borderWidth = 3
        
        btn_SendMessagePopUp_ListChanged.setTitle(String.btn_SendMessagePopUp_ListChangedContent, for: .normal)
        btn_SendMessagePopUp_HeadingToStore.setTitle(String.btn_SendMessagePopUp_HeadingToStoreContent, for: .normal)
        btn_SendMessagePopUp_DidTheShopping.setTitle(String.btn_SendMessagePopUp_DidTheShoppingContent, for: .normal)
        
        btn_SendMessagePopUp_HeadingToStore.addTarget(self, action: #selector(btn_SendMessagePopUp_HeadingToStore_Pressed), for: .touchUpInside)
        btn_SendMessagePopUp_ListChanged.addTarget(self, action: #selector(btn_SendMessagePopUp_ListChanged_Pressed), for: .touchUpInside)
        btn_SendMessagePopUp_DidTheShopping.addTarget(self, action: #selector(btn_SendMessagePopUp_DidTheShopping_Pressed), for: .touchUpInside)
        
        txt_SendMessagePopUp_CustomMessage.placeholder = String.txt_SendMessagePopUp_CustomMessagePalceholder
        txt_SendMessagePopUp_CustomMessage.layer.cornerRadius = 10
        txt_SendMessagePopUp_CustomMessage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        txt_SendMessagePopUp_CustomMessage.layer.borderWidth = 3
        txt_SendMessagePopUp_CustomMessage.delegate = self
        
        
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
        
        widthPerItem = CardOneMembersCollectionView.frame.width / 4
        heightPerItem = CardOneMembersCollectionView.frame.width / 4
        
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
            
            if isCurrentUserShoppingListOwner() {
                
                //Cancel Sharing By List Owner
                guard let selectedUser = getSelectedUser(indexPath: indexPath) else { return }
                
                //Show message that this will cancel sharing with selected user
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
                
            } else {
                
                //Cancel sharing by list member - list member leaves group list
                guard let selectedUser = getSelectedUser(indexPath: indexPath) else { return }
                
                // Ask user if he wants to leave the group list
                let title = String.LeaveGroupListAlertTitle
                let message = String.LeaveGroupListAlertMessage + selectedUser.nickname!
                let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
                    
                    self.sbListWebservice.CancelSharingBySharedUserForMember(member: selectedUser, listToCancel: allShoppingLists[self.currentShoppingListIndex])
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
    
    private func getSelectedUser(indexPath: IndexPath) -> ShoppingBuddyUser? {
        
        if let index = allUsers.index(where: { $0.id! == allShoppingLists[currentShoppingListIndex].members[indexPath.row].memberID  } ){
            
            return allUsers[index]
            
        } else { return nil }
        
    }
    
    private func isCurrentUserShoppingListOwner() -> Bool {
        
        if allShoppingLists[currentShoppingListIndex].owneruid! == Auth.auth().currentUser!.uid { return true }
        else { return false }
        
    }
    
    private func isSelectedUserListOwner(indexPath: IndexPath) -> Bool {
        
        if allShoppingLists[currentShoppingListIndex].members[indexPath.row].memberID!  == Auth.auth().currentUser!.uid { return true }
        else { return false }
        
    }
}
extension Double {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}
extension ShoppingListController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    //MARK: UiScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffset < scrollView.contentOffset.y {
            //Moved up so hide txt_AddArticle
            txt_AddArticle.isHidden = true
            ShoppingListDetailTableView.translatesAutoresizingMaskIntoConstraints = false
            ShoppingListDetailTableView.frame.size.height = ShoppingListDetailView.frame.height * 0.69
        } else if self.lastContentOffset > scrollView.contentOffset.y {
            //Moved down so show txt_AddArticle
            txt_AddArticle.isHidden = false
            ShoppingListDetailTableView.translatesAutoresizingMaskIntoConstraints = false
            ShoppingListDetailTableView.frame.size.height = ShoppingListDetailView.frame.height * 0.625
        }
    }*/
    
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
        let dropHeight = abs((ShoppingListDetailTableView.frame.height))
        if allShoppingLists[currentShoppingListIndex].items.isEmpty { return }
        
        if allShoppingLists[self.currentShoppingListIndex].items[indexPath.row].isSelected! {
            
            SoundPlayer.PlaySound(filename: "drip", filetype: "wav")
            allShoppingLists[self.self.currentShoppingListIndex].items[indexPath.row].isSelected = false
            self.sbListItemWebservice.EditIsSelectedOnShoppingListItem(listItem: allShoppingLists[self.currentShoppingListIndex].items[indexPath.row])
            return
            
        }
        
        //Shake Cart
        ShoppingCartImage.alpha = 1
        view.bringSubview(toFront: ShoppingCartImage)
        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            
            self.ShoppingCartImage.transform = CGAffineTransform(translationX: 20, y: 0)
            
        })
        //Drop item to cart
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            
            tableView.cellForRow(at: indexPath)!.transform = CGAffineTransform.init(translationX: self.view.frame.width * 0.9, y: dropHeight).rotated(by: 45).scaledBy(x: 0.3, y: 0.3)
            SoundPlayer.PlaySound(filename: "drip", filetype: "wav")
            
        }, completion: { (true) in
            allShoppingLists[self.currentShoppingListIndex].items[indexPath.row].isSelected =  true
            self.sbListItemWebservice.EditIsSelectedOnShoppingListItem(listItem: allShoppingLists[self.currentShoppingListIndex].items[indexPath.row])
            
            self.ShoppingCartImage.alpha = 0
            self.ShoppingCartImage.transform = .identity
            tableView.cellForRow(at: indexPath)!.transform = .identity
            
        })
        
    }
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 10
    }*/
    // conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { 
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let itemToMove =  allShoppingLists[currentShoppingListIndex].items[sourceIndexPath.row]
        allShoppingLists[currentShoppingListIndex].items.remove(at: sourceIndexPath.row)
        allShoppingLists[currentShoppingListIndex].items.insert(itemToMove, at: destinationIndexPath.row)
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
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
