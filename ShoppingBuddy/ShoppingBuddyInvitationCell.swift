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
        self.backgroundColor = UIColor.clear
        
        SenderProfileImage.layer.cornerRadius = SenderProfileImage.frame.width * 0.5
        SenderProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        SenderProfileImage.clipsToBounds = true
        SenderProfileImage.layer.borderWidth = 3
        
        if let index = allUsers.index(where: { $0.id == invitation.senderID }){
            
            SenderProfileImage.image = allUsers[index].profileImage
            
        } else {
            
            SenderProfileImage.image = #imageLiteral(resourceName: "userPlaceholder")   
            
        }
        
        lbl_InviteTitle.text = invitation.inviteTitle != nil ? invitation.inviteTitle! : ""
        lbl_IvitationMessage.text = invitation.inviteMessage != nil ? invitation.inviteMessage! : ""
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - 5))
        
        whiteRoundedView.layer.backgroundColor = UIColor.white.cgColor
        whiteRoundedView.layer.masksToBounds = true
        whiteRoundedView.layer.cornerRadius = 20
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 10)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
    
        self.contentView.addSubview(whiteRoundedView)
        self.contentView.sendSubview(toBack: whiteRoundedView)
        
    }

}
