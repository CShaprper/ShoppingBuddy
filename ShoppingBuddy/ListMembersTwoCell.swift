//
//  ListMembersTwoCell.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 08.09.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ListMembersTwoCell: UICollectionViewCell {
    @IBOutlet var MemberProfileImageTwo: UIImageView!
    @IBOutlet var SharedMemberStarImage: UIImageView!
    
    
    func ConfigureCell(user: ShoppingBuddyUser, member:ShoppingListMember) -> Void {
        
        MemberProfileImageTwo.image = user.profileImage
        MemberProfileImageTwo.layer.cornerRadius = MemberProfileImageTwo.frame.width * 0.5
        MemberProfileImageTwo.layer.borderColor = UIColor.ColorPaletteTintColor().cgColor
        MemberProfileImageTwo.clipsToBounds = true
        MemberProfileImageTwo.layer.borderWidth = 3
        
        if user.isFullVersionUser != nil {
            SharedMemberStarImage.alpha = user.isFullVersionUser! == true ? 1 : 0
        } else {
            SharedMemberStarImage.alpha = 0
        }
        
    }

}
