//
//  CancelSharingMemberCell.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 10.09.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class CancelSharingMemberCell: UICollectionViewCell {
    @IBOutlet var MemberProfileImage: UIImageView!
    
    func ConfigureCell(user: ShoppingBuddyUser, member:ShoppingListMember) -> Void {
        
//        if member.status! == "owner" {
//            self.contentView.isHidden = true
//        }
        
        MemberProfileImage.image = user.profileImage
        MemberProfileImage.layer.cornerRadius = MemberProfileImage.frame.width * 0.5
        MemberProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        MemberProfileImage.clipsToBounds = true
        MemberProfileImage.layer.borderWidth = 3
        
    }
}
