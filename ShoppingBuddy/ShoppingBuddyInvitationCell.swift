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
    @IBOutlet var lbl_IvitationMessage: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func ConfigureCell(invitation: ShoppingBuddyInvitation) -> Void{
        SenderProfileImage.layer.cornerRadius = SenderProfileImage.frame.width * 0.5
        SenderProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        SenderProfileImage.clipsToBounds = true
        SenderProfileImage.layer.borderWidth = 3
        SenderProfileImage.image = invitation.senderImage != nil ? invitation.senderImage! : nil        
        
        lbl_InviteTitle.text = invitation.inviteTitle != nil ? invitation.inviteTitle! : ""
        lbl_IvitationMessage.text = invitation.inviteMessage != nil ? invitation.inviteMessage! : ""
        
    }

}
