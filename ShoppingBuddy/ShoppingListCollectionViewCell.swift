//
//  ShoppingListCollectionViewCell.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 28.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ShoppingListCollectionViewCell: UICollectionViewCell {
    @IBOutlet var BackgroundImage: UIImageView!
    @IBOutlet var lbl_ListName: UILabel!
    
    func ConfigureCell(shoppingList: ShoppingList) -> Void {
        lbl_ListName.text = shoppingList.Name != nil ? shoppingList.Name! : ""
    }
}
