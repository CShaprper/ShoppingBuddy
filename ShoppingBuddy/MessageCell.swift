//
//  ShoppingBuddyInvitationCell.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 31.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ShoppingBuddyInvitationCell: UITableViewCell {
    //MARK: - Outlets
    @IBOutlet var SenderProfileImage: UIImageView!
    @IBOutlet var lbl_InviteTitle: UILabel!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var RoundedView: UIView!
    @IBOutlet var lbl_Date: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func ConfigureCell(invitation: ShoppingBuddyMessage) -> Void{
        self.backgroundColor = UIColor.clear
        
        RoundedView.layer.borderColor = tintColor.cgColor
        RoundedView.layer.borderWidth = 5
        RoundedView.layer.cornerRadius = 30
        
        SenderProfileImage.layer.cornerRadius = SenderProfileImage.frame.width * 0.5
        SenderProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        SenderProfileImage.clipsToBounds = true
        SenderProfileImage.layer.borderWidth = 3
        
        if let index = allUsers.index(where: { $0.id == invitation.senderID }){
            
            SenderProfileImage.image = allUsers[index].profileImage
            
        } else {
            
            SenderProfileImage.image = #imageLiteral(resourceName: "userPlaceholder")   
            
        }
        
        lbl_InviteTitle.text = invitation.title != nil ? invitation.title! : ""
        lblMessage.text = invitation.message != nil ? invitation.message! : ""
        lbl_Date.text = invitation.date != nil ? invitation.date! : ""
        
    }

}
