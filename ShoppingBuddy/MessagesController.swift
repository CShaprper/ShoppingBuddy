//
//  MessagesControllerViewController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 30.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class MessagesController: UIViewController, IShoppingBuddyMessageWebservice, IAlertMessageDelegate, IActivityAnimationService {
    //MARK: - Outlets
    @IBOutlet var BackgroundImage: UIImageView!
    @IBOutlet var InvitationsTableView: UITableView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    
    private var blurrView:UIVisualEffectView!
    internal var sbMessageWebservice:ShoppingBuddyMessageWebservice!
    
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //SetNavigationBar Title
        navigationItem.title = String.MessagesControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.MessagesControllerTitle
        
        //NotificationListener
        NotificationCenter.default.addObserver(self, selector: #selector(ReloadInvitesTableView), name: NSNotification.Name.ReloadInvitesTableView, object: nil)
        
        //sbMessageWebservice
        sbMessageWebservice = ShoppingBuddyMessageWebservice()
        sbMessageWebservice.shoppingMessageWebServiceDelegate = self
        sbMessageWebservice.activityAnimationServiceDelegate = self
        sbMessageWebservice.alertMessageDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshProfileImagesFromCache()
    }
    
    //MARK: - IAlertMessageDelegate
    func ShowAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - IActivityAnimationService
    func ShowActivityIndicator() {
        
        ActivityIndicator.activityIndicatorViewStyle = .whiteLarge
        ActivityIndicator.center = view.center
        ActivityIndicator.color = UIColor.green
        ActivityIndicator.startAnimating()
        view.addSubview(ActivityIndicator)
        view.bringSubview(toFront:ActivityIndicator)
        
    }
    
    func HideActivityIndicator() {
        
        if view.subviews.contains(ActivityIndicator) {
            ActivityIndicator.removeFromSuperview()
        }
        
    }
    
    //MARK: - IShoppingBuddyMessageWebservice    
    func ShoppingBuddyUserImageReceived() {
        
        refreshProfileImagesFromCache()
        
    }
    
    private func refreshProfileImagesFromCache() -> Void {
        
        for invite in currentUser!.invites {
            if let index = ProfileImageCache.index(where: { $0.ProfileImageURL == invite.senderProfileImageURL! }) {
                invite.senderImage = ProfileImageCache[index].UserProfileImage!
            }
        }
        InvitationsTableView.reloadData()
        
    }
    
    //MARK: - Notification listener selectors
    func ReloadInvitesTableView(notification: Notification) -> Void {
        refreshProfileImagesFromCache()
        InvitationsTableView.reloadData()
    }
}

extension MessagesController: UITableViewDelegate, UITableViewDataSource{
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser!.invites.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.InvitationCell_Identifier, for: indexPath) as! ShoppingBuddyInvitationCell
        
        let invite = currentUser!.invites[indexPath.row]
        
        cell.ConfigureCell(invitation: invite)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let accept = UITableViewRowAction(style: .normal, title: String.AcceptInvitation) { (action, index) in
            
            self.sbMessageWebservice.AcceptInvitation(invitation: currentUser!.invites[indexPath.row])
            tableView.setEditing(false, animated: true)
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        accept.backgroundColor = UIColor.green
        
        let decline = UITableViewRowAction(style: .destructive, title: String.DeclineInvitation) { (action, index) in
            
            tableView.setEditing(false, animated: true)
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
        return [accept, decline]
    }
    
    
    // conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print(indexPath.row) 
        /*
         if editingStyle == .delete {
         
         // Delete the row from the data source
         tableView.deleteRows(at: [indexPath], with: .fade)
         
         } else if editingStyle == .insert {
         
         }*/
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
