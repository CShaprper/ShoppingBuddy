//
//  eNotificationType.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 01.09.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

enum eNotificationType:String {
    
    case SharingInvitation = "SharingInvitation"
    case SharingAccepted = "SharingAccepted"
    case NotSet = "NotSet"
    case CancelSharingByOwner = "CancelSharingByOwner"
    case CancelSharingBySharedUser = "CancelSharingBySharedUser"
    case ListItemAddedBySharedUser = "ListItemAddedBySharedUser"
    case DeclinedSharingInvitation = "DeclinedSharingInvitation"
    case WillGoShoppingMessage = "WillGoShoppingMessage"
    case ChangedTheListMessage = "ChangedTheListMessage"
    case CustomMessage = "CustomMessage"
    case ErrandsCompletedMessage = "ErrandsCompletedMessage"
    case ArticleIsOutMessage = "ArticleIsOutMessage"
    
}
