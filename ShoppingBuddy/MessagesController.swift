//
//  MessagesControllerViewController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 30.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MessagesController: UIViewController, IAlertMessageDelegate, UITextFieldDelegate {
    //MARK: - Outlets
    @IBOutlet var BackgroundImage: UIImageView!
    @IBOutlet var InvitationsTableView: UITableView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var txt_SendAnswer: UITextField!
    
    private var blurrView:UIVisualEffectView!
    internal var sbUserService:ShoppingBuddyUserWebservice!
    internal var sbMessageWebservice:ShoppingBuddyMessageWebservice!
    var bannerView:GADBannerView!
    var selectedMessage:ShoppingBuddyMessage!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SetNavigationBar Title
        navigationItem.title = String.MessagesControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.MessagesControllerTitle
        
        //NotificationListener
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileImageDownloadFinished), name: NSNotification.Name.UserProfileImageDownloadFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AllInvitesReceived), name: NSNotification.Name.AllInvitesReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SharingInviteReceived), name: NSNotification.Name.SharingInviteReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
        //sbMessageWebservice
        sbMessageWebservice = ShoppingBuddyMessageWebservice()
        sbMessageWebservice.alertMessageDelegate = self
        sbMessageWebservice.ObserveAllMessages()
        
        //sbUserWebservice
        sbUserService = ShoppingBuddyUserWebservice()
        sbUserService.alertMessageDelegate = self
        
        InvitationsTableView.rowHeight = UITableViewAutomaticDimension
        InvitationsTableView.estimatedRowHeight = 100
        
        txt_SendAnswer.delegate = self
        txt_SendAnswer.alpha = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for msg in allMessages {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.YYYY HH:mm"
            if let d = formatter.date(from: msg.date!){
                
                if let date = Calendar.current.date(byAdding: .day, value: 7, to: d) {
                   
                    if date > Date() {
                        
                        sbMessageWebservice.DeleteMessage(messageID: msg.id!)
                        
                    }
                    
                }
                
            }
        }
        
        DispatchQueue.main.async {
            self.InvitationsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Textfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .send {
            var isValid:Bool
            isValid = ValidationFactory.Validate(type: .textField, validationString: txt_SendAnswer.text, alertDelegate: self)
            if isValid {
                
                if let index = allShoppingLists.index(where: { $0.id == selectedMessage.listID }) {
                    
                    sbMessageWebservice.SendCustomMessage(message: txt_SendAnswer.text!, list: allShoppingLists[index])
                    SoundPlayer.PlaySound(filename: "MailSent", filetype: "wav")
                    
                }
                
            }
        }
        
        self.view.endEditing(true)
        return true
    }
    
    @objc func KeyboardDidShow(sender: Notification) -> Void {
        
        if let userInfo = sender.userInfo, let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrameValue.cgRectValue
            var height = keyboardRect.height
            if height == 0 { height = 268 }
            
            txt_SendAnswer.transform = CGAffineTransform(translationX: 0, y: CGFloat(height) * CGFloat(-1) + (self.tabBarController?.tabBar.frame.size.height)!)
        }        
        
        
    }
    
    
    @objc func KeyboardWillHide(sender: Notification) -> Void {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            var height = keyboardSize.height
            if height == 0 { height = 268 }
            
            txt_SendAnswer.transform = CGAffineTransform(translationX: 0, y: height + (self.tabBarController?.tabBar.frame.size.height)!)
            txt_SendAnswer.alpha = 0
            
        } else {
            
            let height:CGFloat = 268
            txt_SendAnswer.transform = CGAffineTransform(translationX: 0, y: height)
            txt_SendAnswer.alpha = 0
            
        }
        
    }
    
    //MARK: - IAlertMessageDelegate
    func ShowAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)

        
    }
    
    //MARK: - Notification listener selectors
    @objc func AllInvitesReceived(notification: Notification) -> Void {
        
        for msg in allMessages{
            
            if let _ = allUsers.index(where: { $0.id == msg.senderID }){ }
            else {  sbUserService.ObserveUser(userID: msg.senderID!, dlType: .DownloadForMessagesController) }
            
        }
        DispatchQueue.main.async {
            self.InvitationsTableView.reloadData()
        }
        
    }
    
    @objc func SharingInviteReceived(notification: Notification) -> Void {
        
        
    }
    
    @objc func UserProfileImageDownloadFinished(notification: Notification) -> Void {
        
        DispatchQueue.main.async {
            self.InvitationsTableView.reloadData()
        }
        
    }
}

extension MessagesController: UITableViewDelegate, UITableViewDataSource{
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.InvitationCell_Identifier, for: indexPath) as! ShoppingBuddyInvitationCell
        
        let invite = allMessages[indexPath.row]
        
        cell.ConfigureCell(invitation: invite)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedMessage = allMessages[indexPath.row]
        if let index = allUsers.index(where: { $0.id == selectedMessage.senderID }){
            
            txt_SendAnswer.placeholder = String.localizedStringWithFormat(String.txt_SendAnswerPlaceholder,  allUsers[index].nickname!)
            
        } else {
            
            txt_SendAnswer.placeholder = String.localizedStringWithFormat(String.txt_SendAnswerPlaceholder,  "user")
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.txt_SendAnswer.alpha = 1
        }, completion: nil)
        
        txt_SendAnswer.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if allMessages[indexPath.row].messageType == eNotificationType.SharingInvitation.rawValue {
            //Set tableview buttons for Sharing Invites
            let accept = UITableViewRowAction(style: .normal, title: String.AcceptInvitation) { (action, index) in
                
                self.sbMessageWebservice.AcceptInvitation(invitation: allMessages[indexPath.row])
                tableView.setEditing(false, animated: true)
                
            }
            accept.backgroundColor = UIColor.green
            
            let decline = UITableViewRowAction(style: .destructive, title: String.DeclineInvitation) { (action, indexp) in
                
                tableView.setEditing(false, animated: true)
                self.sbMessageWebservice.DeclineSharingInvitation(message: allMessages[indexPath.row])
                
            }
            return [accept, decline]
            
        } else {
            
            let answer = UITableViewRowAction(style: .default, title: String.AnswerMessage) { (action, indexp) in
                
                self.selectedMessage = allMessages[indexPath.row]
                if let index = allUsers.index(where: { $0.id == self.selectedMessage.senderID }){
                    
                    self.txt_SendAnswer.placeholder = String.localizedStringWithFormat(String.txt_SendAnswerPlaceholder,  allUsers[index].nickname!)
                    
                } else {
                    
                    self.txt_SendAnswer.placeholder = String.localizedStringWithFormat(String.txt_SendAnswerPlaceholder,  "user")
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                    self.txt_SendAnswer.alpha = 1
                }, completion: nil)
                
                self.txt_SendAnswer.becomeFirstResponder()
                
            }
            answer.backgroundColor = UIColor.blue
            
            let delete = UITableViewRowAction(style: .destructive, title: String.DeleteMessage, handler: { (action, indexp) in
                
                self.sbMessageWebservice.DeleteMessage(messageID: allMessages[indexPath.row].id!)
                allMessages.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.setEditing(false, animated: true)
                
            })
            return [delete, answer]
            
        } 
    }
    
    
    // conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
