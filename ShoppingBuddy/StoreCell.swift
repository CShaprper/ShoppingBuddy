//
//  StoreCell.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 26.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class StoreCell: UITableViewCell {
    @IBOutlet var lbl_StoreName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func ConfigureCell(store: Store) -> Void {
        lbl_StoreName.text = store.Store != nil ? store.Store! : ""
        lbl_StoreName.textColor = UIColor.ColorPaletteTintColor()
    }
}
