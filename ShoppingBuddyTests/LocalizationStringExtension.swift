//
//  LocalizationStringExctension.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 22.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation

extension String{
    //Validation Service Alert
    static let ValidationAlert_Title = NSLocalizedString("ValidationAlert_Title", comment: "")
    
    //Password validation
    static let ValidationPasswordEmptyAlert_Message = NSLocalizedString("ValidationPasswordEmptyAlert_Message", comment: "")
    static let ValidationPasswordCharactersCountBelowSixAlert_Message = NSLocalizedString("ValidationPasswordCharactersCountBelowSixAlert_Message", comment: "")
    
    //Nickname validation
    static let ValidationNicknameEmptyAlert_Message = NSLocalizedString("ValidationNicknameEmptyAlert_Message", comment: "")
    static let ValidationNicknameShouldContainAtLeastSixCharacters = NSLocalizedString("ValidationNicknameShouldContainAtLeastSixCharacters", comment: "")
    
    //Email validation
    static let ValidationEmailEmptyAlert_Message = NSLocalizedString("ValidationEmailEmptyAlert_Message", comment: "")
    static let ValidationEmailShouldContainAtSign = NSLocalizedString("ValidationEmailShouldContainAtSign", comment: "")
    static let ValidationEmailShouldContainDot = NSLocalizedString("ValidationEmailShouldContainDot", comment: "")
    static let ValidationEmailContainsSpaces = NSLocalizedString("ValidationEmailContainsSpaces", comment: "")
    static let ValidationEmailEndingInvalid = NSLocalizedString("ValidationEmailEndingInvalid", comment: "")
    static let ValidationEmailContainsInvalidCharacters = NSLocalizedString("ValidationEmailContainsInvalidCharacters", comment: "")
    
    //Textfield validation
    static let ValidationTextFieldEmptyAlert_Message = NSLocalizedString("ValidationTextFieldEmptyAlert_Message", comment: "")
    static let ValidationTextFieldBelowTwoCharachtersAlert_Message = NSLocalizedString("ValidationTextFieldBelowTwoCharachtersAlert_Message", comment: "")
    
    //LoginController
    static let LogInSegmentedControll_SegmentOne = NSLocalizedString("LogInSegmentedControll_SegmentOne", comment: "")
    static let LogInSegmentedControll_SegmentTwo = NSLocalizedString("LogInSegmentedControll_SegmentTwo", comment: "")
    static let txt_Nickname_Placeholder = NSLocalizedString("txt_Nickname_Placeholder", comment: "")
    static let txt_Email_Placeholder = NSLocalizedString("txt_Email_Placeholder", comment: "")
    static let txt_Password_Placeholer = NSLocalizedString("txt_Password_Placeholer", comment: "")
    static let LoginResetPassword = NSLocalizedString("LoginResetPassword", comment: "")
    
    //DashboardController
    static let DashboardControllerTitle = NSLocalizedString("DashboardControllerTitle", comment: "")
    static let lbl_ObeservedStoresText = NSLocalizedString("lbl_ObeservedStoresText", comment: "")
    static let lbl_ObservedListsText = NSLocalizedString("lbl_ObservedListsText", comment: "")
    static let lbl_YourListsText = NSLocalizedString("lbl_YourListsText", comment: "")
    
    //SettingsController
    static let SettingsControllerTitle = NSLocalizedString("SettingsControllerTitle", comment: "")
    static let txt_AddStore_Placeholder = NSLocalizedString("txt_AddStore_Placeholder", comment: "")
    
    //ShoppingListController
    static let ShoppingListControllerTitle = NSLocalizedString("ShoppingListControllerTitle", comment: "")
    static let CustomRefreshControlImage = NSLocalizedString("CustomRefreshControlImage", comment: "")
    // Add Shopping List PopUp
    static let lbl_AddListPopUpTitle = NSLocalizedString("lbl_AddListPopUpTitle", comment: "")
    static let txt_RelatedStore_Placeholder = NSLocalizedString("txt_RelatedStore_Placeholder", comment: "")
    static let txt_ListName_Placeholder = NSLocalizedString("txt_ListName_Placeholder", comment: "")
    //Add Item PopUp
    static let lbl_AddItemPopUpTitle = NSLocalizedString("lbl_AddItemPopUpTitle", comment: "")
    static let txt_ItemName_Placeholer = NSLocalizedString("txt_ItemName_Placeholer", comment: "")
    static let CustomAddShoppingListRefreshControlImage = NSLocalizedString("CustomAddShoppingListRefreshControlImage", comment: "")
    
    //LocationService
    static let GPSAuthorizationRequestDenied_AlertTitle = NSLocalizedString("GPSAuthorizationRequestDenied_AlertTitle", comment: "")
    static let GPSAuthorizationRequestDenied_AlertMessage = NSLocalizedString("GPSAuthorizationRequestDenied_AlertMessage", comment: "")
    static let GPSAuthorizationRequestDenied_AlertActionSettingsTitle = NSLocalizedString("GPSAuthorizationRequestDenied_AlertActionSettingsTitle", comment: "")
    static let GPSAuthorizationRequestDenied_AlertActionSettingsNoTitle = NSLocalizedString("GPSAuthorizationRequestDenied_AlertActionSettingsNoTitle", comment: "")
    static let LocationManagerEnteredRegion_AlertTitle = NSLocalizedString("LocationManagerEnteredRegion_AlertTitle", comment: "")
    static let LocationManagerEnteredRegion_AlertMessage = NSLocalizedString("LocationManagerEnteredRegion_AlertMessage", comment: "")
    
    //ShoppingCards
    static let lbl_ShoppingCardTotalItems_Label = NSLocalizedString("lbl_ShoppingCardTotalItems_Label", comment: "")
    static let lbl_ShoppingCardOpenItems_Label = NSLocalizedString("lbl_ShoppingCardOpenItems_Label", comment: "")
    
    //ShareListPopUp
    static let lbl_ShareListTitle = NSLocalizedString("lbl_ShareListTitle", comment: "")
    static let txt_ShareOpponentEmailPlaceholder = NSLocalizedString("txt_ShareOpponentEmailPlaceholder", comment: "")
    
    //Share List Message
    static let UserEmailNotFoundTitle = NSLocalizedString("UserEmailNotFoundTitle", comment: "")
    static let UserEmailNotFoundMessage = NSLocalizedString("UserEmailNotFoundMessage", comment: "")
    static let ShareListMessage = NSLocalizedString("ShareListMessage", comment: "")
    static let ShareListTitle = NSLocalizedString("ShareListTitle", comment: "")
    static let ShareListAcceptedTitle = NSLocalizedString("ShareListAcceptedTitle", comment: "")
    static let ShareListAcceptedMessage = NSLocalizedString("ShareListAcceptedMessage", comment: "")
    static let CancelSharingTitle = NSLocalizedString("CancelSharingTitle", comment: "")
    static let CancelSharingMessage = NSLocalizedString("CancelSharingMessage", comment: "")
    static let NotAllowedToShareListAlertTitle = NSLocalizedString("NotAllowedToShareListAlertTitle", comment: "")
    static let NotAllowedToShareListAlertMessage = NSLocalizedString("NotAllowedToShareListAlertMessage", comment: "")
    static let ListCurrentlyNotSharedTitle = NSLocalizedString("ListCurrentlyNotSharedTitle", comment: "")
    static let ListCurrentlyNotSharedMessage = NSLocalizedString("ListCurrentlyNotSharedMessage", comment: "")
    static let lbl_CancelSharing = NSLocalizedString("lbl_CancelSharing", comment: "") 
    static let CancelSharingSelectedMemberAlertTitle = NSLocalizedString("CancelSharingSelectedMemberAlertTitle", comment: "")
    static let CancelSharingSelectedMemberAlertMessage = NSLocalizedString("CancelSharingSelectedMemberAlertMessage", comment: "")
    static let LeaveGroupListAlertTitle = NSLocalizedString("LeaveGroupListAlertTitle", comment: "")
    static let LeaveGroupListAlertMessage = NSLocalizedString("LeaveGroupListAlertMessage", comment: "")
    static let ListOwnerCanceledSharingTitle = NSLocalizedString("ListOwnerCanceledSharingTitle", comment: "")
    static let ListOwnerCanceledSharingMessage = NSLocalizedString("ListOwnerCanceledSharingMessage", comment: "") 
    static let SharedUserCanceledSharingTitle = NSLocalizedString("SharedUserCanceledSharingTitle", comment: "")
    static let SharedUserCanceledSharingMessage = NSLocalizedString("SharedUserCanceledSharingMessage", comment: "")
    static let SharingDeclinedMessageTitle = NSLocalizedString("SharingDeclinedMessageTitle", comment: "")
    static let SharingDeclinedMessageMessage = NSLocalizedString("SharingDeclinedMessageMessage", comment: "")
    static let lbl_PinnedAddress = NSLocalizedString("lbl_PinnedAddress", comment: "")
    
    //List item Added Message
    static let ListItemAddedTitle = NSLocalizedString("ListItemAddedTitle", comment: "")
    static let ListItemAddedMessage = NSLocalizedString("ListItemAddedMessage", comment: "")
    
    static let WillGoShoppingMessageTitle = NSLocalizedString("WillGoShoppingMessageTitle", comment: "")
    static let WillGoShoppingMessageMessage = NSLocalizedString("WillGoShoppingMessageMessage", comment: "")
    
    //Delete List Message
    static let ShoppingListDeleteAlertTitle = NSLocalizedString("ShoppingListDeleteAlertTitle", comment: "")
    static let ShoppingListDeleteAlertMessage = NSLocalizedString("ShoppingListDeleteAlertMessage", comment: "")
    
    //Firebase Error Messages
    static let OnlineFetchRequestError = NSLocalizedString("OnlineFetchRequestError", comment: "")
    
    //Messages Controller
    static let MessagesControllerTitle = NSLocalizedString("MessagesControllerTitle", comment: "")
    
    //Messages TableView EditActions
    static let AcceptInvitation = NSLocalizedString("AcceptInvitation", comment: "")
    static let DeclineInvitation = NSLocalizedString("DeclineInvitation", comment: "")
    
    //In App Purchases
    static let PurchaseRestoreAlertTitle = NSLocalizedString("PurchaseRestoreAlertTitle", comment: "")
    static let PurchaseRestoreAlertMessage = NSLocalizedString("PurchaseRestoreAlertMessage", comment: "")
    static let PurchaseDeniedAlertTitle = NSLocalizedString("PurchaseDeniedAlertTitle", comment: "")
    static let PurchaseDeniedAlertMessage = NSLocalizedString("PurchaseDeniedAlertMessage", comment: "")
    static let FullVersionNeededAlertTitle = NSLocalizedString("FullVersionNeededAlertTitle", comment: "")
    static let FullVersionNeededArticleAlertMessage = NSLocalizedString("FullVersionNeededArticleAlertMessage", comment: "")
    static let FullVersionNeededSharingAlertMessage = NSLocalizedString("FullVersionNeededSharingAlertMessage", comment: "")
    static let FullVersionNeededListCountAlertMessage = NSLocalizedString("FullVersionNeededListCountAlertMessage", comment: "")
    
    //InfoView Image names
    static let DashboardOnboardingImage = NSLocalizedString("DashboardOnboardingImage", comment: "")
    static let ShoppingListsOnboardiongImage = NSLocalizedString("ShoppingListsOnboardiongImage", comment: "")
}
