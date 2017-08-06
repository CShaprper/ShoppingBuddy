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
    @IBOutlet var lbl_Store: UILabel!
    @IBOutlet var lbl_ItemsCount: UILabel!
    
    
    func ConfigureCell(shoppingList: ShoppingList) -> Void {
        lbl_ListName.text = shoppingList.Name != nil ? shoppingList.Name! : ""
        lbl_Store.text = shoppingList.RelatedStore != nil ? shoppingList.RelatedStore! : ""
        if shoppingList.ItemsArray != nil{
            var itemsCount:Int = 0
            for item in shoppingList.ItemsArray!{
                switch item.isSelected! {
                case "false":
                    itemsCount += 1
                    break
                default:
                    break
                }
            }
            lbl_ItemsCount.text = String(itemsCount)
        }
    }
}
