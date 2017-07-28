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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func ConfigureCell(shoppingList: ShoppingList){
        lbl_ShoppingListItem.text = shoppingList.Name != nil ? shoppingList.Name! : ""
    }
}
