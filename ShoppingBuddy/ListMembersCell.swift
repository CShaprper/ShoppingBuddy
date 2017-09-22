//
//  ListMembersCell.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 08.09.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ListMembersCell: UICollectionViewCell {
    @IBOutlet var MemberProfileImage: UIImageView!
    
    
    func ConfigureCell(user: ShoppingBuddyUser, member: ShoppingListMember) -> Void {
        
//        if member.status! == "owner" {
//            self.contentView.isHidden = true
//        }
        self.bringSubview(toFront: MemberProfileImage)
        MemberProfileImage.image = user.profileImage
        MemberProfileImage.layer.cornerRadius = MemberProfileImage.frame.width * 0.5
        MemberProfileImage.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        MemberProfileImage.clipsToBounds = true
        MemberProfileImage.layer.borderWidth = 3
        
    }
}
