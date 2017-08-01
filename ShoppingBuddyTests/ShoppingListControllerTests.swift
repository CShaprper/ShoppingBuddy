//
//  ShoppingListController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 28.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import XCTest
@testable import ShoppingBuddy

class ShoppingListControllerTests: XCTestCase {
    var storyboard:UIStoryboard!
    var sut:ShoppingListController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        sut = storyboard.instantiateViewController(withIdentifier: "ShoppingListController") as! ShoppingListController
        
        // Test and Load the View at the Same Time!
        XCTAssertNotNil(sut.view)
        sut.viewDidLoad()
        sut.didReceiveMemoryWarning()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_ListDetailView_Exists(){
        XCTAssertNotNil(sut!.ShoppingListDetailView, "ShoppingListDetailView should exist")
    }
    func test_ListDetailBackgroundImage_Exists(){
        XCTAssertNotNil(sut!.ListDetailBackgroundImage, "ListDetailBackgroundImage should exist")
    }
    func test_ListDetailTableView_Exists(){
        XCTAssertNotNil(sut!.ShoppingListDetailTableView, "ListDetailTableView should exist")
    }
    func test_ListDetailTableViewDelegate_isSet() {
        XCTAssertNotNil(sut!.ShoppingListDetailTableView.delegate, "ListDetailTableView.delegate not set")
    }
    func test_ListDetailTableViewDatasource_isSet() {
        XCTAssertNotNil(sut!.ShoppingListDetailTableView.dataSource, "ListDetailTableView.dataSource not set")
    }
    func test_DetailTableViewBottomConstraint_Exists(){
        XCTAssertNotNil(sut!.DetailTableViewBottomConstraint, "DetailTableViewBottomConstraint should exist")
    }
    /* func test_ListDetailTableViewCell_hasCorrectResuseIdentifier(){
     let cell = sut.ListDetailTableView.dequeueReusableCell(withIdentifier: String.ShoppingListItemTableViewCell_Identifier) as! ShoppingListItemTableViewCell
     XCTAssertNotNil(cell, "ShoppingListItemTableViewCell_Identifier should not be nil")
     XCTAssertTrue(cell.reuseIdentifier == String.ShoppingListItemTableViewCell_Identifier, "TabelViewCell reuseIdentifier is \(String(describing: cell.reuseIdentifier)) and should be \(String.ShoppingListItemTableViewCell_Identifier)")
     }*/
    //Add List PopUp
    func test_txt_RelatedStore_Exists(){
        XCTAssertNotNil(sut!.txt_RelatedStore, "txt_RelatedStore should exist")
    }
    func test_txt_RelatedStore_Placeholder_isNotNil(){
        XCTAssertNotNil(sut!.txt_RelatedStore.placeholder, "txt_RelatedStore Placeholder not set")
    }
    func test_txt_RelatedStore_Placeholder_isSet(){
        XCTAssertTrue(sut!.txt_RelatedStore.placeholder != "", "txt_RelatedStore Missing placeholder value")
    }
    func test_txt_RelatedStoreTextColor_isSet(){
        XCTAssertEqual(sut!.txt_RelatedStore.textColor, UIColor.ColorPaletteSecondDarkest(), "txt_RelatedStore.textColor should be set")
    }
    func test_txt_RelatedStore_Placeholder_ShowsLocalizedString(){
        XCTAssertEqual(sut!.txt_RelatedStore.placeholder, String.txt_RelatedStore_Placeholder, "txt_RelatedStore_Placeholer not localized")
    }
    func test_txt_RelatedStore_DelegateIsSet() {
        XCTAssertNotNil(sut!.txt_RelatedStore.delegate, "txt_RelatedStore.delegate not set")
    }
    func test_txt_ListName_Exists(){
        XCTAssertNotNil(sut!.txt_ListName, "txt_ListName should exist")
    }
    func test_txt_ListName_Placeholder_isNotNil(){
        XCTAssertNotNil(sut!.txt_ListName.placeholder, "txt_ListName Placeholder not set")
    }
    func test_txt_ListName_Placeholder_isSet(){
        XCTAssertTrue(sut!.txt_ListName.placeholder != "", "txt_ListName Missing placeholder value")
    }
    func test_txt_ListNameTextColor_isSet(){
        XCTAssertEqual(sut!.txt_ListName.textColor, UIColor.ColorPaletteSecondDarkest(), "txt_ListName.textColor should be set")
    }
    func test_txt_ListName_Placeholder_ShowsLocalizedString(){
        XCTAssertEqual(sut!.txt_ListName.placeholder, String.txt_ListName_Placeholder, "txt_ListName_Placeholer not localized")
    }
    func test_txt_ListName_DelegateIsSet() {
        XCTAssertNotNil(sut!.txt_ListName.delegate, "txt_ListName.delegate not set")
    }
    func test_btn_SaveList_isWired_ToAction(){
        XCTAssertTrue(ControlTagetTester.checkTargetForOutlet(outlet: sut!.btn_SaveList, actionName: "btn_SaveList_Pressed", event: .touchUpInside, controller: sut! ))
    }
    
    //Add Item PopUp
    func test_AddItemPopUp_Exists(){
        XCTAssertNotNil(sut!.AddItemPopUp, "AddItemPopUp should exist")
    }
    func test_txt_ItemName_Exists(){
        XCTAssertNotNil(sut!.txt_ItemName, "txt_ItemName should exist")
    }
    func test_txt_ItemName_Placeholder_isNotNil(){
        XCTAssertNotNil(sut!.txt_ItemName.placeholder, "txt_ItemName Placeholder not set")
    }
    func test_txt_ItemName_Placeholder_isSet(){
        XCTAssertTrue(sut!.txt_ItemName.placeholder != "", "txt_ItemName Missing placeholder value")
    }
    func test_txt_ItemNameTextColor_isSet(){
        XCTAssertEqual(sut!.txt_ItemName.textColor, UIColor.ColorPaletteSecondDarkest(), "txt_ItemName.textColor should be set")
    }
    func test_txt_ItemName_Placeholder_ShowsLocalizedString(){
        XCTAssertEqual(sut!.txt_ItemName.placeholder, String.txt_ItemName_Placeholer, "txt_ItemName_Placeholer not localized")
    }
    func test_txt_ItemName_DelegateIsSet() {
        XCTAssertNotNil(sut!.txt_ItemName.delegate, "txt_ItemName.delegate not set")
    }
    func test_btn_SaveItem_isWired_ToAction(){
        XCTAssertTrue(ControlTagetTester.checkTargetForOutlet(outlet: sut!.btn_SaveItem, actionName: "btn_SaveItem_Pressed", event: .touchUpInside, controller: sut! ))
    }
    
    //Trash && Shopping cart images
    func test_TrashImage_Exists(){
        XCTAssertNotNil(sut!.TrashImage, "TrashImage should exist")
    }
    func test_ShoppingCartImage_Exists(){
        XCTAssertNotNil(sut!.ShoppingCartImage, "ShoppingCartImage should exist")
    }
}
