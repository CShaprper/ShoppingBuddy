//
//  ShoppingListItemTableViewCell.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 28.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ShoppingListItemTableViewCell: UITableViewCell {
    //MARK: - Outlets
    @IBOutlet var CheckmarkImage: UIImageView!
    @IBOutlet var lbl_ShoppingListItem: UILabel!    
    @IBOutlet weak var TickImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var ListItemLabelLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func ConfigureCell(shoppingListItem: ShoppingListItem){
        TickImageLeadingConstraint.constant = self.contentView.frame.width * 0.1
        ListItemLabelLeadingConstraint.constant = self.contentView.frame.width * 0.1
        
        lbl_ShoppingListItem.text = shoppingListItem.ItemName != nil ? shoppingListItem.ItemName! : ""
        CheckmarkImage.image = (shoppingListItem.isSelected != nil && shoppingListItem.isSelected == "false") ? #imageLiteral(resourceName: "TickBox") : #imageLiteral(resourceName: "TRickBox-checked")
        
        //        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: lbl_ShoppingListItem.text!)
        if shoppingListItem.isSelected != nil && shoppingListItem.isSelected == "true"
        {
            /* attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
             attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor.gray, range: NSMakeRange(0, attributeString.length))
             textLabel?.attributedText = attributeString*/
            
            lbl_ShoppingListItem.alpha = 0.5
            CheckmarkImage.alpha = 0.5
        }
        else if shoppingListItem.isSelected != nil && shoppingListItem.isSelected == "false"
        {
            lbl_ShoppingListItem.alpha = 1
            CheckmarkImage.alpha = 1
        }
    }
}
