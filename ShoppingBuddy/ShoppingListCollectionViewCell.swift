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
        lbl_ListName.text = shoppingList.name != nil ? shoppingList.name! : ""
        lbl_Store.text = shoppingList.relatedStore != nil ? shoppingList.relatedStore! : ""
        if shoppingList.itemsArray != nil{
            var itemsCount:Int = 0
            for item in shoppingList.itemsArray!{
                switch item.isSelected! {
                case false:
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
