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
    private var sbMessageWebservice:ShoppingBuddyMessageWebservice!
    
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //SetNavigationBar Title
        navigationItem.title = String.MessagesControllerTitle
        
        //SetTabBarTitle
        tabBarItem.title = String.MessagesControllerTitle
        
        //sbMessageWebservice
        sbMessageWebservice = ShoppingBuddyMessageWebservice()
        sbMessageWebservice.shoppingMessageWebServiceDelegate = self
        sbMessageWebservice.activityAnimationServiceDelegate = self
        sbMessageWebservice.alertMessageDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        sbMessageWebservice.ObserveInvitations()
        
    }
    
        //MARK: - IAlertMessageDelegate
    func ShowAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - IActivityAnimationService
    func ShowActivityIndicator() {
        
        if ShowBlurrView() {            
            
            ActivityIndicator.activityIndicatorViewStyle = .whiteLarge
            ActivityIndicator.center = view.center
            ActivityIndicator.color = UIColor.green
            ActivityIndicator.startAnimating()
            view.addSubview(ActivityIndicator)
            
        }
        
    }
    
    func HideActivityIndicator() {
        
        HideBlurrView()
        if view.subviews.contains(ActivityIndicator) {
            ActivityIndicator.removeFromSuperview()
        }
        
    }
    
    //MARK: - IShoppingBuddyMessageWebservice
    func ShoppingBuddyInvitationReceived(invitation: ShoppingBuddyInvitation) {
        
        sbMessageWebservice.DownloadInvitationsProfileImages(invitation: invitation)
        self.tabBarController?.tabBar.items?[2].badgeValue = String(invitationsArray.count)
        
    }
    
    func ShoppingBuddyUserImageReceived() {
        
        for invite in invitationsArray {
            sbMessageWebservice.DownloadInvitationsProfileImages(invitation: invite)
        }
        InvitationsTableView.reloadData()
        
    }
    
    //MARK: - Helpers
    func ShowBlurrView() -> Bool{
        
        if blurrView == nil {
            
            blurrView = UIVisualEffectView()
            blurrView!.effect = UIBlurEffect(style: .light)
            blurrView!.bounds = view.bounds
            blurrView!.center = view.center
            view.addSubview(blurrView!)
            return true
            
        }
        
        return false
        
    }
    
    func HideBlurrView() -> Void{
        
        blurrView?.removeFromSuperview()
        blurrView = nil
        
    }
    
}

extension MessagesController: UITableViewDelegate, UITableViewDataSource{
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return invitationsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.InvitationCell_Identifier, for: indexPath) as! ShoppingBuddyInvitationCell
        
        let invite = invitationsArray[indexPath.row]
        
         cell.ConfigureCell(invitation: invite)
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
