//
//  MessagesControllerViewController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 30.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MessagesController: UIViewController, IAlertMessageDelegate {
    //MARK: - Outlets
    @IBOutlet var BackgroundImage: UIImageView!
    @IBOutlet var InvitationsTableView: UITableView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    
    private var blurrView:UIVisualEffectView!
    internal var sbUserService:ShoppingBuddyUserWebservice!
    internal var sbMessageWebservice:ShoppingBuddyMessageWebservice!
    var bannerView:GADBannerView!
    
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
        
        //sbMessageWebservice
        sbMessageWebservice = ShoppingBuddyMessageWebservice()
        sbMessageWebservice.alertMessageDelegate = self
        sbMessageWebservice.ObserveAllMessages()
        
        //sbUserWebservice
        sbUserService = ShoppingBuddyUserWebservice()
        sbUserService.alertMessageDelegate = self
        
        InvitationsTableView.rowHeight = UITableViewAutomaticDimension
        InvitationsTableView.estimatedRowHeight = 100
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.InvitationsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        print(indexPath)
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
            
            let delete = UITableViewRowAction(style: .destructive, title: "delete", handler: { (action, indexp) in
                
                self.sbMessageWebservice.DeleteMessage(messageID: allMessages[indexPath.row].id!)
                allMessages.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.setEditing(false, animated: true)
                
            })
            return [delete]
            
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
