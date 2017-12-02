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
    @IBOutlet weak var TickImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var txt_ShoppingListItem: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func ConfigureCell(shoppingListItem: ShoppingListItem){
        
        txt_ShoppingListItem.borderStyle = .none
        let listitemText = shoppingListItem.itemName != nil ? shoppingListItem.itemName! : ""
        CheckmarkImage.image = (shoppingListItem.isSelected != nil && shoppingListItem.isSelected == false) ? #imageLiteral(resourceName: "TickBox") : #imageLiteral(resourceName: "TRickBox-checked")
        
        //let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: listitemText)
        //attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        
        if shoppingListItem.isSelected != nil && shoppingListItem.isSelected == true
        {
            //txt_ShoppingListItem.attributedText = nil
            //txt_ShoppingListItem.attributedText = attributeString
            txt_ShoppingListItem.text = listitemText
            txt_ShoppingListItem.alpha = 0.4
            CheckmarkImage.alpha = 0.4
            
        }
        else if shoppingListItem.isSelected != nil && shoppingListItem.isSelected == false
        {
            txt_ShoppingListItem.attributedText = nil
            txt_ShoppingListItem.text = listitemText
            txt_ShoppingListItem.alpha = 1
            CheckmarkImage.alpha = 1
            
        }
    }
}
