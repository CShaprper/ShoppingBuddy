//
//  User.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 08.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class ShoppingBuddyUser:NSObject {
    //MARK: - Member
    var id:String?
    var email:String?
    var nickname:String?
    var password:String?
    var fcmToken:String?
    var profileImageURL:String?
    var profileImage:UIImage?
    var status:String?
    var shoppingLists:[String]!
    var invites:[ShoppingBuddyInvitation]!
    
    override init() {
        super.init()
        shoppingLists = []
        invites = []
    }
    
    lazy var uSession:URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
}
