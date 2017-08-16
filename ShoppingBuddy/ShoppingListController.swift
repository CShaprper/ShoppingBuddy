//
//  ShoppingListController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import FirebaseAuth

class ShoppingListController: UIViewController, IFirebaseWebService, IValidationService, UIGestureRecognizerDelegate, UITextFieldDelegate, IShoppingBuddyListWebService {
    //MARK: - Outlets
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
    
    //Share List PopUp
    @IBOutlet var ShareListPopUp: UIView!
    @IBOutlet var lbl_ShareOpponentTitle: UILabel!
    @IBOutlet var txt_ShareListOpponentEmail: UITextField!
    @IBOutlet var btn_ShareListSave: UIButton!
    
    //MARK:- Member
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var blurrView:UIVisualEffectView?
    //var firebaseWebService:FirebaseWebService!
    var SelectedList:ShoppingList?
    var shoppingList:ShoppingList!
    var refreshControl:UIRefreshControl!
    var refreshShoppingListControl:UIRefreshControl!
    var swipedCellIndex:Int!
    var panRecognizer:UIPanGestureRecognizer!
    var currentUpperCardIndex:Int!
    var currentUpperCard:Int!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubview(toFront: TrashImage)
    }
    //MARK: - IFirebaseWebService implementation
    func ShoppingBuddyListDataReceived() {
        ShoppingListDetailTableView.reloadData()
        RefreshCardView()
        ShoppingListCard.alpha = 1
        ShoppingListCard2.alpha = 1
    }
    
    //MARK: - IFirebaseWebService implementation
    func FirebaseRequestStarted() { }
    func FirebaseRequestFinished() {
        ShoppingListDetailTableView.reloadData()
        RefreshCardView()
        ShoppingListCard.alpha = 1
        ShoppingListCard2.alpha = 1
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
        HideShareListPopUp()
        ShoppingListDetailView.removeFromSuperview()
    }
    func btn_SaveList_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ListName.text, alertDelegate: self)
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_RelatedStore.text, alertDelegate: self)
        if isValid{
            shoppingList.SaveListToFirebaseDatabase(listName: txt_ListName.text!, relatedStore: txt_RelatedStore.text!)
            HideAddListPopUp()
        }
    }
    @IBAction func btn_AddShoppingList_Pressed(_ sender: UIBarButtonItem) {
        ShowAddShoppingListPopUp()
    }
    func btn_CloseListDetailView_Pressed(sender: UIButton) -> Void {
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
    func btn_SaveItem_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .textField, validationString: txt_ItemName.text, alertDelegate: self)
        if isValid{
            let listItem = ShoppingListItem()
            listItem.alertMessageDelegate = self
            listItem.firebaseWebServiceDelegate = self
            listItem.SaveListItemToFirebaseDatabase(shoppingList: SelectedList!, itemName: txt_ItemName.text!)
            HideAddItemPopUp()
        }
    }
    func btn_ShareListSave_Pressed(sender: UIButton) -> Void {
        var isValid:Bool = false
        isValid = ValidationFactory.Validate(type: .email, validationString: txt_ShareListOpponentEmail.text, alertDelegate: self)
        if isValid {
            let fbUser = FirebaseUser()
            fbUser.alertMessageDelegate = self
            fbUser.firebaseWebServiceDelegate = self
            fbUser.SearchUserByEmail(listID: SelectedList!.ID!, email: txt_ShareListOpponentEmail.text!)
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
                let isSelected =  SelectedList!.ItemsArray![self.swipedCellIndex].isSelected
                
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
                                    let listItem = ShoppingListItem()
                                    listItem.alertMessageDelegate  = self
                                    listItem.firebaseWebServiceDelegate = self
                                    listItem.EditIsSelectedOnShoppingListItem(listOwnerID: ShoppingListsArray[index].OwnerID!, shoppingListItem: ShoppingListsArray[index].ItemsArray![self.swipedCellIndex])
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
                                        let listItem = ShoppingListItem()
                                        listItem.alertMessageDelegate  = self
                                        listItem.firebaseWebServiceDelegate = self
                                        listItem.DeleteShoppingListItemFromFirebase(list: ShoppingListsArray[index], itemToDelete: ShoppingListsArray[index].ItemsArray![self.swipedCellIndex])
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
                currentUpperCard = 2
                SwipeCardOffLeft(swipeDuration: swipeDuration, card: note, ySpin: ySpin, bringCardToFront: 2)
                return
            } else if note.center.x > swipeLimitRight{
                //Move off to the right side if drag reached swipeLimitRight
                currentUpperCard = 2
                SwipeCardOffRight(swipeDuration: swipeDuration, card: note, ySpin: ySpin, bringCardToFront: 2)
                return
            } else if note.center.y < swipeLimitTop{
                //Move off the top side if drag reached swipeLimitTop
                currentUpperCard = 2
                SwipeCardOffTop(swipeDuration: swipeDuration, card: note, xSpin: xSpin, bringCardToFront: 2)
                return
            } else if note.center.y > swipeLimitBottom {
                //Move downways if drag reached swipe limit bottom
                SwipeCardOffBottom(swipeDuration: swipeDuration, card: note, xSpin: xSpin, bringCardToFront: 2)
                return
            } else {
                // Reset card if no drag limit reached
                currentUpperCard = 1
                self.ResetCardAfterSwipeOff(card: note, bringCardToFront: 1)
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
                // Move off to the left side if drag reached swipeLimitLeft
                currentUpperCard = 1
                SwipeCardOffLeft(swipeDuration: swipeDuration, card: note, ySpin: ySpin, bringCardToFront: 1)
                return
            } else if note.center.x > swipeLimitRight{
                //Move off to the right side if drag reached swipeLimitRight
                currentUpperCard = 1
                SwipeCardOffRight(swipeDuration: swipeDuration, card: note, ySpin: ySpin, bringCardToFront: 1)
                return
            } else if note.center.y < swipeLimitTop{
                //Move off the top side if drag reached swipeLimitTop
                currentUpperCard = 1
                SwipeCardOffTop(swipeDuration: swipeDuration, card: note, xSpin: xSpin, bringCardToFront: 1)
                return
            } else if note.center.y > swipeLimitBottom {
                //Move downways if drag reached swipe limit bottom
                currentUpperCard = 1
                SwipeCardOffBottom(swipeDuration: swipeDuration, card: note, xSpin: xSpin, bringCardToFront: 1)
                return
            } else {
                // Reset card if no drag limit reached
                currentUpperCard = 2
                self.ResetCardAfterSwipeOff(card: note, bringCardToFront: 2)
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
    private func SwipeCardOffLeft(swipeDuration: TimeInterval, card: UIView, ySpin: CGFloat, bringCardToFront: Int){
        UIView.animate(withDuration: swipeDuration, animations: {
            card.center.x = card.center.x - self.view.frame.size.width
            card.center.y = card.center.y + ySpin
        }, completion: { (true) in
            //Card arise in Center for new view
            self.ResetCardAfterSwipeOff(card: card, bringCardToFront: bringCardToFront)
            self.SetNewCardProdcutAfterSwipe(card: card, bringCardToFront: bringCardToFront)
        })
    }
    private func SwipeCardOffRight(swipeDuration: TimeInterval, card: UIView, ySpin: CGFloat, bringCardToFront: Int){
        UIView.animate(withDuration: swipeDuration, animations: {
            card.center.x = card.center.x + self.view.frame.size.width
            card.center.y = card.center.y + ySpin
        }, completion: { (true) in
            //Card arise in Center for new view
            self.ResetCardAfterSwipeOff(card: card, bringCardToFront: bringCardToFront)
            self.SetNewCardProdcutAfterSwipe(card: card, bringCardToFront: bringCardToFront)
        })
    }
    private func SwipeCardOffTop(swipeDuration: TimeInterval, card: UIView, xSpin: CGFloat, bringCardToFront: Int){
        UIView.animate(withDuration: swipeDuration, animations: {
            card.center.y = card.center.y - self.view.frame.size.height
            card.center.x = card.center.x + xSpin
        }, completion: { (true) in
            //Card arise in Center for new view
            self.ResetCardAfterSwipeOff(card: card, bringCardToFront: bringCardToFront)
            self.SetNewCardProdcutAfterSwipe(card: card, bringCardToFront: bringCardToFront)
        })
    }
    private func SwipeCardOffBottom(swipeDuration: TimeInterval, card: UIView, xSpin: CGFloat, bringCardToFront: Int){
        UIView.animate(withDuration: swipeDuration, animations: {
            card.center.y = card.center.y + self.view.frame.size.height
            card.center.x = card.center.x + xSpin
        }, completion: { (true) in
            //Card arise in Center for new view
            if self.SelectedList!.OwnerID == Auth.auth().currentUser!.uid{
                self.shoppingList.DeleteShoppingListFromFirebase(listToDelete: self.SelectedList!)
                self.ResetCardAfterSwipeOff(card: card, bringCardToFront: bringCardToFront)
                self.SetNewCardProdcutAfterSwipe(card: card, bringCardToFront: bringCardToFront)
            } else {
                let title = "Permission Denied"
                let message = "Your are not allowed to delete your own lists!"
                self.ShowAlertMessage(title: title, message: message)
                self.ResetCardAfterSwipeOff(card: card, bringCardToFront: bringCardToFront)
                self.SetNewCardProdcutAfterSwipe(card: card, bringCardToFront: bringCardToFront)
            }
        })
    }
    private func ResetCardAfterSwipeOff(card: UIView, bringCardToFront: Int){
        TrashImage.alpha = 0
        TrashImage.transform = .identity
        card.alpha = 0
        card.center = self.view.center
        card.Arise(duration: 0.7, delay: 0, options: [.allowUserInteraction], toAlpha: 1)
        if bringCardToFront == 1{
            view.bringSubview(toFront: ShoppingListCard)
            ShoppingListCard2.transform = .identity
            ShoppingListCard2.transform = CGAffineTransform(rotationAngle: Double(8).degreesToRadians)
        } else {
            view.bringSubview(toFront: ShoppingListCard2)
            ShoppingListCard.transform = .identity
            ShoppingListCard.transform = CGAffineTransform(rotationAngle: Double(5).degreesToRadians)
        }
    }
    private func SetNewCardProdcutAfterSwipe(card: UIView, bringCardToFront: Int){
        if ShoppingListsArray.count == 0 { return }
        currentUpperCardIndex = currentUpperCardIndex >= ShoppingListsArray.count - 1 ?  0 : currentUpperCardIndex + 1
        SelectedList = ShoppingListsArray[currentUpperCardIndex]
        
        NSLog("Shopping list array Count \(ShoppingListsArray.count)")
        NSLog("Current upper Card Index \(currentUpperCardIndex)")
        NSLog("Current List Title \(ShoppingListsArray[currentUpperCardIndex].Name!)")
        if ShoppingListsArray.count == 1 {
            SetCardOneValues(index: 0)
            SetCardTwoValues(index: 0)
        } else {
            if bringCardToFront == 1
            {
                let lowerCardIndex = currentUpperCardIndex == ShoppingListsArray.count - 1 ? 1 : currentUpperCardIndex + 1
                SetCardOneValues(index: currentUpperCardIndex!)
                SetCardTwoValues(index: lowerCardIndex)
            }
            else
            {
                let lowerCardIndex = currentUpperCardIndex == ShoppingListsArray.count - 1 ? 1 : currentUpperCardIndex + 1
                SetCardOneValues(index: lowerCardIndex)
                SetCardTwoValues(index: currentUpperCardIndex!)
            }
        }
    }
    func RefreshCardView(){
        if ShoppingListsArray.count == 0 { return }
        if ShoppingListsArray.count == 1{
            SelectedList = ShoppingListsArray[0]
            SetCardOneValues(index: 0)
            SetCardTwoValues(index: 0)
        } else {
            SelectedList = ShoppingListsArray[currentUpperCardIndex]
        }
    }
    private func SetCardOneValues(index: Int) -> Void{
        lbl_ShoppingListCardTitle.text = ShoppingListsArray[index].Name!
        lbl_ShoppingCardStoreName.text = ShoppingListsArray[index].RelatedStore!
        lbl_ShoppingCardTotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
        lbl_ShoppingCardTotalItems.text = "\(ShoppingListsArray[index].ItemsArray!.count)"
        lbl_ShoppingCardOpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
        lbl_ShoppingCardOpenItems.text = "\(GetOpenItemsCount(shoppingItems: ShoppingListsArray[index].ItemsArray!))"
    }
    
    private func SetCardTwoValues(index: Int) -> Void{
        lbl_ShoppingListCard2Title.text = ShoppingListsArray[index].Name!
        lbl_ShoppingCard2StoreName.text = ShoppingListsArray[index].RelatedStore!
        lbl_ShoppingCard2TotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
        lbl_ShoppingCard2TotalItems.text = "\(ShoppingListsArray[index].ItemsArray!.count)"
        lbl_ShoppingCard2OpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
        lbl_ShoppingCard2OpenItems.text = "\(GetOpenItemsCount(shoppingItems: ShoppingListsArray[index].ItemsArray!))"
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
    func ShowShareListPopUp(){
        if ShowBlurrView(){
            ShareListPopUp.frame.size.width = 280
            ShareListPopUp.center = view.center
            view.addSubview(ShareListPopUp)
            ShareListPopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
        }
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
        ShoppingListDetailView.removeFromSuperview()
    }
    func HideAddListPopUp() -> Void {
        HideBlurrView()
        txt_ListName.text = ""
        txt_RelatedStore.text = ""
        AddShoppingListPopUp.removeFromSuperview()
    }
    func HideShareListPopUp(){
        HideBlurrView()
        ShareListPopUp.removeFromSuperview()
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
    func GetOpenItemsCount(shoppingItems: [ShoppingListItem]) -> Int{
        return shoppingItems.filter({$0.isSelected! == "false"}).count
    }
    func ConfigureView() -> Void {
        shoppingList = ShoppingList()
        shoppingList.alertMessageDelegate = self
        shoppingList.shoppingBuddyListWebServiceDelegate = self
        
        if ShoppingListsArray.count == 0{
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
        currentUpperCardIndex = 0
        currentUpperCard = 1
        
        btn_ShoppingCardShareList.addTarget(self, action: #selector(btn_ShoppingCardShareList_Pressed), for: .touchUpInside)
        btn_ShoppingCard2ShareList.addTarget(self, action: #selector(btn_ShoppingCard2ShareList_Pressed), for: .touchUpInside)
        
        if ShoppingListsArray.count > 1{
            SelectedList = ShoppingListsArray[0]
            lbl_ShoppingListCardTitle.text = ShoppingListsArray[0].Name!
            lbl_ShoppingCardStoreName.text = ShoppingListsArray[0].RelatedStore!
            lbl_ShoppingCardTotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
            lbl_ShoppingCardTotalItems.text = "\(ShoppingListsArray[0].ItemsArray!.count)"
            lbl_ShoppingCardOpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
            lbl_ShoppingCardOpenItems.text = "\(GetOpenItemsCount(shoppingItems: ShoppingListsArray[0].ItemsArray!))"
            
            lbl_ShoppingListCard2Title.text = ShoppingListsArray[1].Name!
            lbl_ShoppingCard2StoreName.text = ShoppingListsArray[1].RelatedStore!
            lbl_ShoppingCard2TotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
            lbl_ShoppingCard2TotalItems.text = "\(ShoppingListsArray[1].ItemsArray!.count)"
            lbl_ShoppingCard2OpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
            lbl_ShoppingCard2OpenItems.text = "\(GetOpenItemsCount(shoppingItems: ShoppingListsArray[1].ItemsArray!))"
            
        } else if ShoppingListsArray.count == 1 {
            SelectedList = ShoppingListsArray[0]
            lbl_ShoppingListCardTitle.text = ShoppingListsArray[0].Name!
            lbl_ShoppingCardStoreName.text = ShoppingListsArray[0].RelatedStore!
            lbl_ShoppingCardTotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
            lbl_ShoppingCardTotalItems.text = "\(ShoppingListsArray[0].ItemsArray!.count)"
            lbl_ShoppingCardOpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
            lbl_ShoppingCardOpenItems.text = "\(GetOpenItemsCount(shoppingItems: ShoppingListsArray[0].ItemsArray!))"
            
            lbl_ShoppingListCard2Title.text = ShoppingListsArray[0].Name!
            lbl_ShoppingCard2StoreName.text = ShoppingListsArray[0].RelatedStore!
            lbl_ShoppingCard2TotalItemsLabel.text = String.lbl_ShoppingCardTotalItems_Label
            lbl_ShoppingCard2TotalItems.text = "\(ShoppingListsArray[0].ItemsArray!.count)"
            lbl_ShoppingCard2OpenItemsLabel.text = String.lbl_ShoppingCardOpenItems_Label
            lbl_ShoppingCard2OpenItems.text = "\(GetOpenItemsCount(shoppingItems: ShoppingListsArray[0].ItemsArray!))"
        }
    }
}
extension Double {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
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
                    let listItem = ShoppingListItem()
                    listItem.alertMessageDelegate = self
                    listItem.firebaseWebServiceDelegate = self
                    listItem.EditIsSelectedOnShoppingListItem(listOwnerID: SelectedList!.OwnerID!, shoppingListItem: ShoppingListsArray[index].ItemsArray![indexPath.row])
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
